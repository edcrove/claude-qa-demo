---
name: feedback-local-build-before-ci
description: Always run local typecheck + tests before triggering remote CI, especially after a rebase.
metadata:
  type: feedback
---

Run `npm run typecheck && npm test` in `demo-app/` before triggering any remote
CI build.

**Why:** A failed remote build burns ~10 minutes of wall clock and a slot in the
CI queue. Local typecheck catches the vast majority of breakages in seconds.

**How to apply:** This is what the `local-build-gate` skill enforces. If the user
asks to trigger CI directly, remind them of the gate first.
