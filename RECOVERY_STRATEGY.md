# Recovery Strategy - Inventory

> Historical proposal dated 2026-02-12, reviewed 2026-11-03. This document is not the current runbook. Use [WORKFLOW.md](WORKFLOW.md) for implemented commands. CSV snapshots/manifests and PostgreSQL backup tools now exist; the provenance ledger, scheduling and retention policies described below are proposals unless separately verified. Current commands are `load_ali_orders`, `save_data` and `restore_data`. Media files require a separate backup.

Snapshot date: 2026-02-12
Target context: production operation with mutable DB and about 10,000+ objects.

## Objectives
- Rebuild the application and database at any time without data loss.
- Keep backup format independent from DB technology.
- Keep operations overhead low.
- Preserve current `inventory_manager.py load` flow for new AliExpress imports.

## Recommended Direction
- Use a hybrid model in production:
- Truth source for runtime data: PostgreSQL.
- Truth source for stable reference bootstrap: `Basic_Data.xlsx` + `Staging_Data.xlsx`.
- Recovery source: automated versioned exports in open formats (`CSV` + metadata manifest).

Reason:
- At 10,000 objects, continuous manual DB <-> Excel synchronization is error-prone.
- DB currently does not track source file provenance, so reverse-sync to Excel is costly.

## Level 1 - Simple Strategy (Minimal Ops)
Goal: reach reliable recovery quickly with low implementation effort.

### A. Backup Artifacts (technology-independent)
- Export all mutable business tables to CSV (UTF-8, `;` separator).
- Important:
- `InventoryManager/tools/export_staging_data_to_csv.py` and `InventoryManager/tools/export_basic_data_to_csv.py` export from Excel files, not from DB.
- For production recovery snapshots, add dedicated DB export tools (DB -> CSV/manifest).
- Keep Excel export tools only for bootstrap/reference workflows.
- Export a recovery manifest `recovery_manifest.json` containing:
- export timestamp (UTC)
- app version / git commit
- row counts per exported file
- sha256 checksum per exported file
- aliases for source patterns used during export (notably `orders_details_enriched_*.csv`)

### B. Backup Cadence
- Daily scheduled snapshot.
- Additional snapshot after each `load` batch.
- Additional snapshot before schema migration.

### C. Restore Procedure
1. Deploy app code matching the snapshot commit.
2. Recreate empty DB schema (`create` flow).
3. Import `Basic_Data` and `Staging_Data` sources.
4. Import exported mutable CSV snapshots into final tables (from DB snapshot artifacts, not Excel exports).
5. Replay missing `orders_details_enriched_*.csv` batches only when snapshot is older than latest ingested batch.
6. Verify counts and checksums against `recovery_manifest.json`.

### D. Provenance (Minimal)
- Add an import log table (`ImportBatches`) in DB:
- `batch_id` (uuid), `source_filename`, `source_sha256`, `imported_at_utc`, `rows_read`, `rows_inserted`, `status`.
- During `load`, register one row per imported `orders_details_enriched_*.csv`.
- Store filename + checksum, not only date range.

## Level 2 - Robust Strategy (Recommended for Long-Term)
Goal: deterministic replay and auditable recovery with low human intervention.

### A. Immutable Batch Ledger
- For each imported `orders_details_enriched_*.csv`, keep:
- original file in archive directory (write-once policy)
- file checksum
- parsed date range from filename
- import status and retry history
- Keep this ledger in both DB and filesystem manifest.

### B. Deterministic Rebuild Pipeline
- Provide one command/script to rebuild from zero:
- create schema
- load Basic/Staging
- replay archived AliExpress batches in deterministic order
- run post-processing hooks
- run integrity checks
- Script output must include final counts and success/failure report.

### C. Point-in-Time Safety
- Add PostgreSQL logical backup for fast disaster recovery.
- Keep CSV/manifest exports as DB-independent fallback.
- Retention example:
- daily for 30 days
- weekly for 12 weeks
- monthly for 12 months

### D. Data Integrity Checks
- Required post-restore checks:
- row counts per critical table
- FK integrity checks
- orphan checks for item/container/media relations
- random sample comparison with latest manifest

## Required Changes by Subproject

### 1) `InventoryManager`
- Add `ImportBatches` model/table and migration.
- Extend `load` path to write provenance (filename + checksum + counts).
- Add `tools/export_recovery_snapshot.py` to generate:
- table CSV exports
- `recovery_manifest.json`
- Add `tools/restore_from_snapshot.py` (or CLI command) for deterministic restore.
- Keep current Excel->CSV tools unchanged for bootstrap/reference:
- `tools/export_staging_data_to_csv.py`
- `tools/export_basic_data_to_csv.py`

### 2) `OrdersPostProcessingPipeline`
- Add optional batch manifest output for each `data_n_YYYYMMDD.csv`:
- input source filename
- pipeline config used
- output checksum
- Keep one metadata file per batch to simplify chain-of-custody.

### 3) `aliexpress_orders_exporter`
- Emit checksum file per export:
- `Aliexpress_orders_details_YYYYMMDD_YYYYMMDD.csv.sha256`
- Optional JSON sidecar with extraction metadata:
- date range
- export timestamp
- row count

## Operational Policy
- In production, do not maintain Excel as the canonical mutable dataset.
- Keep Excel for bootstrap/editing workflows where useful, but treat snapshots + manifests as recovery contract.
- Keep `inventory_manager.py load` as the ingestion entrypoint for new order batches.

## Immediate Next Step (Low Risk)
1. Implement Level 1 provenance in `load` (`ImportBatches` + checksum).
2. Add snapshot export script + manifest generation.
3. Test full restore on a disposable DB.
