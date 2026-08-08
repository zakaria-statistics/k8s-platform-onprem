# ADR-0002 — Terraform provisions, Ansible configures

- Status: accepted · 2026-08-07

## Context

VMs must be created on Proxmox and then turned into cluster nodes. Both Terraform and
Ansible could each do most of it alone (Ansible has a Proxmox module; Terraform has
provisioners).

## Decision

Hard boundary: **Terraform owns machine existence** (clone rhel9-tpl, cloud-init:
IP/key/user, disks on `tank-vms`); **Ansible owns machine state** (subscription →
baseline → containerd → kubeadm init/join), reading its inventory from Terraform output.

## Consequences

- Rebuild-over-repair: `terraform apply` + one playbook = empty host → joined cluster;
  broken nodes get destroyed and recreated, never hand-fixed.
- Terraform state stays local to the Proxmox host in early phases (no remote backend
  yet); revisited when a second operator or CI applies appear.
- Each tool is exercised in its industry-standard role — the boundary itself is a
  common interview question.
