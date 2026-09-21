# Eufy S4 Evidence Log

## Format

Each entry must include:
- Date
- Equipment firmware versions
- Route being tested
- Exact method (commands with placeholders, no real IPs/creds)
- Raw result (redacted)
- Confidence: confirmed / strong lead / hypothesis / rejected
- Next step

---

## Entries

### EV-001: NVR S4 (T8N00) has no native RTSP or ONVIF support

- **Date:** 2026-09-21
- **Equipment:** Eufy NVR S4 / NVR S4 Max (T8N00), PoE Bullet-PTZ Cam S4 (T8E00121)
- **Route:** Native RTSP / ONVIF
- **Method:** Web research — official Eufy product pages, community forums, open-source issue trackers
- **Result:** No evidence that the NVR S4 (T8N00) exposes RTSP or ONVIF endpoints. A feature request posted 2026-07-13 on the Eufy community forum explicitly asks for "Public API / ONVIF support for eufy NVR (T8N00 / S4)" and describes the NVR as having "no documented public API and no ONVIF compliance." The PoE cameras use an encrypted proprietary link to the NVR and do not expose usable RTSP/ONVIF endpoints themselves. The NAS/RTSP toggle in the Eufy app (Camera Settings > Storage > NAS) is documented for older standalone and HomeBase-connected cameras but no source confirms it is available for PoE Cam S4 models connected via an NVR S4.
- **Sources:**
  - https://community.eufy.com/t/feature-request-public-api-onvif-support-for-eufy-nvr-t8n00-s4/5808100
  - https://github.com/HallyAus/Eufy-Home-Assistant (README states cameras "do not expose usable RTSP/ONVIF endpoints themselves")
  - https://service.eufy.com/article-description/About-NAS-RTSP (general NAS/RTSP docs, no S4 NVR mention)
- **Confidence:** strong lead (toward rejection) — no confirmed RTSP/ONVIF; formal rejection requires physical device verification
- **Next step:** Stage 0/2 — check NVR UI and Eufy app on actual hardware for any RTSP/NAS/ONVIF toggle

---

### EV-002: Eufy NAS/RTSP feature on older models is event-only and auto-disables

- **Date:** 2026-09-21
- **Equipment:** General Eufy cameras (Indoor Cam, eufyCam 2C, HomeBase models)
- **Route:** Native RTSP (on models that support it)
- **Method:** Web research — Home Assistant community, Eufy support docs
- **Result:** Even on models that support NAS/RTSP, the stream auto-disables after a few minutes unless Continuous Recording is enabled. Users report needing to toggle RTSP off/on in the app to restart it. The RTSP function is labeled as "NAS (RTSP Stream)" and Eufy's docs state it "only works with NAS that supports the RTSP protocol," though community reports confirm it can be activated without a NAS. Battery-powered cameras only stream during events.
- **Sources:**
  - https://community.home-assistant.io/t/eufy-camera-rtsp-stream-is-disabled-after-a-few-minutes-my-findings/581001
  - https://community.home-assistant.io/t/rtsp-with-eufy-cams-not-working-very-long/726535
  - https://service.eufy.com/article-description/About-NAS-RTSP
- **Confidence:** confirmed (for older models); not applicable to S4 NVR until verified
- **Next step:** If S4 somehow exposes RTSP, test for the same auto-disable behavior

---

### EV-003: HallyAus/Eufy-Home-Assistant — LAN-direct WebRTC extraction for NVR S4

