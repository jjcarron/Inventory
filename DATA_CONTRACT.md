# DATA CONTRACT - Inventory

Verified against local code and files: 2026-11-03
Scope: data sources and schemas used to rebuild the database and ingest new orders.

## 1) Scraper output (Aliexpress)
Process: a new CSV is created for each import batch. Columns are fixed and do not change per file.
File naming pattern:
- `Aliexpress_orders_details_YYYYMMDD_YYYYMMDD.csv`
- Example: `Aliexpress_orders_details_20031121_20251211.csv` means export window from 2003-11-21 to 2025-12-11.

Columns (fixed):
- order
- order_date
- received_date
- store_name
- store_link
- item_name
- db_item_name
- item_link
- item_image_link
- db_item_img
- item_attribute
- item_unit_price
- item_quantity
- order_price

Notes:
- File naming pattern is part of the contract.
- There are 14 columns. `db_item_name` starts empty; `db_item_img` is filled when an image is downloaded.
- The date filter is exclusive; the start date in the filename is the day after `--last_order_date`.
- CSV exports use UTF-8 and semicolon separators; order numbers must remain text.

## 2) LLM step (OrdersPostProcessingPipeline)
Purpose: generate a short name and category for each item. Output must be manually validated.

Input columns (from scraper):
- order, order_date, received_date, store_name, store_link, item_name, db_item_name, item_link, item_image_link,
  db_item_img, item_attribute, item_unit_price, item_quantity, order_price

Output columns after first steps (llm_step + ensure_extra_columns):
- order
- order_date
- received_date
- store_name
- store_link
- item_name
- db_item_name
- item_link
- item_image_link
- db_item_img
- item_attribute
- item_unit_price
- item_quantity
- order_price
- item_tag_code
- confidence
- ai_status
- ai_error
- ai_raw_json
- i
- code
- uuid
- container_code
- flag

Manual validation:
- `db_item_name` and `item_tag_code` are verified/corrected manually.
- `confidence`, `ai_status`, `ai_error`, `ai_raw_json` are LLM quality metadata and are not manually modified.

## 3) Manually processed input (OrdersPostProcessingPipeline)
Location: `OrdersPostProcessingPipeline/data/manually_processed_input`

File naming convention:
- `data_n_YYYYMMDD.csv` where `n` is a sequence number and `YYYYMMDD` is creation date.

Expected column superset (LLM quality/debug columns may be absent in historical files):
- order
- order_date
- received_date
- store_name
- store_link
- item_name
- db_item_name
- item_link
- item_image_link
- db_item_img
- item_attribute
- item_unit_price
- item_quantity
- order_price
- item_tag_code
- confidence
- ai_status
- ai_error
- ai_raw_json
- i
- code
- uuid
- container_code
- flag

Notes:
- Each file is a manually validated copy of the pipeline output after the first two steps.
- Lots 1 and 2 have 22 columns (no ai_error/ai_raw_json); lot 3 has 24.
- Lot 1 is historically comma-separated; the pipeline reader tries delimiter fallbacks. New files and generated outputs use semicolons.
- A matching `pipeline.process_data_n.yml` is created manually to run the rest of the pipeline.

## 4) Enriched orders for import (InventoryManager)
Location: `InventoryManager/data/input`
Pattern:
- `orders_details_enriched_YYYYMMDD_YYYYMMDD.csv`

Columns:
- order
- order_date
- received_date
- store_name
- store_link
- item_name
- db_item_name
- item_link
- item_image_link
- db_item_img
- item_attribute
- item_unit_price
- item_quantity
- order_price
- item_tag_code
- confidence
- ai_status
- i
- code
- uuid
- container_code
- flag
- quantity_multiplier
- quantity_multiplier_source
- db_item_total_quantity
- db_item_values
- db_unit_cost

Load rule:
- `inventory_manager.py load_ali_orders` (also called by `load_data`) reads all files matching
  `^orders_details_enriched_(\d{4})(\d{2})(\d{2})_(\d{4})(\d{2})(\d{2})\.csv$` in `InventoryManager/data/input`.

## 5) Base data (authoritative, manual)
Authoritative sources (edited manually):
- `InventoryManager/data/init_data/Basic_Data.xlsx`
- `InventoryManager/data/init_data/Staging_Data.xlsx`

These Excel files are the source of truth in the current phase.
The CSV files in `InventoryManager/data/input` are snapshots exported from these Excel files.

