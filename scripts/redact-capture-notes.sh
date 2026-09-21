#!/bin/bash
# Redact sensitive data from research capture notes before committing.
# Usage: ./scripts/redact-capture-notes.sh <file>
set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <file>"
    exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "Error: $FILE not found"
    exit 1
fi

echo "Redacting sensitive data from: $FILE"

# IP addresses (RFC1918)
sed -i.bak -E 's/192\.168\.[0-9]+\.[0-9]+/<REDACTED_IP>/g' "$FILE"
sed -i.bak -E 's/10\.[0-9]+\.[0-9]+\.[0-9]+/<REDACTED_IP>/g' "$FILE"
sed -i.bak -E 's/172\.(1[6-9]|2[0-9]|3[01])\.[0-9]+\.[0-9]+/<REDACTED_IP>/g' "$FILE"

# MAC addresses
sed -i.bak -E 's/([0-9a-fA-F]{2}:){5}[0-9a-fA-F]{2}/<REDACTED_MAC>/g' "$FILE"

# Serial numbers (common patterns)
sed -i.bak -E 's/[Ss]erial[^:]*:[[:space:]]*[A-Z0-9]{8,}/Serial: <REDACTED_SERIAL>/g' "$FILE"

# RTSP URLs with credentials
sed -i.bak -E 's|rtsp://[^@]+@|rtsp://<REDACTED_CREDS>@|g' "$FILE"

# Bearer tokens / JWTs
sed -i.bak -E 's/[Bb]earer [A-Za-z0-9._-]{20,}/Bearer <REDACTED_TOKEN>/g' "$FILE"
sed -i.bak -E 's/eyJ[A-Za-z0-9._-]{20,}/<REDACTED_JWT>/g' "$FILE"

# Cookie values
sed -i.bak -E 's/[Cc]ookie:[[:space:]]*[^\n]+/Cookie: <REDACTED_COOKIES>/g' "$FILE"

# Clean up backup files
rm -f "${FILE}.bak"

echo "Done. Review $FILE before committing."
