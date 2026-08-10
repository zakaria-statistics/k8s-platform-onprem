variable "pve_node" {
  description = "Proxmox node name hosting the cluster VMs"
  type        = string
  default     = "pve"
}

variable "datastore" {
  description = "Proxmox datastore for VM disks and cloud-init drives"
  type        = string
  default     = "tank-vms"
}

variable "bridge" {
  description = "Linux bridge the node NICs attach to"
  type        = string
  default     = "vmbr0"
}

variable "template_vmid" {
  description = "VMID of the RHEL 9 cloud-init template (built by scripts/build-template.sh)"
  type        = number
  default     = 9100
}

variable "gateway" {
  description = "Default gateway for the node network"
  type        = string
  default     = "192.168.11.1"
}

variable "dns_server" {
  description = "DNS server handed to the nodes via cloud-init"
  type        = string
  default     = "192.168.11.1"
}

variable "ci_user" {
  description = "Cloud-init user created on every node"
  type        = string
  default     = "k8s"
}

variable "ssh_public_key_file" {
  description = "Path to the SSH public key installed for ci_user (private key never enters the repo)"
  type        = string
  default     = "/root/.ssh/k8s-lab.pub"
}

variable "nodes" {
  description = "Cluster nodes: name => shape + address (addresses per docs/architecture.md network plan)"
  type = map(object({
    vmid      = number
    role      = string # "control_plane" | "worker"
    vcpu      = number
    memory_mb = number
    disk_gb   = number
    ip        = string
  }))
  default = {
    "k8s-cp-01" = { vmid = 9101, role = "control_plane", vcpu = 4, memory_mb = 6144, disk_gb = 40, ip = "192.168.11.60" }
    "k8s-wk-01" = { vmid = 9102, role = "worker", vcpu = 6, memory_mb = 10240, disk_gb = 60, ip = "192.168.11.61" }
    "k8s-wk-02" = { vmid = 9103, role = "worker", vcpu = 6, memory_mb = 10240, disk_gb = 60, ip = "192.168.11.62" }
  }
}
