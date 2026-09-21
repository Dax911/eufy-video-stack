# Eufy Video Stack — Engineering Contract

## Objective

Build a LAN-only, privacy-preserving video ingest, relay, OBS integration,
and local-recording stack for a Eufy PoE S4 Bullet-PTZ camera connected to
an Eufy NVR S4. Target use: adult content production with local recording
and OBS scene composition.

## Owner authorization scope

All devices, network segments, accounts, firmware, and recordings referenced
in this project are owner-controlled. The following research activities are
explicitly authorized against owned hardware only:

- Passive and active local network traffic capture
- Port scanning and service fingerprinting of owned NVR/camera IPs
- Browser session inspection (DevTools, WebRTC internals)
- Token/session replay against owner's own authenticated sessions
- Firmware extraction and binary analysis of owned devices
- Protocol reverse engineering from captured traffic
- ONVIF/UPnP/SSDP/mDNS discovery against owned devices
- Credential testing with owner's own accounts
- Mobile app traffic inspection via local proxy (mitmproxy/Charles)
- Cloud API probing limited to owner's authenticated endpoints

The following remain out of scope:

- Credential theft from other users
- Token replay against accounts not owned by operator
- Mass scanning of shared/cloud infrastructure
- Brute force attacks
- Vulnerability exploitation of vendor systems
- Firmware modification or binary patching
- Publishing streams to the Internet
- Copying sensitive video into the repository

## Safety and privacy requirements

- Camera, NVR, MediaMTX, OBS host, and recorder must never be exposed
  directly to the public Internet.
- Do not add port forwarding, UPnP, cloud relays, Tailscale Funnel,
  public RTMP endpoints, or remote-access defaults.
- Never place credentials, RTSP URLs containing credentials, serial numbers,
  MAC addresses, private IPs, recordings, or screenshots in Git.
- Use environment variables or Docker secrets for credentials.
- Store recordings outside the repository.
- Assume recordings are sensitive personal media:
  use encrypted storage where supported and restrictive filesystem permissions.
- Every person filmed must have explicitly consented to recording and
  the intended distribution.
- Preserve human review before destructive retention/deletion changes.

## Source-of-truth rules

- Do not invent an RTSP URL, ONVIF profile, authentication method, codec,
  stream count, or resolution.
- Document every discovered camera/NVR capability with:
  date, firmware version, discovery method, endpoint, auth type, codec,
  resolution, FPS, and result.
- Prefer direct local probing and official Eufy documentation.
- Treat third-party RTSP endpoint lists as hypotheses only.

## Architecture

```
Camera/NVR -> MediaMTX -> {OBS, FFmpeg recorder}
```

Do not have OBS and the recorder independently pull from the camera/NVR
unless testing proves the NVR supports the required concurrent clients.

OBS is for scene composition and streaming output. A separate FFmpeg-based
recorder preserves the camera feed continuously — even when OBS is closed,
a scene changes, or an OBS source freezes.

## Engineering conventions

- Target Linux host and Docker Compose.
- Shell scripts: `set -euo pipefail`
- Use quoted variables and validate required environment variables.
- Prefer TCP transport for RTSP where UDP loss is problematic.
- Segment recordings; do not create one unbounded file.
- Write recordings to a staging extension and atomically finalize them.
- Record in MKV when crash resilience is more important; remux finalized
  segments to MP4 only as a separate, verified step.
- Add disk-space and stale-stream health checks.
- Emit useful structured logs without leaking secrets.

## Required acceptance tests

1. Stream can run for 60 minutes without manually restarting OBS.
2. Recorder writes valid, decodable segments.
3. Restarting MediaMTX self-recovers downstream OBS and recorder paths.
4. Loss of upstream stream triggers visible unhealthy state and retry.
5. Retention removes only eligible old files; no current segment is deleted.
6. Credentials do not appear in git diff, logs, process list, or docs.
7. Reboot of capture host returns recording service automatically.
8. HDMI fallback works if protocol route fails.

## Agent roles

| Agent | Mission |
|---|---|
| `eufy-s4-ingest-researcher` | Map every ingest path, produce evidence-backed recommendation |
| `camera-protocol-researcher` | Establish real S4/NVR stream/control capabilities |
| `network-security-architect` | LAN segmentation, credentials, firewall, storage encryption |
| `media-pipeline-engineer` | MediaMTX + FFmpeg pull/relay/record stack |
| `obs-integration-engineer` | OBS scene/source configuration and recovery |
| `reliability-engineer` | Watchdogs, verification, retention, restart, runbook |
| `qa-validation-agent` | Test pipeline against failure modes |

No agent validates its own work. Research agents produce findings before
implementation agents write production code.
