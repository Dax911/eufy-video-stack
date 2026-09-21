# Eufy S4 Ingest Research Plan

## Status: STAGE 0 — Lab Inventory (next: physical access required)

*Stage 4 (open-source prior art audit) completed 2026-09-21 via web research.*
*See eufy-s4-evidence-log.md (EV-001 through EV-008) and eufy-s4-recommendation.md.*

## Equipment

| Item | Model | Firmware | IP | Notes |
|------|-------|----------|----|-------|
| NVR | Eufy NVR S4 | TBD | TBD | Check model number on unit |
| Camera | Eufy PoE Cam S4 Bullet-PTZ | TBD | TBD | Triple-lens: wide + PTZ |
| Capture host | TBD | | TBD | Linux recommended |
| HDMI capture | TBD | | N/A | Fallback path |

## Stage 0: Lab Inventory (CURRENT)

- [ ] Record exact NVR model number and hardware revision
- [ ] Record NVR firmware version
- [ ] Record camera model number
- [ ] Record camera firmware version
- [ ] Record Eufy app version
- [ ] Document physical topology: camera -> NVR PoE port vs camera -> switch -> NVR
- [ ] Confirm which devices get IP leases (camera, NVR, or both)
- [ ] Assign DHCP reservations
- [ ] Confirm live view works in mobile app
- [ ] Confirm live view works in desktop browser (if available)
- [ ] Check NVR HDMI output: resolution, refresh rate, per-camera full-screen mode
- [ ] Check NVR storage configuration
- [ ] Identify all NVR/app settings related to: RTSP, NAS, ONVIF, local access, third-party

## Stage 1: Local Service Inventory

- [ ] Port scan NVR (TCP: 80,443,554,1935,3478,5000,7443,8000,8080,8081,8443,8554,9000,10000)
- [ ] Port scan NVR (UDP: 1900,3478,3702,5000,5353)
- [ ] Port scan camera IP if visible on LAN
- [ ] Document all listening services
- [ ] Identify media-bearing vs management-only services
- [ ] Test RTSP 554/8554 if listening
- [ ] Test ONVIF 3702 if listening
- [ ] Test HTTP/HTTPS management interfaces

## Stage 2: Official Configuration

- [ ] Check all NVR UI settings for stream/RTSP/ONVIF options
- [ ] Check all Eufy app settings for local stream options
- [ ] Check for "third-party integration" or "developer" sections
- [ ] Enable RTSP if option exists; record credentials created
- [ ] Test any official RTSP endpoint with ffprobe

## Stage 3: Browser/App Protocol Observation

- [ ] Open fresh browser profile with authorized Eufy login
- [ ] Start DevTools Network tab before loading live view
- [ ] Record: request domains, protocols, WebSocket connections
- [ ] Check chrome://webrtc-internals during live view
- [ ] Classify: LAN WebRTC / NAT traversal / TURN relay / cloud relay / HLS
- [ ] Capture workstation traffic during live view (tcpdump/Wireshark)
- [ ] Redact and save findings

## Stage 4: Open-Source Prior Art Audit (COMPLETED 2026-09-21)

- [x] Audit HallyAus/Eufy-Home-Assistant — WebRTC extraction, experimental, firmware-fragile (EV-003)
- [x] Review eufy-security-client / eufy-security-ws — T8N00 listed but streaming broken (EV-004)
- [x] Review eufy-mega-client (keesmod) — T8N00 explicitly unsupported (EV-005)
- [x] Check go2rtc Eufy support — no native source type, transport layer only (EV-006)
- [x] Confirm Eufy web portal live view — mysecurity.eufylife.com confirmed (EV-007)
- [x] Identify camera model number — T8E00121 (EV-008)
- [x] Assess RTSP/ONVIF availability — likely unavailable on S4 (EV-001)
- [x] Document findings in eufy-s4-evidence-log.md, eufy-s4-integration-matrix.md, eufy-s4-recommendation.md

## Stage 5: HDMI Capture Baseline (parallel)

- [ ] Test NVR HDMI output characteristics
- [ ] Test with HDMI capture device
- [ ] Measure latency, quality, UI overlays
- [ ] Record 1-hour stability test
- [ ] Assess as production baseline

## Decision gates

- After Stage 2: if RTSP confirmed, skip to pipeline build
- After Stage 3: if WebRTC path viable, audit prior art for reuse
- After Stage 5: if HDMI stable, accept as fallback regardless of protocol results
- Stop protocol research if no viable software path after Stages 1-4
