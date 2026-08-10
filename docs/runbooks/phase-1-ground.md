# Runbook — Phase 1 build (operator-driven)

You run every state-changing step by hand — including `terraform plan` — Claude
prepares configs and verifies. Each step says what it does, the exact command,
and how to check it worked. All commands run on the pve host as root unless noted.

## Current position (2026-08-10)

- [x] Template **9100 `rhel9-tpl`** built from the qcow2 (step 1 — done, ran once)
- [x] Terraform code written and validated — no plan/apply run yet
- [ ] **Step 2 is next: you plan, review, apply**
- [ ] Ansible roles not yet written (Claude writes them; you run the playbook)

## Step 1 — Build the template (done · idempotent)

```bash
/root/work/k8s-platform-onprem/terraform/proxmox/scripts/build-template.sh
```

Creates template VM 9100 from `/tank/iso/rhel-9.8-x86_64-kvm.qcow2` (checksum-verified).
Safe to re-run: exits immediately if 9100 exists.
**Verify:** `qm config 9100 | grep template:` → `template: 1`.

## Step 2 — Create the node VMs (Terraform)

```bash
cd /root/work/k8s-platform-onprem/terraform/proxmox
source /root/.k8s-lab.env          # loads PROXMOX_VE_* auth (root-only file, outside repo)
terraform plan -out=phase1.tfplan  # READ the plan output before going further
terraform apply phase1.tfplan
```

The plan must show **4 to add, 0 to change, 0 to destroy**: three
`proxmox_virtual_environment_vm.node` + one `local_file.ansible_inventory`.
Anything else → stop and investigate.

Creates 9101 `k8s-cp-01` (.60, 4c/6G/40G), 9102 `k8s-wk-01` (.61, 6c/10G/60G),
9103 `k8s-wk-02` (.62, 6c/10G/60G) as full clones of 9100, and renders
`ansible/inventory/hosts.yaml`. Template 9100 and the source qcow2 are read-only
throughout. Takes ~1–3 min.

**Verify:**

```bash
qm list | grep 910                          # three VMs, status running
for ip in 60 61 62; do ssh -i /root/.ssh/k8s-lab -o StrictHostKeyChecking=accept-new \
  k8s@192.168.11.$ip hostname; done          # answers: k8s-cp-01 / k8s-wk-01 / k8s-wk-02
```

First boot needs ~1 min for cloud-init before SSH answers.

## Step 3 — Red Hat credentials vault (you only — Claude never sees them)

Needed before the playbook: nodes must register to get RHEL repos.

```bash
cd /root/work/k8s-platform-onprem/ansible
ansible-vault create group_vars/all/vault.yaml
```

Pick a vault password (remember it), then in the editor put:

```yaml
vault_rhsm_username: "<your Red Hat login>"
vault_rhsm_password: "<your Red Hat password>"
```

The file is committed encrypted; the password never leaves your head.

## Step 4 — Converge the cluster (Ansible — after Claude writes the roles)

```bash
cd /root/work/k8s-platform-onprem/ansible
ansible-playbook -i inventory/hosts.yaml site.yaml --ask-vault-pass
```

Runs the full chain: register → base hardening → containerd → k8s v1.35 packages →
kubeadm init (.60) → join workers → Cilium.
**Verify:** `kubectl get nodes` on the cp — three nodes `Ready`.

## Step 5 — Validation gate + smoke test

```bash
cilium status --wait
cilium connectivity test
```

Then the smoke test (nginx ×2, ClusterIP from a debug pod, default-deny
NetworkPolicy blocks, remove, restored) — exact manifests provided at that step.

## Step 6 — Drills (gate the v1.0 tag)

1. etcd snapshot → destroy etcd data → restore → state survives.
2. Hard power-off a worker under load → watch eviction/rescheduling.

Each produces a postmortem in `docs/incidents/`. Commands provided at drill time.

## Rebuild / rollback (any time)

```bash
cd /root/work/k8s-platform-onprem/terraform/proxmox
source /root/.k8s-lab.env
terraform destroy        # removes ONLY the 3 node VMs — template + qcow2 untouched
```

Then repeat from step 2. Full reset: also `qm destroy 9100` and rerun step 1.
