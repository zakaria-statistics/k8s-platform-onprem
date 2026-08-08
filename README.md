# k8s-platform-onprem

Infrastructure for an on-prem Kubernetes platform: a **RHEL 9 kubeadm cluster on
Proxmox**, provisioned by Terraform and configured by Ansible, carrying an AI inference
service behind a security-gated pipeline — deployed exclusively via GitOps, and
failure-tested with staged incident drills.

📐 **[Architecture](docs/architecture.md)** · 📋 **[Decisions (ADRs)](docs/adr)** ·
🗂 **[Roadmap & phase designs](docs/phases)** · 🔥 **[Incident postmortems](docs/incidents)**

## Layout

```
terraform/   proxmox/ — RHEL 9 VMs from a cloud-init template
ansible/     inventory from terraform output · roles: rhel-base → containerd → kubeadm
docs/        architecture · ADRs · phase designs · incident postmortems
```

## Delivery

Built in reviewed phases, each ending in incident drills and a tag — see the
[roadmap](docs/phases/roadmap.md). Current: **Phase 0 — bootstrap**.

## Companion repos

- [`k8s-gitops`](https://github.com/zakaria-statistics/k8s-gitops) — ArgoCD desired
  state; the only path anything takes into the cluster.
- [`ai-inference-app`](https://github.com/zakaria-statistics/ai-inference-app) — the
  workload: FastAPI inference service, hardened UBI9 image, gated CI.
