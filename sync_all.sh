#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo "[1/4] Synchronize submodule URLs"
git submodule sync --recursive

echo "[2/4] Initialize and checkout recorded submodule commits"
git submodule update --init --recursive

echo "[3/4] Pull latest remote changes for submodules (tracked branches)"
git submodule update --remote --merge --recursive

echo "[4/4] Current submodule status"
git submodule status --recursive

echo
echo "Done. If submodule pointers changed, commit them in the root repo:"
echo "  git add InventoryManager OrdersPostProcessingPipeline aliexpress_orders_exporter"
echo "  git commit -m \"Update submodule pointers\""
