---
name: local-build-gate
description: Use before triggering remote CI to fail fast on compile or unit-test errors. Saves ~10 minutes per broken push by catching issues locally.
---

# Local build gate

Always run before triggering any remote CI build, especially after a rebase,
cherry-pick, or large refactor.

## Steps

1. **Typecheck:**
   ```bash
   cd demo-app && npm run typecheck
   ```
   Expected: no output. If errors, fix them and stop — do not proceed to CI.

2. **Unit tests:**
   ```bash
   cd demo-app && npm test
   ```
   Expected: all green. If any test fails, fix it locally — do not proceed.

3. **Smoke check:** if the change affects an endpoint, manually call it once
   with a known input to confirm no obvious runtime breakage.

## When to skip

Never. The rule `no-parallel-ci.mdc` still applies on top of this — they
compose.

## What this prevents

- 10-minute CI runs that fail in the first 30 seconds with a typo
- Slot contention with teammates' real test runs
- Pollution of the known-issues registry with false flakes
