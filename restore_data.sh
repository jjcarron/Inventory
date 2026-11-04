#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "" ]]; then
  echo "Usage: $0 <archive.tar.gz> [target_dir]" >&2
  exit 1
fi

ARCHIVE_PATH="$(realpath "$1")"
TARGET_DIR="${2:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
CHECKSUM_PATH="${ARCHIVE_PATH}.sha256"

if [[ ! -f "$ARCHIVE_PATH" ]]; then
  echo "Archive not found: $ARCHIVE_PATH" >&2
  exit 1
fi

if [[ -f "$CHECKSUM_PATH" ]]; then
  echo "Verifying checksum with $CHECKSUM_PATH"
  EXPECTED_HASH="$(awk 'NR==1 {print $1}' "$CHECKSUM_PATH")"
  ACTUAL_HASH="$(sha256sum "$ARCHIVE_PATH" | awk '{print $1}')"

  if [[ -z "$EXPECTED_HASH" ]]; then
    echo "Checksum file is empty or invalid: $CHECKSUM_PATH" >&2
    exit 1
  fi

  if [[ "$EXPECTED_HASH" != "$ACTUAL_HASH" ]]; then
    echo "Checksum mismatch for $ARCHIVE_PATH" >&2
    echo "Expected: $EXPECTED_HASH" >&2
    echo "Actual:   $ACTUAL_HASH" >&2
    exit 1
  fi
  echo "Checksum OK"
else
  echo "No checksum file found next to archive. Skipping checksum verification."
fi

mkdir -p "$TARGET_DIR"
tar -xzf "$ARCHIVE_PATH" -C "$TARGET_DIR"

echo "Restore complete into: $TARGET_DIR"
