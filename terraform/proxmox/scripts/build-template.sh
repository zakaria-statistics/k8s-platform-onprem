#!/usr/bin/env bash
# Build the RHEL 9 cloud-init template (VMID 9100) from the Red Hat KVM guest image.
# Idempotent: exits cleanly if the template already exists. Run on the Proxmox host.
set -euo pipefail

VMID=9100
NAME=rhel9-tpl
STORAGE=tank-vms
BRIDGE=vmbr0
IMAGE=/tank/iso/rhel-9.8-x86_64-kvm.qcow2
SHA256_EXPECTED=b99091f1b4489111004d449398d9cc6aa024cb48b02c72fa99e6ca1fc48a7e4e

if qm status "$VMID" >/dev/null 2>&1; then
  echo "VM $VMID already exists — nothing to do."
  exit 0
fi

[ -f "$IMAGE" ] || { echo "image not found: $IMAGE" >&2; exit 1; }
echo "$SHA256_EXPECTED  $IMAGE" | sha256sum --check --quiet \
  || { echo "checksum mismatch on $IMAGE" >&2; exit 1; }

qm create "$VMID" \
  --name "$NAME" \
  --ostype l26 \
  --machine q35 \
  --cpu host \
  --cores 2 \
  --memory 2048 \
  --net0 "virtio,bridge=$BRIDGE" \
  --scsihw virtio-scsi-single \
  --serial0 socket \
  --vga serial0 \
  --agent enabled=1

qm set "$VMID" --scsi0 "$STORAGE:0,import-from=$IMAGE,discard=on,ssd=1"
qm set "$VMID" --ide2 "$STORAGE:cloudinit"
qm set "$VMID" --boot order=scsi0
qm template "$VMID"

echo "template $NAME ($VMID) ready on $STORAGE"
