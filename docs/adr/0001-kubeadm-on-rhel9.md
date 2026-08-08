# ADR-0001 — kubeadm on RHEL 9, not OpenShift or a distro

- Status: accepted · 2026-08-07

## Context

The platform needs a Kubernetes cluster on Proxmox VMs. Options: OpenShift/OKD,
lightweight distros (k3s, RKE2), or vanilla kubeadm. The builder's goals include CKA
and RHCSA readiness, and the host has 62 GB RAM shared with other labs.

## Decision

Vanilla Kubernetes via **kubeadm on RHEL 9** (free developer subscription; fallback
Rocky 9 with identical Ansible roles). Firewalld and SELinux stay enabled.

## Consequences

- Every control-plane component is installed and operated by hand — the CKA muscle;
  RHEL admin (subscription-manager, firewalld, SELinux) is the RHCSA muscle.
- No OpenShift conveniences (operators, routes, oc). OpenShift stays a separate,
  later lab (single-node SNO) so the resume line is still honest.
- k3s/RKE2 would be faster to stand up but hide exactly the internals interviews ask about.
