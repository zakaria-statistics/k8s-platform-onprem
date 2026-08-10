# ADR-0007 — Terraform provider: bpg/proxmox

Status: accepted (2026-08-10)

## Context

Two Terraform providers exist for Proxmox: `telmate/proxmox` (the historical
default, widely referenced in tutorials) and `bpg/proxmox`. Phase 1 needs full
cloud-init control (static IPs, user + SSH key injection) and clone-from-template
with disk resize on Proxmox VE 9.

## Decision

Use **`bpg/proxmox`** (pinned `~> 0.111`).

- Actively maintained with frequent releases; Telmate has long gaps and
  open issues around PVE 8/9 API changes.
- First-class cloud-init support (`initialization` block: ip_config, dns,
  user_account) — no hand-rolled snippets needed for our static-IP nodes.
- Auth via API token entirely through `PROXMOX_VE_*` environment variables,
  keeping credentials out of the repo and the state clean.

## Consequences

- Provider schema evolves quickly; the `~> 0.111` pin plus the committed
  plan/apply discipline (CI runs fmt/validate only) keeps upgrades deliberate.
- Some advanced operations (snippet upload) would need SSH access configured in
  the provider — not needed in Phase 1; revisit if custom cloud-init snippets
  ever become necessary (they were the sllm-lab instance-id gotcha, so avoiding
  them is a feature, not a loss).
