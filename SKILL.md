---
name: infra-detective
description: >-
  Infrastructure incident investigator and postmortem generator for DevOps/SRE teams.
  Uses multi-agent orchestration to parallelize log analysis, metrics correlation,
  and timeline reconstruction. Generates structured incident reports and blameless postmortems.
  Use when investigating production incidents, analyzing outage timelines, correlating
  logs with metrics, generating postmortems, or performing chaos engineering reviews.
  Do NOT use for: code review (use refactor), security scanning (use security audit tools),
  general monitoring setup (use docs or runbooks directly).
  Triggers on "investigate incident", "what happened in prod", "outage analysis",
  "postmortem", "root cause analysis", "RCA", "incident timeline",
  "расследовать инцидент", "постмортем", "анализ аварии", "что упало в проде",
  or explicit /infra-detective command.
---

# Infra Detective

Infrastructure incident investigator that combines parallel log analysis, metrics correlation, and timeline reconstruction into actionable incident reports and blameless postmortems. Designed for Kubernetes-native environments with Prometheus/Grafana/OpenSearch observability stacks.

## Context

For investigation playbooks: `references/investigation-playbooks.md`
For postmortem template and SRE patterns: `references/postmortem-patterns.md`

## Core Expertise

### 1. Incident Investigation
- Timeline reconstruction from heterogeneous sources (logs, metrics, events, git history)
- Blast radius assessment across services, pods, nodes, and availability zones
- Correlation of deployment events with degradation signals

### 2. Root Cause Analysis
- 5-Whys structured decomposition with evidence linking
- Fault tree construction (AND/OR gates with probability)
- Distinguishing proximate cause vs. contributing factors vs. systemic weakness

### 3. Postmortem Generation
- Blameless postmortem documents following Google SRE / Atlassian / PagerDuty formats
- Action item extraction with owner assignment and priority
- Pattern detection across historical incidents

## Terminology

