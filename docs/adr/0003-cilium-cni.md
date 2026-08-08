# ADR-0003 — Cilium as CNI

- Status: accepted · 2026-08-07

## Context

kubeadm ships no CNI. Candidates: flannel (simplest), Calico (common default),
Cilium (eBPF, kube-proxy-less, Hubble observability).

## Decision

**Cilium**, kube-proxy-less, with Hubble enabled.

## Consequences

- eBPF datapath and NetworkPolicy enforcement give the deepest networking story of the
  three; Hubble makes traffic visible for the observability phase and incident drills.
- Kube-proxy-less mode means Service handling diverges from the kubeadm default —
  documented, since CKA material assumes kube-proxy.
- Risk: eBPF features vs the RHEL 9 kernel; validated in Phase 1 before committing —
  fallback is Cilium with kube-proxy, then Calico.
