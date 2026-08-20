#!/usr/bin/env bash
# Fails if any banned (work-confidential) word appears anywhere in the repo,
# tracked or untracked. Run before every rehearsal and before pushing.
#
# Scope warning: this only sees THIS repo. The global config (~/.claude/CLAUDE.md,
# MCP server names, tokens) is a separate leak surface — use scripts/demo-profile.sh
# to keep it off the projector.

set -euo pipefail

# Matched case-insensitively, so one entry covers Pluto / PLUTO / pluto.
#
# Two groups: the employer's own names and hosts, and the internal identifiers
# that are not obviously confidential but are one search away from the org —
# repo names, job names, suite names, service names, framework prefixes. Those
# arrived on 2026-08-20 with docs/showable-inventory.md, which sanitizes the
# private toolkit: the substitution table there is only a promise, this is the
# enforcement.
#
# Do NOT add short tokens (3 letters or fewer). "gqe" was rejected because it
# appears inside a base64 integrity hash in package-lock.json — a banned word
# that fires on noise gets the whole check disabled.
BANNED=(
  # employer, products, hosts
  "pluto"
  "paramount"
  "viacom"
  "viacbs"
  "STCBE"
  "ed-plutotv"
  # escaped dot on purpose: the author's display name "Edgardo Crovetto" is
  # intentionally on the title slide and in LICENSE. What is banned is the work
  # e-mail local part, where the dot is literal.
  "edgardo\\.crovetto"
  "build.viacom.com"
  "jenkins-dev.ste.pluto.tv"
  "atlassian.net"
  "testrail.io"
  # internal identifiers: repos, jobs, suites, services, framework
  "api-web-monorepo"
  "service-bootstrap"
  "service-features"
  "liveEpg"
  "apps-api"
  "CBS_LO"
  "PLDCMS"
  # the private toolkit repos — the shape is showable, the names are not
  "metis-agent"
  "charon-agent"
)

ROOT="$(git rev-parse --show-toplevel)"
EXIT=0

for word in "${BANNED[@]}"; do
  if matches=$(git -C "$ROOT" grep -inI --untracked "$word" -- ':!scripts/check-leaks.sh' ':!.demo-profile' 2>/dev/null); then
    echo "❌ Leak: '$word' found"
    echo "$matches"
    EXIT=1
  fi
done

if [[ "$EXIT" -eq 0 ]]; then
  echo "✅ No leaks found"
fi

exit "$EXIT"
