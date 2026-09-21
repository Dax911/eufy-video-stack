# Eufy S4 Ingest Recommendation

*Initial recommendation based on Stage 4: open-source prior art audit*
*Date: 2026-09-21*
*Status: PROVISIONAL — no physical device testing yet*

## Executive summary

The Eufy NVR S4 (T8N00) and PoE Cam S4 (T8E00) operate within a closed,
proprietary ecosystem. There is no confirmed RTSP, ONVIF, or standard local
streaming interface. The only demonstrated software extraction path is the
HallyAus/Eufy-Home-Assistant project, which reverse-engineers the NVR's
WebRTC signaling protocol but is experimental, firmware-fragile, and limited
to one concurrent stream. HDMI capture remains the most reliable fallback.

## 1. Primary route: HDMI capture (pending physical validation)

**Why:** Zero dependency on reverse-engineered protocols, firmware stability,
or Eufy cloud signaling. If the NVR outputs clean 1080p/4K HDMI with
acceptable overlays in full-screen single-camera mode, this is the most
reliable 24/7 path.

**Requirements to validate (Stage 5):**
- NVR HDMI output resolution and refresh rate
- Per-camera full-screen mode availability
- Presence/absence of UI overlays, timestamps, status bars
- HDMI capture card compatibility (UVC class)
- Latency measurement (HDMI -> capture -> OBS)
- 1-hour stability test
- Wide lens vs PTZ lens selection via HDMI output

**Risks:**
- Cannot independently select wide and PTZ feeds simultaneously (likely)
- NVR UI overlays may be burned into the capture
- Single camera at a time unless NVR supports multi-view HDMI output
- No programmatic camera switching

**Score: 3-4/5 quality, 3-4/5 latency, 4-5/5 stability, 5/5 cloud-free**

## 2. Fallback route: HallyAus WebRTC extraction

**Why:** Only demonstrated software path for LAN-direct video from NVR S4.
If it works on our firmware version, it provides H.265 video via go2rtc as
standard RTSP, which integrates cleanly with MediaMTX/OBS/FFmpeg.

**Requirements to validate:**
- Record exact NVR firmware version (critical — firmware 4.2.4.2 broke DTLS)
- Install Home Assistant OS or test add-on in Docker
- Test with NVR owner account (member accounts fail with -104)
- Verify camera discovery (cmd 9100)
- Verify stream establishment (WebRTC/DTLS/ICE)
- Measure stream duration before timeout
- Test single-stream limitation impact on our use case
- Test recovery after NVR reboot

**Risks:**
- Firmware updates can break DTLS/WebRTC negotiation at any time
- Single concurrent stream — cannot view two cameras or two lenses simultaneously
- Requires initial cloud signaling (Eufy account login) even for LAN video
- Experimental project with small maintainer base
- H.265 decode required (not all consumers support it)

**Score: 4-5/5 quality, 4-5/5 latency, 2-3/5 stability, 2/5 cloud-free**

## 3. Temporary bring-up route: Browser window/screen capture

**Why:** mysecurity.eufylife.com is confirmed to support live view in browser.
This can be captured via OBS Window Capture immediately, with no reverse
engineering or special hardware, as a day-one validation path.

**Requirements to validate:**
- Enable Web Portal Access in Eufy app
- Generate Safety PIN
- Open live view in Chrome/Firefox
- Capture via OBS Window Capture or Browser Source
- Measure quality degradation, latency, session duration
- Test session renewal (24hr max)

**Risks:**
- Requires active Eufy cloud session with PIN renewal
- Quality limited by browser rendering and window capture
- Not suitable for 24/7 recording
- Session timeout after 24 hours maximum
- Two-step auth (app + PIN) makes automation difficult

**Score: 3/5 quality, 2-3/5 latency, 2/5 stability, 1/5 cloud-free**

## 4. Routes not worth pursuing

