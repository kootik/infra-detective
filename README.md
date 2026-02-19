<div align="center">

# 🔍 Infra Detective

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Skill Tier: Professional](https://img.shields.io/badge/Tier-Professional-blue.svg)](#architecture)
[![Audit Score: 4.6/5](https://img.shields.io/badge/Audit-4.6%2F5_(Grade_A)-brightgreen.svg)](#quality-audit)
[![Claude Compatible](https://img.shields.io/badge/Claude_Code-Compatible-blueviolet.svg)](https://docs.anthropic.com)

**Multi-agent incident investigation skill for Claude Code & claude.ai**

Parallel log analysis · Metrics correlation · Blameless postmortems

</div>

---

## What Is This?

**Infra Detective** is an AI skill that turns Claude into an infrastructure incident investigator. It spawns parallel agents to reconstruct timelines, correlate metrics, and audit changes — then synthesizes everything into structured RCA reports and blameless postmortems.

Built for **Kubernetes-native environments** with Prometheus/Grafana/OpenSearch observability stacks.

## How It Works

```
                    ┌──────────────────┐
                    │   Incident Data  │
                    │ logs · metrics · │
                    │ deploys · alerts │
                    └────────┬─────────┘
                             │
                    ┌────────▼─────────┐
                    │   Infra Detective │
                    │   (Orchestrator)  │
                    └──┬─────┬─────┬───┘
                       │     │     │        ← parallel agents
              ┌────────▼┐ ┌──▼───┐ ┌▼────────┐
              │Timeline ││Metrics││ Change   │
              │Recon    ││Correl.││ Auditor  │
              │(haiku)  ││(haiku)││ (haiku)  │
              └────┬────┘└──┬───┘ └──┬──────┘
                   │        │        │
                   └────────┼────────┘
                            │
                   ┌────────▼─────────┐
                   │   Synthesis      │
                   │   5-Whys · RCA   │
                   │   Postmortem     │
                   └──────────────────┘
```

## 4 Operational Modes

| Mode | When | Output |
|------|------|--------|
| **Triage** | Incident is active, need quick orientation | Severity card with blast radius and immediate actions |
| **Investigate** | Incident mitigated, need root cause | Investigation report with unified timeline, 5-Whys, cause classification |
| **Postmortem** | Investigation done, need stakeholder doc | Blameless postmortem (Google SRE / Atlassian / PagerDuty format) |
| **Pattern Analysis** | Multiple incidents, need systemic view | Cross-incident patterns with improvement roadmap |

## What's Inside

```
infra-detective/
├── SKILL.md                              # Main skill (274 lines, Professional tier)
└── references/
    ├── investigation-playbooks.md        # Layer-specific procedures + kubectl/PromQL commands
    └── postmortem-patterns.md            # 3 postmortem formats + blameless writing guide
```

### Investigation Playbooks

5-layer investigation framework with real commands:

| Layer | Scope | Tools |
|-------|-------|-------|
| L5: User-Facing | HTTP 5xx, latency SLO breaches | PromQL, ingress logs |
| L4: Application | OOM, crash loops, connection exhaustion | `kubectl logs`, `kubectl top`, resource metrics |
| L3: Platform | K8s scheduling, DNS, service mesh | CoreDNS, Istio, node conditions |
| L2: Infrastructure | Node failures, disk pressure, network | `journalctl`, PV/PVC status, CNI |
| L1: External | Cloud provider, third-party APIs, certs | Status pages, connectivity tests |

Includes a **cross-layer correlation matrix** — map symptom combinations to likely failure layers.

### Postmortem Templates

Three industry-standard formats ready to fill:

- **Google SRE** — full technical depth, Lessons Learned, error budget impact
- **Atlassian** — cross-functional, accessible to non-technical stakeholders
- **PagerDuty** — compact, action-oriented, fast turnaround

All include typed action items (Prevent / Detect / Mitigate / Process) with priority and owner assignment.

## Installation

### Claude Code

Drop the folder into your skills directory:

```bash
cp -r infra-detective/ .claude/skills/infra-detective/
```

### claude.ai (Projects)

Upload the `.skill` file from [Releases](../../releases) to your Claude project.

### Manual

Just tell Claude:

> "Use the infra-detective skill to investigate this incident: [paste logs/description]"

## Usage Examples

```
# Active incident — quick triage
"We're getting 5xx spikes on the payments service, started 10 min ago"

# Post-incident investigation
"Investigate yesterday's outage. Here are the logs: [paste/upload]"

# Postmortem generation
"Generate a Google SRE postmortem for INC-2847"

# Russian triggers work too
"Что упало в проде ночью? Вот логи из OpenSearch..."
```

## Architecture

Built following the [skill-architect-ultra](https://github.com/topics/claude-skills) methodology:

- **Tier**: Professional (200-400 lines body + 2-4 references)
- **Category**: Multi-Agent Coordinator + Domain Expert (hybrid)
- **Agent pattern**: Parallel Research (3 haiku agents → synthesis)
- **Failure handling**: Agent failures fall back to manual analysis
- **Bilingual triggers**: English (7 phrases) + Russian (4 phrases)

## Quality Audit

| Dimension | Score | Notes |
|-----------|-------|-------|
| Clarity | 5/5 | Concrete output templates, specific K8s commands |
| Coverage | 4/5 | 4 modes, agent failure handling, 5-layer playbooks |
| Consistency | 5/5 | Uniform terminology, templates, bilingual triggers |
| Testability | 4/5 | Clear output formats, verification via templates |
| Architecture | 5/5 | Perfect Professional tier fit, clean progressive disclosure |

**Overall: 4.60/5 — Grade A** (Production-ready)

## License

[MIT](LICENSE)
