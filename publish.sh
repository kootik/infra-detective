#!/bin/bash
# One-shot publish script for infra-detective
# Usage: bash publish.sh

set -e

REPO_NAME="infra-detective"
DESCRIPTION="Multi-agent incident investigation skill for Claude Code — parallel log analysis, metrics correlation, blameless postmortems"

echo "Creating GitHub repo: $REPO_NAME"
gh repo create "$REPO_NAME" --public --description "$DESCRIPTION" --clone=false

git init
git add -A
git commit -m "feat: infra-detective v1.0.0 — multi-agent incident investigation skill

- 4 modes: triage, investigate, postmortem, pattern analysis
- 3 parallel haiku agents for timeline/metrics/change audit
- 5-layer K8s investigation playbooks with kubectl/PromQL
- 3 postmortem formats (Google SRE / Atlassian / PagerDuty)
- Bilingual triggers (EN/RU)
- Audit score: 4.6/5 (Grade A)"

REMOTE=$(gh repo view "$REPO_NAME" --json url -q .url)
git remote add origin "$REMOTE"
git branch -M main
git push -u origin main

echo ""
echo "Published: $REMOTE"
echo "Done."
