# ADR-0006 — GitFlow, phased delivery, incident track

- Status: accepted · 2026-08-08

## Context

Solo project, but its value depends on looking and operating like team-grade work:
reviewable history, protected releases, and operational evidence — not a pile of
commits on main.

## Decision

- **GitFlow, solo-adapted:** protected `main` (releases + `vN.0` tags), `dev` default,
  `feature/*` branches, PR-only into `main` with green checks; no reviewer requirement.
- **Phased delivery:** every phase gets `docs/phases/phase-N.md` reviewed *before* its
  first implementation PR; each phase is a working system and closes with a tag.
- **Incident track:** every phase ends with staged failure drills fixed for real and
  written up as postmortems in `docs/incidents/`.

## Consequences

- The git history itself demonstrates GitFlow — one of the target skills.
- Design-before-build produces the ADR/decision density interviews reward.
- Drills cost roughly a day per phase and produce the "tell me about an incident"
  answers; they are honestly framed as chaos drills on our own platform.
