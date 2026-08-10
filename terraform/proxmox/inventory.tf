# Terraform → Ansible handoff: render the inventory from the same node map
# that shaped the VMs. The file is gitignored — it is generated state.
locals {
  control_plane = { for n, v in var.nodes : n => v if v.role == "control_plane" }
  workers       = { for n, v in var.nodes : n => v if v.role == "worker" }

  inventory = {
    all = {
      vars = {
        ansible_user                 = var.ci_user
        ansible_ssh_private_key_file = "/root/.ssh/k8s-lab"
      }
      children = {
        control_plane = {
          hosts = { for n, v in local.control_plane : n => { ansible_host = v.ip } }
        }
        workers = {
          hosts = { for n, v in local.workers : n => { ansible_host = v.ip } }
        }
      }
    }
  }
}

resource "local_file" "ansible_inventory" {
  filename        = abspath("${path.module}/../../ansible/inventory/hosts.yaml")
  file_permission = "0644"
  content         = yamlencode(local.inventory)
}
