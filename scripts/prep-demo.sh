#!/usr/bin/env bash
# Reset the repo to a clean state for the next rehearsal, then assert that every
# scene still has something left to do.
#
# - Drops working changes and rehearsal leftovers (tracked and untracked)
# - Reinstalls demo-app deps
# - Verifies the initial state each demo depends on
# - Runs the leak check

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "→ Resetting working tree..."
git restore .
# Untracked leftovers from a rehearsal (new skills, new memory entries, new tests).
# node_modules and other ignored paths are left alone: no -x.
git clean -fdq

echo "→ Reinstalling demo-app deps..."
(cd demo-app && npm install --silent)

# iCloud Drive can evict node_modules into "dataless" placeholders (4-15s per
# cold read — typecheck appears to hang at 0% CPU). npm install over an existing
# tree does NOT rematerialize them; a fresh install writes local files and does.
dataless=$(find demo-app/node_modules -type f -exec ls -lO {} + 2>/dev/null | grep -c dataless || true)
if [[ "$dataless" -gt 0 ]]; then
  echo "→ $dataless files evicted by iCloud — reinstalling node_modules from scratch..."
  rm -rf demo-app/node_modules
  (cd demo-app && npm install --silent)
fi

echo "→ Verifying demo state..."
fail=0
check() { # check <description> <0-or-1 result>
  if [[ "$2" -eq 0 ]]; then
    echo "   ✅ $1"
  else
    echo "   ❌ $1"
    fail=1
  fi
}

# Demo 2 needs a real red test: getChannelBySlug must exist and must NOT yet
# validate the slug format, or there is nothing left to TDD on stage.
grep -q 'export function getChannelBySlug' demo-app/src/api.ts && r=0 || r=1
check "Demo 2 — getChannelBySlug exists" "$r"
grep -qE 'isValidSlug|InvalidSlug|\[a-z0-9' demo-app/src/api.ts && r=1 || r=0
check "Demo 2 — slug validation still missing (the gap DEMO-100 asks for)" "$r"

# Demo 3 needs a build already RUNNING on stage so no-parallel-ci has something
# to block live.
jq -e 'select(.status == "RUNNING" and .env == "stage")' mocks/jenkins/build-43-running.json >/dev/null 2>&1 && r=0 || r=1
check "Demo 3 — build 43 RUNNING on stage (the rule has something to block)" "$r"

# Demo 5 needs the registry to match against, and no giveaway hints in the mock.
[[ -f memory/known-issues.md ]] && r=0 || r=1
check "Demo 5 — known-issues registry present" "$r"
grep -q 'category_hint' mocks/jenkins/build-44.json && r=1 || r=0
check "Demo 5 — build mock has no category hints" "$r"

# The typecheck hook parses its stdin JSON with jq.
command -v jq >/dev/null 2>&1 && r=0 || r=1
check "Hook — jq available on PATH" "$r"

if [[ "$fail" -ne 0 ]]; then
  echo "⚠️  Demo state is not rehearsal-ready — fix the ❌ above."
  exit 1
fi

echo "→ Running leak check..."
./scripts/check-leaks.sh

echo "✅ Ready for next rehearsal"
