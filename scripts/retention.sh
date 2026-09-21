#!/usr/bin/env bash
set -euo pipefail

# retention.sh: Recording retention management with dry-run default

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../.env" 2>/dev/null || true

RECORDING_DIR="${RECORDING_DIR:-./recordings}"
RETENTION_DAYS="${RETENTION_DAYS:-7}"
DRY_RUN="${DRY_RUN:-1}"

echo "=== Recording Retention Job ==="
echo "Directory: $RECORDING_DIR"
echo "Retention: ${RETENTION_DAYS} days"
echo "Dry run: $DRY_RUN"
echo "Timestamp: $(date -Iseconds)"

if [[ ! -d "$RECORDING_DIR" ]]; then
    echo "Error: Recording directory does not exist"
    exit 1
fi

# macOS date vs GNU date
if date -v-1d &>/dev/null 2>&1; then
    CUTOFF_DATE=$(date -v-${RETENTION_DAYS}d +%Y%m%d)
else
    CUTOFF_DATE=$(date -d "${RETENTION_DAYS} days ago" +%Y%m%d)
fi

echo -e "\nFiles eligible for deletion (older than $CUTOFF_DATE):"

find "$RECORDING_DIR" -name "*.mkv" -type f | while read -r file; do
    FILENAME=$(basename "$file")
    if [[ "$FILENAME" =~ _([0-9]{8})_ ]]; then
        FILE_DATE="${BASH_REMATCH[1]}"
        if [[ "$FILE_DATE" < "$CUTOFF_DATE" ]]; then
            echo "  $FILENAME (date: $FILE_DATE)"

            if [[ "$DRY_RUN" == "0" ]]; then
                if ! lsof "$file" &>/dev/null; then
                    rm "$file"
                    echo "    -> Deleted"
                else
                    echo "    -> SKIPPED (file in use)"
                fi
            fi
        fi
    fi
done

if [[ "$DRY_RUN" == "1" ]]; then
    echo -e "\nThis was a dry run. Set DRY_RUN=0 to actually delete files."
else
    echo -e "\nRetention job completed."
fi
