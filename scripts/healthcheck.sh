#!/usr/bin/env bash
set -euo pipefail

# healthcheck.sh: Pipeline health monitoring

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../.env" 2>/dev/null || true

UPSTREAM_URL="${UPSTREAM_URL:-}"
RELAY_URL="${RELAY_URL:-rtsp://localhost:8554/eufy}"
RECORDING_DIR="${RECORDING_DIR:-./recordings}"
MIN_FREE_SPACE_GB="${MIN_FREE_SPACE_GB:-10}"
MAX_SEGMENT_AGE_MINUTES="${MAX_SEGMENT_AGE_MINUTES:-5}"

STATUS="HEALTHY"
MESSAGES=()

# Check upstream reachability
if [[ -n "$UPSTREAM_URL" ]]; then
    if timeout 10 ffprobe -hide_banner -rtsp_transport tcp \
        -show_streams "$UPSTREAM_URL" &>/dev/null; then
        MESSAGES+=("OK: Upstream reachable")
    else
        MESSAGES+=("FAIL: Upstream unreachable")
        STATUS="DEGRADED"
    fi
fi

# Check relay (MediaMTX) health
if timeout 10 ffprobe -hide_banner -rtsp_transport tcp \
    -show_streams "$RELAY_URL" &>/dev/null; then
    MESSAGES+=("OK: Relay reachable")
else
    MESSAGES+=("FAIL: Relay unreachable")
    STATUS="DEGRADED"
fi

# Check disk space
if command -v df &>/dev/null; then
    FREE_GB=$(df -BG "$RECORDING_DIR" 2>/dev/null | awk 'NR==2 {print $4}' | tr -d 'G' || \
        df -g "$RECORDING_DIR" | awk 'NR==2 {print $4}')  # macOS fallback
    if [[ "$FREE_GB" -gt "$MIN_FREE_SPACE_GB" ]]; then
        MESSAGES+=("OK: Disk space: ${FREE_GB}G free")
    else
        MESSAGES+=("FAIL: Disk space critical: ${FREE_GB}G free (min: ${MIN_FREE_SPACE_GB}G)")
        STATUS="CRITICAL"
    fi
fi

# Check for recent recording activity
if [[ -d "$RECORDING_DIR" ]]; then
    LATEST_SEGMENT=$(find "$RECORDING_DIR" -name "*.mkv" -mmin -"$MAX_SEGMENT_AGE_MINUTES" 2>/dev/null | head -1)
    if [[ -n "$LATEST_SEGMENT" ]]; then
        MESSAGES+=("OK: Recent recording activity")
    else
        MESSAGES+=("FAIL: No recent recording activity (${MAX_SEGMENT_AGE_MINUTES}min)")
        STATUS="DEGRADED"
    fi
fi

echo "=== Health Check: $STATUS ==="
printf '%s\n' "${MESSAGES[@]}"
echo "Timestamp: $(date -Iseconds)"

case "$STATUS" in
    HEALTHY) exit 0 ;;
    DEGRADED) exit 1 ;;
    CRITICAL) exit 2 ;;
esac
