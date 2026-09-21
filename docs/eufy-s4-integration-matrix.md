# Eufy S4 Integration Matrix

*Updated: 2026-09-21 — Stage 4 (open-source prior art audit)*

## Route Scoring (1-5, higher = better)

| Route | Quality | Latency | 24/7 | Wide+PTZ | Cloud-free | Complexity | Status |
|-------|---------|---------|------|----------|------------|------------|--------|
| NVR/Camera RTSP | 5 | 5 | 5 | ? | 5 | 1 | **likely unavailable** |
| ONVIF media profiles | 5 | 5 | 5 | ? | 5 | 2 | **likely unavailable** |
| Local WebRTC extraction (HallyAus) | 4-5 | 4-5 | 2-3 | ? | 2 | 5 | **strong lead, fragile** |
| Browser live-view capture | 3-4 | 2-3 | 2-3 | ? | 1 | 2 | **feasible temp** |
| NVR HDMI -> UVC capture | 3-5 | 3-4 | 4-5 | depends | 5 | 2 | **strong fallback** |
| NVR export/download | 5 | N/A | 4 | depends | 1-3 | 2 | archival only |
| Physical NVR storage | ? | N/A | 1-3 | ? | 5 | 5 | low priority |

### Status definitions

- **likely unavailable**: No evidence exists that the S4 NVR/PoE cameras expose this; community feature requests confirm absence. Requires physical verification to formally reject.
- **strong lead, fragile**: Working code exists (HallyAus) but firmware-sensitive, single-stream limit, experimental, and multiple open issues with stream failures.
- **feasible temp**: Eufy web portal confirmed; protocol inspection needed.
- **strong fallback**: No dependency on protocol reverse engineering; depends only on HDMI output quality.

### Confidence changes from Stage 4 research

| Route | Previous status | New status | Reason |
|-------|----------------|------------|--------|
| NVR/Camera RTSP | unconfirmed | likely unavailable | Eufy community feature request (2026-07) confirms no RTSP/ONVIF on T8N00; HallyAus README states PoE cameras have no usable RTSP endpoints |
| ONVIF media profiles | unconfirmed | likely unavailable | Same evidence as RTSP; explicit feature request for ONVIF on T8N00 |
| Local WebRTC extraction | strong lead | strong lead, fragile | HallyAus demonstrates it works but: single stream limit, firmware breaks (4.2.4.2 DTLS issue), requires owner account, many users report discovery-without-streaming |
| Browser live-view capture | feasible temp | feasible temp (confirmed portal exists) | mysecurity.eufylife.com confirmed; requires PIN auth, 24hr session max |
| NVR HDMI -> UVC capture | strong fallback | strong fallback (unchanged, needs physical test) | No new information from web research |

## Open-Source Project Assessment

| Project | S4/NVR support | Protocol | Streaming works? | Maintenance | Risk |
|---------|---------------|----------|-------------------|-------------|------|
| HallyAus/Eufy-Home-Assistant | T8N00 targeted | WebRTC (reversed) | Partial — firmware-dependent | Active, experimental | Firmware updates break it |
| bropat/eufy-security-client | T8N00 listed | P2P (legacy API) | No — stuck in PREPARING | Threatened by Mega migration | API removal |
| fuatakgun/eufy_security (HA) | T8N00 via eufy-security-client | P2P | No — Issue #1477 | Low activity | Dead end for S4 |
| keesmod/eufy-mega-client | T8N00 explicitly unsupported | Would need Mega WebRTC + WASM | No | Active but NVR is lowest priority | No near-term path |
| go2rtc (AlexxIT) | No native Eufy source | N/A (transport layer) | N/A | Active | Useful as relay, not as extractor |
| ha-eufy-sdk-bridge | Unknown for S4 | P2P via SDK | Unknown | Low activity | Likely same issues as eufy-security-client |

## Evidence Log

| Date | Route | Test | Result | Confidence | Evidence |
|------|-------|------|--------|------------|----------|
| 2026-09-21 | RTSP/ONVIF | Web research | No S4 support found; feature request confirms absence | strong lead (rejection) | EV-001 |
| 2026-09-21 | NAS/RTSP (older models) | Web research | Works but auto-disables; not confirmed for S4 | confirmed (other models) | EV-002 |
| 2026-09-21 | WebRTC extraction | HallyAus audit | Partial success, firmware-fragile, 1-stream limit | strong lead | EV-003 |
| 2026-09-21 | eufy-security-client | GitHub research | T8N00 listed but streams stuck PREPARING | hypothesis | EV-004 |
| 2026-09-21 | eufy-mega-client | GitHub research | T8N00 explicitly unsupported | confirmed (not supported) | EV-005 |
| 2026-09-21 | go2rtc native | GitHub research | No native Eufy source type | confirmed | EV-006 |
| 2026-09-21 | Web portal live view | Web research | Portal confirmed at mysecurity.eufylife.com | confirmed (exists) | EV-007 |
| 2026-09-21 | Equipment ID | Web research | PoE Cam S4 = T8E00121, NVR S4 = T8N00 | confirmed | EV-008 |

*Physical device testing required for all routes. No route is formally confirmed or rejected until tested on actual hardware.*
