# Roadmap — phases, incidents, tags

Every phase starts with a design doc here (`phase-N.md`, reviewed before build), is a
working system on its own, ends with **staged incident drills + postmortems** in
[`docs/incidents/`](../incidents/), and closes with a git tag.

The narrative arc: we build and operate an on-prem platform (Phases 0–5). Then a
migration decision is made (Phase 6) — move to Azure AKS **and** separate the database
out of Kubernetes into a managed service. New repos and ADRs are born the day that
decision lands, exactly as they would in a real company.

| Phase | Deliverable | Incident drills | Tag |
|---|---|---|---|
| 0 · Bootstrap | 3 repos, docs system, day-0 CI gates, RHEL account | — | — |
| 1 · Ground | Terraform → 3 RHEL 9 VMs; Ansible → kubeadm + Cilium | etcd kill + snapshot restore · worker power-off under load | v1.0 |
| 2 · Edge & storage | MetalLB, ingress-nginx, cert-manager (CA), NFS SC | ingress cert expiry / broken renewal · MetalLB pool exhaustion | v2.0 |
| 3 · App + pipeline | Inference API + in-cluster Postgres via ArgoCD; gated CI green | bad deploy → `git revert` rollback · planted secret caught by gate · CVE blocks image | v3.0 |
| 4 · Stateful ops | Velero backup/restore drills for the DB | Postgres PVC full → outage → restore from backup | v4.0 |
| 5 · Observability + secrets | kube-prometheus-stack, Loki, OTel traces; Vault + ESO | latency bug found via traces · OOMKilled hunt via metrics | v5.0 |
| 6 · **Migration** | AKS + managed Postgres (Flexible Server, private endpoint); Velero moves k8s state, `pg_dump`/logical replication moves the DB; cutover + rollback | botched cutover rehearsal (wrong connection string) → rollback executed | v6.0 |
| 7 · Polish | READMEs, diagrams, demo script, cost teardown | — | — |

## Phase 6 — what gets born at the migration decision

- Repo `k8s-platform-azure`: Terraform for AKS, VNet + private endpoint + private DNS,
  Azure Database for PostgreSQL Flexible Server, Blob (Velero BackupStorageLocation).
- `k8s-gitops` gains `clusters/aks/` — ArgoCD on AKS points at the same repo; that *is*
  how config migrates.
- ADRs recorded at decision time: migrate-to-AKS, separate-DB-to-managed-Postgres
  (before/after trade-offs), Blob-as-BSL (S3 is an API, not AWS — real S3 waits for an
  EKS sequel), DB cutover method (`pg_dump`/restore vs logical replication).
- Secret story contrast: Vault on-prem vs managed identity / Entra auth in Azure.

**Azure cost guard:** AKS + Flexible Server exist only for Phase 6 — smallest SKUs,
`az aks stop` / `az postgres flexible-server stop` when idle, budget alert, scripted
`terraform destroy` ends every session.

## Interview mapping

Phases front-load interview value: after Phase 1 you have the CKA/RHCSA story; after
Phase 2 the networking/TLS/LB fundamentals story; after Phase 3 the GitOps + supply-chain
security story. Each drill answers a standard question ("how do you roll back?",
"tell me about an incident", "how did you move the database?") with something that
actually happened and can survive follow-up questions.

## Sequels (not this project)

- EKS + real S3 (AWS lane) · single-node OpenShift lab (justifies the OpenShift line) ·
  one pipeline mirrored in GitLab CI with a comparison writeup.
