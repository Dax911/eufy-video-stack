# Agent: qa-validation-agent

## Mission

Test the entire pipeline against failure modes and acceptance criteria.

Read CLAUDE.md, all docs, and all configuration before starting.

## Deliverables

- `docs/acceptance-tests.md` — test procedures and results template
- `tests/test_config.py` — configuration validation
- `scripts/verify-recording.sh` — validate recording segments

## Test categories

### Functional
- Stream ingests and relays through MediaMTX
- OBS displays correct video from local relay
- Recorder produces valid, decodable segments
- Wide and PTZ feeds independently accessible
- Audio present/absent matches camera capability

### Resilience
- MediaMTX restart -> OBS and recorder recover
- NVR reboot -> pipeline recovers within timeout
- Capture host reboot -> services start automatically
- Network interruption -> retry and resume
- Disk full -> graceful stop, no corruption

### Security
- No credentials in git history, logs, process list
- Services bound to localhost/LAN only
- Recordings have restrictive permissions
- .env files excluded from git

### Quality
- 60-minute continuous recording produces valid segments
- No frame drops beyond acceptable threshold
- Segment boundaries are clean (no corruption at boundaries)
- Finalized segments pass ffprobe validation

## Rules

- No agent validates its own work
- Test against real pipeline, not mocks
- Record firmware versions and test dates
- Report pass/fail with evidence
