# Auth is supplied entirely via environment variables, never in files:
#   PROXMOX_VE_ENDPOINT, PROXMOX_VE_API_TOKEN, PROXMOX_VE_INSECURE
# (sourced from /root/.k8s-lab.env on the host — outside the repo)
provider "proxmox" {}
