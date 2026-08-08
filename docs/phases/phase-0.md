# Phase 0 — Bootstrap

> Status: **in progress** · designed 2026-08-08 · rhythm: every phase gets a design doc
> here, reviewed, before its first implementation PR.

## Deliverable

Three public repos that enforce quality and security from commit #1, before any infra exists.

## Design

1. **Repos** (`zakaria-statistics`), split by lifecycle (ADR-0004):
   - `k8s-platform-onprem` — Terraform (Proxmox), Ansible, docs/ADRs/incidents (this repo)
   - `k8s-gitops` — ArgoCD desired state, `clusters/onprem/{bootstrap,platform,apps}`
   - `ai-inference-app` — FastAPI service, hardened image, app CI

   A fourth repo (`k8s-platform-azure`) is deliberately **not** created now — it is born
   at the Phase 6 migration decision, so the git timeline tells the story.
2. **GitFlow:** protected `main` (releases, `vN.0` tags), `dev` default working branch,
   `feature/*` branches, PR-only into `main` with green checks. Solo-adapted: no reviewer
   requirement, but no direct pushes to `main`.
3. **Day-0 CI gates, green on the empty skeleton:**
   - platform: gitleaks · terraform fmt/validate · tfsec · Checkov (terraform jobs
     activate once `terraform/` has `.tf` files)
   - gitops: gitleaks · kubeconform manifest validation (activates once manifests exist)
   - app: gitleaks · ruff · pytest (activate once `src/` has code)
   Rationale: the secret-scan gate is institutionalized *before* there is anything to leak.
4. **Docs system:** `docs/architecture.md` (master), `docs/adr/` (one record per
   decision), `docs/phases/` (roadmap + this rhythm), `docs/incidents/` (postmortems
   from the incident track).
5. **Conventions:** conventional commits (`feat:`/`fix:`/`docs:`/`chore:`), tag `vN.0`
   closes each phase.

## Exit criteria

- [ ] All three repos public with skeleton + docs + CI green
- [ ] `main` protected, `dev` default — on all three
- [x] Red Hat account created (user) — portal login confirmed 2026-08-08
- [ ] Router DHCP scope confirmed to exclude 192.168.11.60–79 (user)

## Out of scope

Any Terraform/Ansible content — that's Phase 1, which gets its own `phase-1.md` first.
The AI app's exact model/endpoint — decided in the app's Phase 3 design.
