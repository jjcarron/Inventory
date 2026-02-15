# DATA CONTRACT - Inventory

Snapshot date: 2026-02-12
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
- item_link
- item_image_link
- item_attribute
- item_unit_price
- item_quantity
- order_price

Notes:
- File naming pattern is part of the contract.

## 2) LLM step (OrdersPostProcessingPipeline)
Purpose: generate a short name and category for each item. Output must be manually validated.

Input columns (from scraper):
- order, order_date, received_date, store_name, store_link, item_name, item_link, item_image_link,
  item_attribute, item_unit_price, item_quantity, order_price

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

Columns (same as LLM step output):
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
- `inventory_manager.py load` reads all files matching
  `^orders_details_enriched_(\d{4})(\d{2})(\d{2})_(\d{4})(\d{2})(\d{2})\.csv$` in `InventoryManager/data/input`.

## 5) Base data (authoritative, manual)
Authoritative sources (edited manually):
- `InventoryManager/data/init_data/Basic_Data.xlsx`
- `InventoryManager/data/init_data/Staging_Data.xlsx`

These Excel files are the source of truth in the current phase.
The CSV files in `InventoryManager/data/input` are snapshots exported from these Excel files.

### 5.1 Basic_Data.xlsx
Sheets and columns:
- Resources: key, en, de, fr, it
- Tags: code, name, parent_code, default_icon
- Countries: name, ISO_code
- UserRoles: role, code

Purpose:
- Stable reference data (i18n, tag taxonomy, countries, user roles).

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
- `Stg*.csv`, `basic_data_*.csv`

Notes:
- These files are regenerated from the Excel sources and versioned for change tracking.
- They are not the primary source of truth.

## 7) Manually modified data (relations)
Purpose: manual completion of relations, especially item ⇄ container mapping.

Status:
- Files are expected under `manually_modified_data/*.csv` but are not present in the workspace at snapshot time.
- Once available, their columns will be documented here.
