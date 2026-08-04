#!/usr/bin/env bash
# Launch Claude Code in an isolated config profile for the talk.
#
# Why: the day-to-day config in ~/.claude is the real leak risk, not the repo.
# It loads a global CLAUDE.md with employer names and internal URLs, MCP servers
# whose names show up in every tool call, tokens, and other projects in
# autocomplete. check-leaks.sh cannot see any of that — it only greps this repo.
#
# This profile loads the repo's own CLAUDE.md, skills, rules and hook, plus the
# two marketplace plugins the demo needs. Nothing else.

set -euo pipefail

ROOT="$(git rev-parse --show-toplevel)"
PROFILE="$ROOT/.demo-profile"

mkdir -p "$PROFILE"

# Reuse the already-installed plugins (superpowers, pr-review-toolkit) without
# importing the rest of the global config.
if [[ -d "$HOME/.claude/plugins" && ! -e "$PROFILE/plugins" ]]; then
  ln -s "$HOME/.claude/plugins" "$PROFILE/plugins"
fi

cat > "$PROFILE/settings.json" <<'JSON'
{
  "enabledPlugins": {
    "superpowers@claude-plugins-official": true,
    "pr-review-toolkit@claude-plugins-official": true
  },
  "model": "sonnet",
  "permissions": { "defaultMode": "auto" }
}
JSON

# Skip the first-run wizard on stage.
if [[ ! -f "$PROFILE/.claude.json" ]]; then
  cat > "$PROFILE/.claude.json" <<'JSON'
{ "hasCompletedOnboarding": true, "theme": "dark" }
JSON
fi

cat <<EOF
Demo profile: $PROFILE

  · no global CLAUDE.md   → no employer names, no internal URLs in context
  · no MCP servers        → no jenkins/jira/testrail hostnames in tool calls
  · plugins               → superpowers + pr-review-toolkit only
  · model                 → sonnet (run /model opus before Demo 4 if you want it)

On stage: run /context once and confirm only ./CLAUDE.md is loaded.

EOF

cd "$ROOT"
exec env CLAUDE_CONFIG_DIR="$PROFILE" claude "$@"
