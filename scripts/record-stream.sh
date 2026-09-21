#!/usr/bin/env bash
set -euo pipefail

# record-stream.sh: Continuous segmented recording with FFmpeg
# Usage: ./scripts/record-stream.sh [stream_name]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../.env"

STREAM_NAME="${1:-main}"
SEGMENT_DURATION="${SEGMENT_DURATION:-3600}"
RECORDING_DIR="${RECORDING_DIR:-./recordings}"

mkdir -p "$RECORDING_DIR"
chmod 700 "$RECORDING_DIR"

case "$STREAM_NAME" in
    main|wide)
        SOURCE_URL="${UPSTREAM_URL:-}"
        ;;
    ptz)
        SOURCE_URL="${UPSTREAM_PTZ_URL:-${UPSTREAM_URL:-}}"
        ;;
    sub|low)
        SOURCE_URL="${UPSTREAM_SUB_URL:-${UPSTREAM_URL:-}}"
        ;;
    *)
        SOURCE_URL="${UPSTREAM_URL:-}"
        ;;
esac

if [[ -z "$SOURCE_URL" ]]; then
    echo "Error: No upstream URL configured for stream '$STREAM_NAME'"
    exit 1
fi

SAFE_URL=$(echo "$SOURCE_URL" | sed 's/:\/\/[^@]*@/:\/\/***@/')
echo "=== Starting Recording ==="
echo "Stream: $STREAM_NAME"
echo "Source: $SAFE_URL"
echo "Output: $RECORDING_DIR"
echo "Segment duration: ${SEGMENT_DURATION}s"

while true; do
    echo "[$(date -Iseconds)] Starting segment for $STREAM_NAME"

    if ffmpeg -hide_banner \
        -rtsp_transport tcp \
        -use_wallclock_as_timestamps 1 \
        -fflags +genpts \
        -i "$SOURCE_URL" \
        -c copy \
        -f segment \
        -segment_time "$SEGMENT_DURATION" \
        -segment_format mkv \
        -reset_timestamps 1 \
        -strftime 1 \
        "${RECORDING_DIR}/${STREAM_NAME}_%Y%m%d_%H%M%S.mkv" \
        2> >(sed "s|$SOURCE_URL|***REDACTED***|g" >> "${RECORDING_DIR}/ffmpeg.log"); then

        echo "[$(date -Iseconds)] Segment completed normally"
    else
        echo "[$(date -Iseconds)] FFmpeg exited with error. Restarting in 5 seconds..."
        sleep 5
    fi
done
