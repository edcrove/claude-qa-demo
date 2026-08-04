#!/usr/bin/env bash
# Fails if any banned (work-confidential) word appears anywhere in the repo,
# tracked or untracked. Run before every rehearsal and before pushing.
#
# Scope warning: this only sees THIS repo. The global config (~/.claude/CLAUDE.md,
# MCP server names, tokens) is a separate leak surface — use scripts/demo-profile.sh
# to keep it off the projector.

set -euo pipefail

BANNED=(
  "pluto"
  "Pluto"
  "PLUTO"
  "paramount"
  "Paramount"
  "viacom"
  "Viacom"
  "STCBE"
  "ed-plutotv"
  "edgardo.crovetto"
  "build.viacom.com"
  "jenkins-dev.ste.pluto.tv"
  "paramount.atlassian.net"
  "paramount.testrail.io"
)

ROOT="$(git rev-parse --show-toplevel)"
EXIT=0

for word in "${BANNED[@]}"; do
  if matches=$(git -C "$ROOT" grep -nI --untracked "$word" -- ':!scripts/check-leaks.sh' ':!.demo-profile' 2>/dev/null); then
    echo "❌ Leak: '$word' found"
    echo "$matches"
    EXIT=1
  fi
done

if [[ "$EXIT" -eq 0 ]]; then
  echo "✅ No leaks found"
fi

exit "$EXIT"
