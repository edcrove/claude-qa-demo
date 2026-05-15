#!/usr/bin/env bash
# Reset the repo to a clean state for the next rehearsal.
#
# - Drops any working changes in the demo-app
# - Clears memory entries created during the rehearsal (keeps seeds)
# - Reinstalls demo-app deps

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

echo "→ Resetting working tree..."
git restore .
git clean -fd demo-app/dist demo-app/coverage 2>/dev/null || true

echo "→ Restoring seed memory only..."
# Anything in memory/ not tracked by git was created during a rehearsal — remove it.
if [[ -d memory ]]; then
  git -C memory clean -fd
fi

echo "→ Reinstalling demo-app deps..."
(cd demo-app && npm install --silent)

echo "→ Running leak check..."
./scripts/check-leaks.sh

echo "✅ Ready for next rehearsal"
