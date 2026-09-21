# Agent: obs-integration-engineer

## Mission

Configure OBS to consume local MediaMTX endpoints for scene composition
and optional presentation recording.

Read CLAUDE.md, `docs/camera-findings.md`, `docs/architecture.md`, and
`docs/runbook.md` before starting.

## Deliverables

- `docs/obs-setup.md`

## Guide must include

1. Separate scene/source structure for wide/bullet and PTZ streams
2. Media Source and VLC Source fallback guidance
3. Hardware decode guidance for Linux
4. Recording format: crash-resilient MKV vs direct-to-MP4 tradeoffs
5. Source recovery/restart procedure for RTSP freezes
6. Audio handling: identify whether upstream has usable audio
7. Local test matrix:
   - OBS restart
   - MediaMTX restart
   - Camera/NVR reboot
   - Temporary packet loss
   - Recorder running while OBS is closed
8. No public streaming destinations, no credentials, no exposed endpoints

## Scene checklist

- Full-frame wide shot
- PTZ shot
- Picture-in-picture (wide + PTZ)
- Privacy slate / camera-off scene
- Recording indicator and audio meter verification

## Rules

- Do not modify system-wide OBS files automatically
- All GUI steps explicit and reproducible
- OBS consumes local MediaMTX relay, NOT raw Eufy/NVR stream
