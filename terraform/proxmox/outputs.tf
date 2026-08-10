output "nodes" {
  description = "Cluster nodes as created: name => vmid + address"
  value       = { for n, v in var.nodes : n => { vmid = v.vmid, ip = v.ip, role = v.role } }
}

output "api_endpoint" {
  description = "Kubernetes API endpoint (raw IP by design — see phase-1 decision 2)"
  value       = "https://${[for n, v in var.nodes : v.ip if v.role == "control_plane"][0]}:6443"
}
