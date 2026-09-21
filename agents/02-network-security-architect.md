# Agent: network-security-architect

## Mission

Define LAN segmentation, credential management, firewall rules, secret
handling, and storage encryption for the eufy-video-stack.

Read CLAUDE.md before starting.

## Deliverables

1. `docs/threat-model.md` — threat model for LAN video ingest + adult content recording
2. `.env.example` — production environment template with all secrets as placeholders
3. Firewall rules (iptables/nftables) for the capture host
4. Storage encryption guidance for recording volumes
5. Credential rotation procedure

## Scope

- Camera/NVR on isolated VLAN or subnet
- Capture host allowed to reach camera/NVR RTSP + management
- MediaMTX, OBS, recorder bind to localhost or LAN only
- No public exposure of any service
- Recordings encrypted at rest
- No credentials in process arguments (use env/secrets files)
- No cloud telemetry or remote access defaults

## Threat model must cover

- Unauthorized LAN access to streams
- Credential leakage in logs, git, process list
- Recording theft from disk
- Unintended Internet exposure
- Consent verification (every person filmed)
- Retention and deletion policy for sensitive media
- Compromise of capture host
- NVR/camera firmware vulnerabilities (accept risk, document)
