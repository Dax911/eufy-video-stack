# Agent: media-pipeline-engineer

## Mission

Build the Docker Compose video pipeline: MediaMTX relay + FFmpeg recorder.

Read CLAUDE.md and `docs/eufy-s4-*` findings before making changes.
Only proceed after the ingest researcher has confirmed at least one route.

## Deliverables

- `compose.yml`
- `mediamtx.yml`
- `.env.example` (update with pipeline variables)
- `scripts/probe-stream.sh`
- `scripts/record-stream.sh`
- `scripts/healthcheck.sh`
- `scripts/retention.sh`
- `docs/runbook.md`
- `docs/architecture.md`

## Requirements

1. Pull only confirmed upstream RTSP endpoint(s) from .env
2. Relay each stream through MediaMTX on localhost/LAN
3. Record each selected stream continuously with FFmpeg in fixed-duration segments
4. Stream-copy when upstream codec/container allows — no re-encode by default
5. Restart strategy for network interruptions and stale inputs
6. Configurable host recording directory (not tracked in git)
7. Strict permissions, no credentials in CLI arguments
8. Health checks: upstream reachability, frame freshness, segment progress, free storage
9. Retention script defaults to DRY_RUN=1, requires explicit flag to delete
10. Segment lifecycle: `.recording.mkv` -> `.mkv` (finalized) -> verified -> retention-eligible

## Rules

- Do not use a fake RTSP URL in executable defaults
- Never log full RTSP URI if it contains a password
- Bind admin/control ports to 127.0.0.1
- Make every destructive action opt-in
- Include smoke test: `ffprobe` against local relay
