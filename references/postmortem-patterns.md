# Postmortem Patterns & Templates

Three industry-standard postmortem formats with complete templates, action item taxonomy, and blameless writing guidelines.

## Format Selection Guide

| Format | Best For | Length | Audience |
|--------|----------|--------|----------|
| Google SRE | Engineering teams, technical depth | Long | Engineers, SRE, Tech leads |
| Atlassian | Cross-functional teams, process focus | Medium | Engineering + Product + Management |
| PagerDuty | Fast turnaround, action-oriented | Short | On-call teams, rapid iteration |

Default: Google SRE format unless user specifies otherwise.

---

## Format 1: Google SRE Postmortem

```markdown
# Postmortem: [Incident Title]

**Date**: [YYYY-MM-DD]
**Authors**: [names]
**Status**: Draft / Review / Final
**Severity**: SEV-[1-4]
**Incident Commander**: [name/role]

## Summary

[2-3 sentence executive summary. What happened, how long, what was affected, how it was resolved.]

## Impact

- **Duration**: [start time] to [end time] ([total duration])
- **User Impact**: [N users affected, N% of traffic, specific features unavailable]
- **Revenue Impact**: [estimated if applicable]
- **SLO Impact**: [which SLOs were breached, by how much, remaining error budget]

## Timeline

All times in UTC.

| Time | Event |
|------|-------|
| HH:MM | [First anomalous signal] |
| HH:MM | [Alert fires / user report] |
| HH:MM | [Incident declared, IC assigned] |
| HH:MM | [Investigation begins] |
| HH:MM | [Root cause identified] |
| HH:MM | [Mitigation applied] |
| HH:MM | [Recovery confirmed] |
| HH:MM | [Incident resolved, all-clear] |

## Root Cause

[Detailed technical explanation of what went wrong and why. Include code snippets, config diffs, or architecture diagrams as needed. Focus on the systemic issue, not individual actions.]

## Trigger

[What specific event initiated the incident? Deployment, config change, traffic spike, external dependency failure, etc.]

## Detection

[How was the incident detected? Alert, user report, manual observation? Was the detection mechanism adequate?]

- **MTTD**: [duration from trigger to detection]
- **Detection method**: [automated alert / user report / manual check]
- **Detection gap assessment**: [adequate / needs improvement / critical gap]

## Response

[How the team responded. What worked well, what was difficult, any communication issues.]

## Recovery

[What specific actions resolved the incident? Rollback, config change, scaling, hotfix, etc.]

- **MTTR**: [duration from detection to recovery]

## Lessons Learned

### What Went Well
- [Positive observation — something that prevented worse outcome or accelerated recovery]
- [Positive observation]

### What Went Wrong
- [Negative observation — not blame, but systemic issues]
- [Negative observation]

### Where We Got Lucky
- [Near-miss observation — something that could have made it worse but didn't]
- [Near-miss observation]

## Action Items

| ID | Action | Type | Priority | Owner | Due Date | Bug/Ticket |
|----|--------|------|----------|-------|----------|------------|
| 1 | [concrete action] | Prevent | P0 | [ASSIGN: role] | [date] | [link] |
| 2 | [concrete action] | Detect | P1 | [ASSIGN: role] | [date] | [link] |
| 3 | [concrete action] | Mitigate | P1 | [ASSIGN: role] | [date] | [link] |
| 4 | [concrete action] | Process | P2 | [ASSIGN: role] | [date] | [link] |

## Supporting Data

[Links to dashboards, logs, traces, chat transcripts, or other evidence.]
```

---

## Format 2: Atlassian Postmortem

