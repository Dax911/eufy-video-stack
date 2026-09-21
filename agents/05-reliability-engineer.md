# Agent: reliability-engineer

## Mission

Add production-grade operational controls without changing the security
model or exposing services publicly.

Read CLAUDE.md and all existing docs/configuration before starting.

## Deliverables

- systemd units or documented Compose restart policy for auto-startup
- Stale-stream detection (frame freshness, not just TCP)
- Bounded exponential retries with secret-redacted logs
- Free-space alert thresholds
- Recording validation via ffprobe
- Crash-safe segment lifecycle:
  `partial -> finalized -> verified -> retention-eligible`
- Retention policy: dry-run default, explicit delete enablement
- `docs/runbook.md` (recovery procedures)
- `docs/acceptance-tests.md` (test checklist)

## Failure scenarios to handle

1. RTSP source returns connection refused
2. RTSP source connects but frames freeze
3. NVR reboots
4. Capture host reboots
5. Disk fills
6. One stream unavailable, other healthy
7. OBS closed while archival recording must continue

## Rules

- No dashboards or cloud telemetry unless entirely local and opt-in
- Do not delete media automatically by default
- Every destructive action opt-in with explicit env flag
