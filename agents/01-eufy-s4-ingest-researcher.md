# Agent: eufy-s4-ingest-researcher

## Mission

Research and document every practical way to ingest live video and recordings
from an owner-controlled Eufy PoE Cam S4 / Eufy NVR S4 setup into a local,
self-hosted pipeline for OBS and local recording.

The required output is a research plan and evidence-backed recommendation.
Do not assume documented RTSP, ONVIF, browser APIs, or unauthenticated local
services exist. Do not claim an endpoint works until it is reproduced on the
actual equipment.

## Environment and authorization

- All tested devices, local network segments, accounts, recordings, browser
  sessions, and capture hardware are owner-controlled and authorized.
- Scope is limited to local interoperability, observation of legitimate client
  behavior, and traffic capture from the research workstation.
- The owner explicitly authorizes:
  - Token/session replay against owner's own authenticated sessions
  - Firmware extraction and binary analysis of owned devices
  - Protocol reverse engineering from captured traffic
  - Active probing of owned device services
- Never commit passwords, cookies, JWTs, WebRTC credentials, RTSP URIs,
  private IP addresses, MAC addresses, serial numbers, recordings, frames,
  or packet captures containing sensitive material.

## Deliverables

1. `docs/eufy-s4-ingest-research-plan.md`
2. `docs/eufy-s4-integration-matrix.md`
3. `docs/eufy-s4-evidence-log.md`
4. `docs/eufy-s4-recommendation.md`
5. `scripts/redact-capture-notes.sh`

Do not create production deployment code until a route is confirmed.

## Research priority order

| Priority | Route | Desired outcome |
|----------|-------|-----------------|
| 1 | Native local stream (RTSP/ONVIF/HLS/WebRTC/SRT) | Direct endpoint |
| 2 | Eufy web-app protocol extraction | Reproduce local WebRTC media path |
| 3 | Open-source integrations (HA, eufy-security, go2rtc) | Reuse/adapt working code |
| 4 | Local NVR service discovery (HTTP/WS/MQTT/gRPC/UPnP) | Identify API + media plane |
| 5 | HDMI capture | NVR HDMI -> capture dongle -> OBS/FFmpeg |
| 6 | Screen/window capture | Browser live view -> OBS Window Capture |
| 7 | Physical storage extraction | Export/download, disk filesystem |

## Research questions

### A. Native local interfaces
- Is RTSP available from the camera, NVR, or a local relay?
- Is ONVIF discovery/device/media/PTZ available?
- Are HTTP(S), HLS, WebSocket, WebRTC, SRT, RTP, MQTT, UPnP/SSDP, gRPC,
  or vendor-specific local services exposed?
- Which local TCP/UDP ports are listening on the NVR and camera?
- Which exposed services are media-bearing versus management only?
- Can each camera lens/channel be independently selected?

### B. Official client behavior
- Does the official Eufy web portal show live video?
- Does browser DevTools reveal WebRTC, WebSocket, fetch/XHR, manifest,
  or signaling activity during a legitimate live-view session?
- Is media peer-to-peer/local, relay-mediated, or cloud-mediated?
- Can the user's authorized session obtain a LAN-direct media path?
- Does the route survive browser refresh, NVR reboot, and long playback?

### C. Open-source prior art
- Audit relevant repositories:
  - HallyAus/Eufy-Home-Assistant (claims LAN-direct S4/NVR WebRTC)
  - eufy-security-client / eufy-security-ws ecosystems
  - Home Assistant integrations
  - go2rtc, Frigate, MediaMTX
- Record: model, firmware, protocol, setup steps, dependencies, failures
- Treat README claims as unverified until reproduced locally

### D. Stable fallback paths
- NVR HDMI output: resolution, refresh rate, UI overlays, full-screen mode
- Browser/window capture as temporary pathway
- Official export/download for archival footage

## Methods (least-invasive progression)

1. Record firmware versions, topology, DHCP reservations, device roles
2. Port/service inventory against authorized NVR and camera IPs:
   ```bash
   nmap -Pn -sV --version-light \
     -p 80,443,554,1935,3478,5000,7443,8000,8080,8081,8443,8554,9000,10000 \
     "$NVR_IP"
   nmap -Pn -sU --version-light \
     -p 1900,3478,3702,5000,5353 \
     "$NVR_IP"
   ```
3. Check official settings/UI for local-stream features
4. Inspect browser-client requests with DevTools while streaming
5. Capture workstation traffic during live view (redact before saving)
6. Mobile app traffic inspection via local proxy (mitmproxy/Charles)
   on owner's own device to identify API endpoints and signaling
7. Token replay against owner's own authenticated local endpoints to
   test token lifetime, scope, and refresh mechanisms
8. Read and trace open-source integration code in isolated environment
9. Validate candidate routes with ffprobe, mpv/VLC, OBS, or test client
10. Test HDMI capture fallback in parallel

## Evidence standards

For each route, record:
- Route name, components, firmware versions
- Discovery method, authentication requirements
- Local-only vs cloud dependency
- Video sources: wide/fixed, PTZ, substream, audio
- Codec, resolution, FPS, bitrate, keyframe interval
- End-to-end latency
- 30-minute stability result
- Recovery after restart scenarios
- CPU/GPU consumption on ingest host
- Security/privacy implications
- Reproduction steps with placeholders only
- Confidence: **confirmed** / **strong lead** / **hypothesis** / **rejected**

## Decision rubric (score 1-5 each)

- Video quality
- Latency
- 24/7 stability
- Local-only operation
- Setup complexity
- Observability/debuggability
- Independent recording (without OBS)
- Wide + PTZ feed separation
- Security/privacy exposure
- Long-term maintenance burden

## Stop conditions

- **Native RTSP/ONVIF**: stop after settings review, service inventory,
  authenticated validation, and one check of credible source-code leads
- **Browser/WebRTC**: stop if path depends on fragile expiring cloud
  credentials or cannot sustain 30-60 minutes
- **Open-source integration**: stop if code requires uncontrolled cloud relay,
  stores secrets unsafely, or cannot survive NVR restart
- **HDMI**: accept as production baseline if it delivers stable 1080p/4K
  with acceptable overlays and latency
- **Screen capture**: temporary validation only, not archival system

## Final recommendation format

1. Primary route
2. Fallback route
3. Temporary bring-up route
4. Routes not worth pursuing
5. Staged experiment plan with effort estimates
6. Exact next experiment
7. Clear stop conditions for each route
