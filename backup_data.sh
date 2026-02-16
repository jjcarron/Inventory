#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date -u +%Y%m%d_%H%M%S)"
BACKUP_DIR="${1:-$ROOT_DIR/backups}"
ARCHIVE_NAME="inventory_data_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="$BACKUP_DIR/$ARCHIVE_NAME"
CHECKSUM_PATH="${ARCHIVE_PATH}.sha256"

DATA_PATHS=(
  "InventoryManager/data/init_data"
  "InventoryManager/data/input"
  "InventoryManager/data/output"
  "OrdersPostProcessingPipeline/data"
  "aliexpress_orders_exporter/data"
)

mkdir -p "$BACKUP_DIR"

EXISTING_PATHS=()
for p in "${DATA_PATHS[@]}"; do
  if [[ -e "$ROOT_DIR/$p" ]]; then
    EXISTING_PATHS+=("$p")
  fi
done

if [[ "${#EXISTING_PATHS[@]}" -eq 0 ]]; then
  echo "No data paths found to back up. Nothing done." >&2
  exit 1
fi

tar -C "$ROOT_DIR" --exclude-vcs -czf "$ARCHIVE_PATH" "${EXISTING_PATHS[@]}"
# Write checksum with archive basename to keep the file portable across machines.
(cd "$BACKUP_DIR" && sha256sum "$ARCHIVE_NAME" > "$(basename "$CHECKSUM_PATH")")

echo "Backup created: $ARCHIVE_PATH"
echo "Checksum file:  $CHECKSUM_PATH"
echo "Included paths:"
for p in "${EXISTING_PATHS[@]}"; do
  echo "- $p"
done
