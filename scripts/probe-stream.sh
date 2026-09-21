#!/usr/bin/env bash
set -euo pipefail

# probe-stream.sh: Validate RTSP/ONVIF endpoint accessibility
# Usage: ./scripts/probe-stream.sh [endpoint_url]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../.env" 2>/dev/null || true

ENDPOINT_URL="${1:-${UPSTREAM_URL:-}}"
if [[ -z "$ENDPOINT_URL" ]]; then
    echo "Error: No endpoint URL provided. Set UPSTREAM_URL in .env or pass as argument."
    exit 1
fi

# Redact credentials for logging
SAFE_URL=$(echo "$ENDPOINT_URL" | sed 's/:\/\/[^@]*@/:\/\/***@/')

echo "=== Stream Probe: $SAFE_URL ==="
echo "Timestamp: $(date -Iseconds)"

if ! command -v ffprobe &> /dev/null; then
    echo "Error: ffprobe not found. Install ffmpeg."
    exit 1
fi

echo -e "\n--- Probing with TCP transport ---"
if timeout 30 ffprobe -hide_banner \
    -rtsp_transport tcp \
    -show_streams \
    -show_format \
    -print_format json \
    "$ENDPOINT_URL" 2>&1 | tee /tmp/probe-result.json; then

    echo -e "\n=== Probe Summary ==="
    jq -r '
        .streams[] |
        "Stream \(.index): \(.codec_type) - \(.codec_name) \(.width)x\(.height) @ \(.r_frame_rate)"
    ' /tmp/probe-result.json 2>/dev/null || echo "Raw output saved to /tmp/probe-result.json"

    echo -e "\nEndpoint is accessible and returning media"
else
    echo -e "\nProbe failed. Common causes:"
    echo "  - Authentication failure"
    echo "  - Network unreachable"
    echo "  - RTSP not enabled on device"
    echo "  - Incorrect URL format"
    exit 1
fi