### 5.1 Basic_Data.xlsx
Sheets and columns:
- Tags: code, name, parent_code, default_icon
- Countries: name, ISO_code
- UserRoles: role, code

Purpose:
- Business reference data (tag taxonomy, countries, user roles). Translations are authoritative JSON catalogs under InventoryManager/inventorymanager/resources/i18n; they are not database initialization inputs.

### 5.2 Staging_Data.xlsx
Sheets and columns:
- StgAddresses: Code, title, last_name, first_name, enterprise, address_line1, address_line2, city, zip, state, notes, country_ISO_code
- StgContainers: code, label, uuid, printed, container_type, icon, image, notes, address_code, parent_container_code
- StgCDs: artist, title, container_code, style, comment
- StgDVDs: title, extras, style, container_code, comment
- StgItems: name, code, uuid, description, quantity, notes, container_code, supplier_code, tag_code
- StgItemExtras: item_code, extra_type_code, value_text, value_numeric, value_date, link
- StgDocs: item_code, doc_type_code, value_text, value_numeric, value_date, link
- StgSuppliers: name, address_code, e-mail, phone_1, website, comments
- StgUsers: username, code, password_hash, hash_scheme, email, is_active, created_at, updated_at, last_login_at, role_code, address_code

Notes:
- Stg* sheets are imported as raw staging tables, then post-processed into final tables with resolved dependencies.
- The Stg* naming is the contract for intermediate table names.

## 6) Exported staging CSV (versioned snapshots)
Location: `InventoryManager/data/input`
Files:
- `Countries.csv`, `Tags.csv`, `UserRoles.csv`, and the nine `Stg*.csv` files listed above.
- Export filenames match the sheet/table name exactly; current export tools do not prepend `basic_data_`.

Notes:
- These files are regenerated from the Excel sources and versioned for change tracking.
- They are not the primary source of truth.

## 7) Historical manually_modified_data location (relations)
Purpose: manual completion of relations, especially item ⇄ container mapping.

Status:
- No `manually_modified_data/*.csv` directory was found at the expected workspace locations.
- The active corrected order sources are the four files in `OrdersPostProcessingPipeline/data/manually_processed_input`. `container_code`, `code`, `uuid` and `flag` are passed through to the import.
- Do not assume a historical directory mentioned in older instructions has been recovered or is required by the current scripts.

## 8) Derived fields, snapshots and filesystem media

- Active deterministic pipelines produce 27-column import CSVs, with `db_item_values` encoded as a JSON list.
- `db_item_total_quantity` is derived from item_quantity and detected quantity multipliers. The implementation computes `db_unit_cost` from item_unit_price multiplied by purchased item_quantity, divided by total physical quantity, with quantity fallbacks. This was corrected on 2026-11-03 for batches ordering multiple units.
- Current optional Excel outputs use sheet `StgAliItemOrders` in the four post-processing configurations; scraper Excel output uses `Item_Orders`.
- `save_data` exports the 15 tables listed in `project.tables.export_data_tables`; all `Stg*` tables are excluded, including `StgAliItemOrders`.
- The output manifest filename remains `manifest.output.export_data.json`; `restore_data` writes `manifest.input.load_all.json` for compatibility. These filenames do not mean the old CLI commands still exist.
- Media paths are relative to `InventoryManager/data/static`; database CSV snapshots contain references and metadata, not the binary files. Copying scraper images to this static directory and deploying them is a separate operation.
- The default import reads all matching Ali CSVs. Use `load_ali_orders --input-file <filename>` for a single new batch: existing order IDs are rejected before import. CSV `order_price` maps to the ORM field `item_order_price`. See `WORKFLOW.md` before replaying on an active inventory.

## 9) Reviewed import corrections — Linux_version_0.1

The first two final `orders_details_enriched_*.csv` inputs were manually corrected on 2026-11-04 after deterministic processing. These final files are the validated import references until all corrections have been backported upstream; regenerating older manual inputs can overwrite reviewed quantities and split assortments. `quantity_multiplier` is not consumed by the Inventory loader; physical stock comes from `db_item_total_quantity`, allocated across `db_item_values`.

The latest disposable PostgreSQL rebuild contains 2,204 items / 52,103 units, with no fractional allocation in active order rows. One heterogeneous box is represented by nine IC references of five units each plus five sockets, all in `BTE_7x13x2_TR08`. The input manifest captures current CSV hashes; it does not certify the business correctness of every source identifier. Detailed source observations are retained in `InventoryManager/docs/CORRECTED_IMPORT_REVIEW_20261104.md`.