| Term | Definition | Avoid |
|------|-----------|-------|
| Blast radius | Set of systems/users affected by the incident | "damage", "impact zone" |
| Contributing factor | Condition that increased likelihood or severity | "secondary cause" |
| Detection gap | Time between incident start and first alert | "alert lag" |
| MTTD | Mean Time to Detect — incident start to first alert | Confusing with MTTR |
| MTTR | Mean Time to Recover — detection to full recovery | Confusing with MTTD |
| Proximate cause | Direct trigger that initiated the failure | "root cause" (when it's not) |
| Systemic weakness | Organizational/process gap enabling the incident | "blame", "fault" |
| Toil | Repetitive manual operational work that should be automated | "busywork" |

## Workflow

### Mode 1: Triage — Rapid Initial Assessment

**When**: Incident is active or just happened. Need quick orientation.

**Step 1**: Collect incident signal
- User provides: error messages, alert screenshots, Grafana dashboard links, log snippets, or verbal description
- If URL provided, fetch and parse the content
- If logs provided, extract timestamps, error codes, and affected services

**Step 2**: Classify severity and blast radius
- Map affected components to infrastructure layers:
  ```
  Layer 5: User-facing (HTTP 5xx, latency SLO breach)
  Layer 4: Application (OOM, crash loops, connection pool exhaustion)
  Layer 3: Platform (K8s scheduling, DNS, service mesh)
  Layer 2: Infrastructure (node failure, disk pressure, network partition)
  Layer 1: External (cloud provider, third-party API, DNS root)
  ```
- Estimate blast radius: single pod → service → namespace → cluster → multi-cluster

**Step 3**: Generate triage card
- Use Triage Output format below
- Include immediate recommended actions

**Output**: Use Triage Card format.

---

### Mode 2: Investigate — Deep Multi-Agent Analysis

**When**: Incident is mitigated. Need thorough root cause analysis.

**Step 1**: Gather all evidence
- Collect: logs, metrics data, deployment history, config changes, alert timelines
- User provides files, URLs, or pastes content directly

**Step 2**: Launch parallel investigation agents (all in ONE message)

**Agent A** — Timeline Reconstructor (Explore, haiku)
"Analyze the provided logs and events. Extract every timestamped event. Sort chronologically. Identify: first error signal, escalation points, mitigation actions, recovery confirmation. Return as markdown timeline table with columns: Time | Source | Event | Severity."

**Agent B** — Metrics Correlator (Explore, haiku)
"Analyze the provided metrics data and dashboard information. Identify: anomaly onset time, correlated metric changes (CPU, memory, network, disk, request rate, error rate, latency), any leading indicators that preceded the incident. Return as structured findings with metric name, normal baseline, anomaly value, and timestamp."

**Agent C** — Change Auditor (Explore, haiku)
"Analyze deployment history, git logs, config changes, and infrastructure changes provided. Identify: all changes within 72h before incident, correlation between changes and incident timeline, any rollback events. Return as change audit table: Time | Type | Description | Author | Correlation (High/Med/Low)."

**Failure handling**: If any agent fails, perform that analysis manually using the provided data. Note which analysis was degraded in the report.

**Step 3**: Synthesize agent results
- Merge timelines into unified incident timeline
- Cross-reference changes with anomaly onset
- Identify the most likely causal chain

**Step 4**: Perform 5-Whys analysis
- Start from the observable symptom
- Each "Why" must link to evidence from the investigation
- Stop when you reach an actionable systemic issue
- Distinguish: proximate cause, contributing factors, systemic weaknesses

**Step 5**: Generate investigation report
- Use Investigation Report format below

**Output**: Use Investigation Report format.

---

### Mode 3: Postmortem — Blameless Postmortem Document

**When**: Investigation complete. Need formal postmortem for stakeholders.

**Step 1**: Load postmortem template
- Read `references/postmortem-patterns.md` for format selection
- If user specifies format (Google SRE / Atlassian / PagerDuty), use that
- Default: Google SRE format

**Step 2**: Populate from investigation
- If Mode 2 was already run, use those results
- If not, run Mode 2 first, then proceed

**Step 3**: Generate action items
- Each action item MUST have:
  - Description (concrete, not vague)
  - Type: Prevent / Detect / Mitigate / Process
  - Priority: P0 (this week) / P1 (this sprint) / P2 (this quarter)
  - Owner placeholder: `[ASSIGN: role]`
- Minimum 3, maximum 10 action items
- At least one from each type: Prevent, Detect, Mitigate

**Step 4**: Calculate incident metrics
- MTTD: Time from incident start to first alert
- MTTR: Time from detection to full recovery
- Detection gap assessment (acceptable / needs improvement / critical)
- User impact estimate (if data available)

**Step 5**: Generate postmortem document
- Write both Markdown and HTML versions
- HTML uses professional styling suitable for stakeholder presentation

**Output**: Use Postmortem Document format. Write to `incident_{YYYYMMDD}_{title}/` directory.

---

### Mode 4: Pattern Analysis — Cross-Incident Intelligence

**When**: Multiple incidents available. Need to find systemic patterns.

**Step 1**: Collect incident history
- User provides past postmortems, incident logs, or describes recurring issues

**Step 2**: Categorize incidents
- Group by: failure domain, affected layer, root cause type, time patterns

**Step 3**: Identify systemic patterns
- Recurring causes (same root cause, different symptoms)
- Common contributing factors
- Detection gap trends (are we getting faster or slower?)
- Toil indicators (manual steps that should be automated)

**Step 4**: Generate improvement roadmap
- Prioritized by: frequency × severity × fixability
- Map to infrastructure investment areas

**Output**: Pattern Analysis Report with improvement roadmap.

## Output Formats

### Triage Card
```markdown
# 🚨 Incident Triage: [Title]

**Severity**: SEV-[1-4] | **Status**: Active / Mitigated / Resolved
**Blast Radius**: [scope description]
**Started**: [timestamp] | **Detected**: [timestamp] | **MTTD**: [duration]

## Affected Systems
| System | Impact | Status |
|--------|--------|--------|
| [service] | [description] | 🔴/🟡/🟢 |

## Initial Signal
> [First error/alert that indicated the problem]

## Suspected Cause
[Best current hypothesis with confidence level]

## Immediate Actions
1. [ ] [Action with specific command or procedure]
2. [ ] [Action]
3. [ ] [Action]

## Escalation
- [ ] Page [team/person] if [condition]
- [ ] Communicate to [stakeholders] via [channel]
```

### Investigation Report
```markdown
# 🔍 Investigation Report: [Title]

**Incident**: [ID] | **Date**: [date] | **Severity**: SEV-[N]
**Investigator**: Infra Detective (AI-assisted)

## Unified Timeline
| Time | Source | Event | Severity |
|------|--------|-------|----------|
| [ts] | [src]  | [evt] | 🔴/🟡/🟢 |

## Metrics Correlation
| Metric | Baseline | Anomaly | Delta | Onset |
|--------|----------|---------|-------|-------|
| [name] | [val]    | [val]   | [%]   | [ts]  |

## Change Audit
| Time | Type | Description | Correlation |
|------|------|-------------|-------------|
| [ts] | deploy/config/infra | [desc] | 🔴 High / 🟡 Med / 🟢 Low |

## 5-Whys Analysis
1. **Why** [symptom]? → [answer] *Evidence: [source]*
2. **Why** [answer 1]? → [answer] *Evidence: [source]*
3. **Why** [answer 2]? → [answer] *Evidence: [source]*
4. **Why** [answer 3]? → [answer] *Evidence: [source]*
5. **Why** [answer 4]? → **[systemic root cause]**

## Cause Classification
- **Proximate cause**: [direct trigger]
- **Contributing factors**: [list]
- **Systemic weakness**: [organizational/process gap]

## Confidence Level
[High/Medium/Low] — [explanation of uncertainty]
```

### Postmortem Document
See `references/postmortem-patterns.md` for full template per format (Google SRE / Atlassian / PagerDuty).

## Known Issues

1. **Incomplete logs** — Detection: gaps in timeline. Fix: ask user for additional log sources, note gaps explicitly in report.
2. **Metrics without context** — Detection: anomaly values without baselines. Fix: ask user for normal baseline values or SLO thresholds.
3. **Multi-root-cause incidents** — Detection: 5-Whys branches. Fix: create parallel causal chains, note interaction effects.
4. **Hindsight bias** — Detection: "obviously they should have..." language. Fix: enforce blameless framing, focus on systemic improvements.

## Questions to Ask

When the incident context is ambiguous:
- What was the first signal (alert, user report, monitoring)?
- What changed in the last 72 hours (deployments, config, infra)?
- What is the current status (active, mitigated, resolved)?
- What observability stack is in use (Prometheus, Datadog, OpenSearch, CloudWatch)?
- Are there previous incidents with similar symptoms?

## References

- `references/investigation-playbooks.md` — Layer-specific investigation procedures and K8s-specific commands
- `references/postmortem-patterns.md` — Three postmortem formats with templates and action item taxonomy
