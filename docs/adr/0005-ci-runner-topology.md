# ADR-0005 — CI runner topology: hosted runners check, the host applies

- Status: accepted · 2026-08-07

## Context

CI needs to run app builds, static IaC checks, and eventually `terraform apply` /
`ansible-playbook`. GitHub-hosted runners cannot reach the 192.168.11.0/24 LAN, and
giving cloud runners Proxmox/SSH credentials would contradict the security story.

## Decision

- **GitHub-hosted runners:** everything that needs only GitHub + registries — app CI
  (lint/test/build/Trivy/push), platform static gates (fmt/validate, tfsec, Checkov,
  gitleaks), gitops manifest validation.
- **Proxmox host, by hand:** `terraform apply` and `ansible-playbook` — the only place
  with LAN and token access.
- **In-cluster ArgoCD:** all deploys (see ADR-0004).

## Consequences

- No infrastructure credentials stored in GitHub.
- Applies are manual in early phases — acceptable for a solo operator; deferred
  upgrade: self-hosted runner in an LXC for applies.
- The topology itself is a talking point: what runs where and why.
