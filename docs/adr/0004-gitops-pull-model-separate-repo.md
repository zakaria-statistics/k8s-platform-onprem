# ADR-0004 — GitOps pull model, desired state in its own repo

- Status: accepted · 2026-08-08

## Context

Something must deploy workloads and platform addons to the cluster. Push (CI runs
kubectl/helm against the cluster) requires cluster credentials in CI and a network
path in; GitHub-hosted runners have no route to the LAN. Repo layout question: desired
state inside the platform repo, or separate?

## Decision

**ArgoCD app-of-apps, pull model** — the cluster pulls its desired state; nothing
outside pushes in. Desired state lives in a **separate repo (`k8s-gitops`)** with a
`clusters/<name>/` layout, because infra code, desired state, and app code have
different lifecycles and change rates.

## Consequences

- No cluster credentials ever leave the cluster; the LAN constraint dissolves.
- Rollback = `git revert` (drilled in Phase 3's incident).
- A second cluster is just a second folder pointed at by its own ArgoCD — which is
  exactly the mechanism a future migration would use.
- Cost: three repos to maintain instead of two; CI is duplicated per repo.