| Route | Reason |
|-------|--------|
| Native RTSP from NVR/camera | No evidence it exists on S4. Community feature request (2026-07) confirms absence. Will formally reject after Stage 0/2 device inspection. |
| Native ONVIF from NVR/camera | Same as RTSP — no evidence, explicit feature request confirms absence. |
| bropat/eufy-security-client | Streams stuck in PREPARING on T8N00 (Issue #1477). Legacy API being removed by Eufy Mega migration. |
| fuatakgun/eufy_security HA integration | Wraps eufy-security-client; same PREPARING issue on S4. |
| keesmod/eufy-mega-client | T8N00/T8E00 explicitly unsupported (Issue #144). NVR is "lowest priority" transport gap. Requires WASM framing with no licence-clean implementation. |
| go2rtc native Eufy source | Does not exist. go2rtc is a transport layer, not a protocol implementation. |

## 5. Staged experiment plan

| Stage | Task | Effort | Depends on |
|-------|------|--------|------------|
| 0 | Lab inventory: firmware versions, topology, IP assignments | 1 hour | Physical access |
| 1 | Port scan NVR + camera IPs | 30 min | Stage 0 |
| 2 | Check NVR UI and Eufy app for RTSP/ONVIF/NAS settings | 30 min | Stage 0 |
| 3a | Browser DevTools inspection during web portal live view | 1-2 hours | Stage 0 |
| 3b | Workstation traffic capture during live view (Wireshark) | 1-2 hours | Stage 0 |
| 4-val | Clone and test HallyAus add-on against actual hardware | 2-4 hours | Stage 0, HA instance |
| 5 | HDMI capture baseline test | 1-2 hours | Stage 0, capture card |

**Total estimated effort for physical validation: 6-12 hours**

## 6. Exact next experiment

**Stage 0: Lab Inventory** — This is the gate for everything else.

1. Record NVR model number, hardware revision, and firmware version
2. Record PoE Cam S4 model number and firmware version
3. Document physical topology (camera -> NVR PoE port or camera -> switch -> NVR)
4. Assign DHCP reservations for NVR and camera (if camera gets its own IP)
5. Confirm live view works in mobile app
6. Check NVR settings menu for any RTSP/ONVIF/NAS/third-party options
7. Check HDMI output: resolution, per-camera full-screen, overlays

**Critical finding to capture:** The exact firmware version of the NVR. This
determines whether HallyAus is viable (firmware 4.2.4.2 is known to break it).

## 7. Stop conditions

| Route | Stop if... |
|-------|-----------|
| RTSP/ONVIF | No setting exists in NVR UI or Eufy app AND port scan confirms 554/3702 closed. Formally reject. |
| HallyAus WebRTC | Firmware is 4.2.4.2+ and DTLS fails, OR stream never establishes after 2 hours of debugging. Deprioritize to "monitor only." |
| Browser capture | Session cannot sustain 30 minutes, OR quality is unacceptable for production use. Accept as validation-only. |
| HDMI capture | Delivers stable 1080p+ with acceptable overlays and < 500ms latency. Accept as production baseline. |
| All software routes | If no software route produces a stable 30-minute stream after Stages 1-4, commit to HDMI capture as primary and stop protocol research. |

## Key risk: single-stream limitation

The NVR S4 appears to allow only one active live stream at a time (per
HallyAus documentation). This is a fundamental constraint for any software
extraction path. If we need simultaneous wide + PTZ feeds, or simultaneous
OBS preview + independent recording from the source, a single-stream
protocol path cannot satisfy both. HDMI capture with a splitter, or
accepting the MediaMTX fan-out architecture (one pull, multiple consumers),
may be required.

The MediaMTX architecture in CLAUDE.md (Camera/NVR -> MediaMTX -> {OBS, FFmpeg})
is specifically designed for this scenario: one upstream pull, fanned out to
multiple consumers. This is compatible with the single-stream limitation as
long as MediaMTX is the only client pulling from the NVR.

## Open questions for physical testing

1. Does the NVR assign the PoE camera its own LAN IP, or is the camera only
   reachable through the NVR?
2. Does the camera expose any services directly (HTTP, RTSP, etc.) if it has
   a LAN IP?
3. What is the exact NVR firmware version? (Determines HallyAus viability)
4. Does the NVR HDMI output support per-camera full-screen without UI overlays?
5. Can the wide and PTZ lenses be independently selected in the web portal?
6. What codec/resolution does the web portal use for live view?