```markdown
# Incident Review: [Title]

**Incident #**: [ID]
**Date**: [YYYY-MM-DD]
**Severity**: [Critical / Major / Minor]
**Prepared by**: [name]

## What Happened?

[Plain-language description accessible to non-technical stakeholders. 1 paragraph.]

## What Was the Customer Impact?

- **Affected customers**: [number or percentage]
- **Affected features**: [list]
- **Duration of impact**: [time]
- **Support tickets created**: [number if known]

## What Triggered This?

[Single sentence: the specific event that started the cascade.]

## How Did We Respond?

| Step | Who | What | When |
|------|-----|------|------|
| Detection | [team] | [how detected] | [time] |
| Triage | [IC] | [severity assessment] | [time] |
| Investigation | [team] | [what was investigated] | [time] |
| Mitigation | [who] | [what fixed it] | [time] |
| Recovery | [who] | [full service restoration] | [time] |
| Communication | [who] | [stakeholder updates sent] | [time] |

## Why Did It Happen? (5 Whys)

1. **Why** [symptom]?
   Because [cause 1].
2. **Why** [cause 1]?
   Because [cause 2].
3. **Why** [cause 2]?
   Because [cause 3].
4. **Why** [cause 3]?
   Because [cause 4].
5. **Why** [cause 4]?
   Because [root cause / systemic issue].

## What Are We Doing About It?

| # | Action | Type | Priority | Owner | Target Date |
|---|--------|------|----------|-------|-------------|
| 1 | [action] | Prevention | Immediate | [role] | [date] |
| 2 | [action] | Detection | Sprint | [role] | [date] |
| 3 | [action] | Process | Quarter | [role] | [date] |

## Appendix

[Links to technical details, logs, dashboards]
```

---

## Format 3: PagerDuty Postmortem (Compact)

```markdown
# [Title] — Postmortem

**When**: [date, start-end times UTC]
**Severity**: SEV-[N] | **Duration**: [total]
**IC**: [name] | **Status**: [Draft/Final]

## TL;DR
[One sentence: what broke, why, how long, how fixed.]

## Impact
[Bullet points: users, features, SLOs affected]

## Timeline
- **HH:MM** — [event]
- **HH:MM** — [event]
- **HH:MM** — [event]

## Root Cause
[1-2 paragraphs, technical but concise]

## Resolution
[What specifically fixed it]

## Metrics
| Metric | Value |
|--------|-------|
| MTTD | [time] |
| MTTR | [time] |
| Error budget consumed | [%] |

## Action Items
- [ ] **P0**: [action] — [ASSIGN: role]
- [ ] **P1**: [action] — [ASSIGN: role]
- [ ] **P1**: [action] — [ASSIGN: role]
- [ ] **P2**: [action] — [ASSIGN: role]
```

---

## Action Item Taxonomy

Every action item must be classified by type:

| Type | Purpose | Examples |
|------|---------|---------|
| **Prevent** | Stop this class of incident from happening | Add input validation, implement circuit breaker, set resource limits |
| **Detect** | Find this type of incident faster | Add alert for error rate, create dashboard, improve log verbosity |
| **Mitigate** | Reduce impact when it does happen | Add graceful degradation, implement retry with backoff, add runbook |
| **Process** | Improve team response capability | Update on-call playbook, run gameday, improve handoff procedure |

### Action Item Quality Checklist
- [ ] Is it specific? ("Add OOM alert for payments service" not "improve monitoring")
- [ ] Is it measurable? (Can you verify it's done?)
- [ ] Has an owner role? (Even if placeholder `[ASSIGN: SRE]`)
- [ ] Has a priority? (P0/P1/P2)
- [ ] Has a target date?
- [ ] Is it actually addressing the root cause (not just the symptom)?

---

## Blameless Writing Guidelines

### Words to Avoid
| Avoid | Use Instead |
|-------|-------------|
| "X should have..." | "The system lacked..." |
| "X failed to..." | "The process didn't include..." |
| "Human error" | "The interface allowed..." |
| "Careless" | "The validation didn't catch..." |
| "Obviously" | "In hindsight..." |
| "Simple mistake" | "The system permitted..." |

### Blameless Framing Principle
Every failure is a system failure. If a human made an error, the system should have:
1. Prevented the error (guardrails, validation)
2. Detected the error quickly (monitoring, alerts)
3. Limited the blast radius (circuit breakers, rollback)
4. Made recovery easy (runbooks, automation)

The postmortem's job is to identify which of these system properties were missing and how to add them.

---

## Incident Severity Definitions

| Severity | Criteria | Response |
|----------|----------|----------|
| SEV-1 | Complete service outage, data loss risk, security breach | All hands, exec notification, war room |
| SEV-2 | Major feature unavailable, significant user impact | Dedicated IC, team mobilization |
| SEV-3 | Degraded performance, minor feature impact | On-call investigation, normal escalation |
| SEV-4 | Cosmetic issue, minimal user impact | Next business day, no escalation |