- **Date:** 2026-09-21
- **Equipment:** Eufy NVR S4 Max (T8N00), PoE cameras
- **Route:** Local WebRTC extraction via reverse-engineered NVR protocol
- **Method:** Web research — GitHub README, issues #5, #6, #8, #13, #16
- **Result:** This Home Assistant add-on reverse-engineers the NVR's WebRTC signaling protocol to extract LAN-direct video. Key architecture: headless email/password login with reversed ECDH/AES -> cloud-relayed signaling (cmd 9100 for camera discovery) -> local WebRTC session -> H.265 -> RTSP via go2rtc. The add-on container bundles Python + Node + ffmpeg + go2rtc.
  - **Critical limitation:** NVR allows only ONE active live stream at a time. The add-on serializes camera requests and only holds a session while something is watching.
  - **Authentication:** Requires the NVR owner/admin Eufy account (not shared/member). Member accounts get error -104.
  - **Firmware sensitivity:** Firmware 4.2.4.2 broke DTLS certificate parsing (Issue #16 — ASN.1 ExtraData error in aiortc/pyOpenSSL). Earlier firmware versions worked.
  - **Known issues:** Multiple users report cameras discovered but streams not viewable (Issues #5, #13). ICE/DTLS negotiation failures are common.
  - **Status:** Experimental. Active development but fragile.
- **Sources:**
  - https://github.com/HallyAus/Eufy-Home-Assistant
  - https://github.com/HallyAus/Eufy-Home-Assistant/issues/5
  - https://github.com/HallyAus/Eufy-Home-Assistant/issues/6
  - https://github.com/HallyAus/Eufy-Home-Assistant/issues/8
  - https://github.com/HallyAus/Eufy-Home-Assistant/issues/13
  - https://github.com/HallyAus/Eufy-Home-Assistant/issues/16
- **Confidence:** strong lead — demonstrated working on some firmware versions, but fragile and firmware-sensitive
- **Next step:** Clone repo, audit code for protocol details, test against actual hardware

---

### EV-004: eufy-security-client (bropat) — NVR S4 listed but streaming broken

- **Date:** 2026-09-21
- **Equipment:** Eufy NVR S4 Max (T8N00)
- **Route:** P2P streaming via eufy-security-client library
- **Method:** Web research — GitHub supported_devices.md, npm, issue #898, issue #1477 (fuatakgun/eufy_security)
- **Result:** The eufy-security-client library lists T8N00 (NVR S4 Max, type 300) in its supported devices with firmware 1.3.2.2, and eufyCam S4 (T8172) with firmware 1.0.6.5. However, the fuatakgun/eufy_security Home Assistant integration (which wraps eufy-security-client via eufy-security-ws) has Issue #1477 reporting that NVR S4 Max streams stay stuck in PREPARING state — cameras are discovered but livestreams never start, while the Eufy app and Alexa work fine. Additionally, Eufy is migrating to the "Eufy Mega" platform and has started removing access to legacy APIs this library was built on.
- **Sources:**
  - https://github.com/bropat/eufy-security-client/blob/master/docs/supported_devices.md
  - https://github.com/bropat/eufy-security-client/issues/898
  - https://github.com/fuatakgun/eufy_security/issues/1477
  - https://www.npmjs.com/package/eufy-security-client
- **Confidence:** hypothesis — device listed but streaming does not work; library may be obsoleted by Mega migration
- **Next step:** Monitor eufy-mega-client (keesmod) as potential successor

---

### EV-005: eufy-mega-client (keesmod) — NVR S4/PoE explicitly unsupported

- **Date:** 2026-09-21
- **Equipment:** Eufy NVR S4 (T8N00), PoE cameras (T8E00)
- **Route:** Mega platform client
- **Method:** Web research — GitHub issue #144, PRs #125, #132, #161
- **Result:** The eufy-mega-client explicitly documents PoE cameras behind NVR (T8N00/T8E00) as unsupported (Issue #144). The NVR transport requires "Mega signaling/WebRTC plus Eufy's WASM framing, for which no distributable, licence-clean implementation exists." The library supports HomeBase 3 cameras but explicitly rejects H3 ownership for NVR pairs. This is listed as "lowest priority of the open transport gaps." The library does support concurrent streams (1-4 per station) for supported devices.
- **Sources:**
  - https://github.com/keesmod/eufy-mega-client/issues/144
  - https://github.com/keesmod/eufy-mega-client/pull/125
  - https://github.com/keesmod/eufy-mega-client/releases/tag/v0.14.0
- **Confidence:** confirmed (not supported) — explicitly documented as unsupported with no near-term path
- **Next step:** None for this library unless WASM framing is independently implemented

---

### EV-006: go2rtc has no native Eufy source type

- **Date:** 2026-09-21
- **Equipment:** General Eufy cameras
- **Route:** go2rtc direct integration
- **Method:** Web research — go2rtc.org, GitHub issues #1145, #1453, related projects
- **Result:** go2rtc does not have a native Eufy source type. Eufy cameras are integrated indirectly: (a) via the eufy-security P2P streamer pushing raw H.264 to go2rtc's /api/stream endpoint, or (b) via bridge projects like ha-eufy-sdk-bridge that bundle go2rtc with an Eufy SDK. The HallyAus add-on also uses go2rtc as its RTSP/WebRTC transport layer after extracting the WebRTC stream from the NVR. Go2rtc version 1.9.7 broke Eufy camera compatibility (Issue #1453 — "mse: unsupported scheme").
- **Sources:**
  - https://go2rtc.org/
  - https://github.com/AlexxIT/go2rtc/issues/1453
  - https://github.com/AlexxIT/go2rtc/issues/1145
  - https://github.com/oischinger/eufyp2pstream
  - https://github.com/mega-yfue/ha-eufy-sdk-bridge
- **Confidence:** confirmed — go2rtc is a transport layer, not an Eufy protocol implementation
- **Next step:** go2rtc remains useful as the RTSP/WebRTC relay regardless of upstream extraction method

---

### EV-007: Eufy web portal (mysecurity.eufylife.com) supports live view

- **Date:** 2026-09-21
- **Equipment:** General Eufy cameras/NVRs
- **Route:** Browser live-view capture / WebRTC extraction
- **Method:** Web research — Eufy official docs, blog posts
- **Result:** The Eufy web portal at mysecurity.eufylife.com supports live view in browser (Chrome, Edge, Firefox on Windows 11 confirmed). Access requires: (1) enabling Web Portal Access in the Eufy app (Profile > Settings > Security > Web Portal Access), (2) setting a session duration, (3) generating a Safety PIN, (4) entering the PIN on the web portal. Sessions last up to 24 hours. The portal offers live view, events, two-way audio, and recording playback. The streaming protocol used by the portal is not publicly documented, but it is likely WebRTC given the HallyAus project's findings.
- **Sources:**
  - https://mysecurity.eufylife.com/
  - https://www.eufy.com/blogs/security-camera/view-eufy-camera-on-pc
  - https://www.eufy.com/blogs/security-camera/how-to-remotely-view-security-cameras-using-the-internet
  - https://mysecurity.eufylife.com/ext-web/live-view-access
- **Confidence:** confirmed (portal exists and supports live view); hypothesis (WebRTC protocol, applicable to S4 NVR)
- **Next step:** Stage 3 — open DevTools during live view to capture signaling, identify WebRTC/WebSocket/HLS, classify LAN vs cloud path

---

### EV-008: PoE Bullet-PTZ Cam S4 model number is T8E00121

- **Date:** 2026-09-21
- **Equipment:** Eufy PoE Bullet-PTZ Cam S4
- **Route:** Equipment identification
- **Method:** Web research — Best Buy, B&H Photo, Eufy product pages
- **Result:** The PoE Bullet-PTZ Cam S4 model number is T8E00121 (also referenced as T8E00). It features a triple-lens design: upper 4K wide-angle (122 deg FOV, 2.8mm, F1.6) and lower 2K PTZ (360 deg pan, 8x hybrid zoom with 3x optical / 5x digital, 2.8mm/8mm). Combined 16MP resolution. PoE powered. No RTSP or ONVIF mentioned in any product specification page.
- **Sources:**
  - https://www.eufy.com/products/t8e00121
  - https://www.bestbuy.com/product/eufy-poe-bulletptz-cam-s4-4k-triple-lens-122-fov-360-pan-tilt-8-zoom-ai-tracking-strobe-color-night-24-7/JJ858R8L6W
  - https://www.bhphotovideo.com/c/product/1910222-REG/eufy_security_t8e00121_s4_4k_uhd_add_on.html
- **Confidence:** confirmed (model identification)
- **Next step:** Record exact firmware version from physical device
