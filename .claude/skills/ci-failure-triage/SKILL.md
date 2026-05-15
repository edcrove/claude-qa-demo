---
name: ci-failure-triage
description: Use when a CI build has failed tests. Categorizes failures into real regression, known flake, or infrastructure, then suggests a next action (retry, fix, ignore).
---

# CI failure triage

## Inputs

- The failure list (JSON or text) — in this demo: `mocks/jenkins/build-N.json`
- The known-issues registry: `evolution-timeline.md` and the
  `known-issues-registry-update` skill output

## Steps

### 1. Parse failures

For each failed test, extract:
- Test name
- Failure message (first 3 lines)
- Failing step / line

### 2. Categorize

| Category | Signal |
|----------|--------|
| Real regression | Failure never seen before AND the change being tested touches related code |
| Known flake | Failure matches an entry in the registry |
| Infrastructure | Failure mentions network, DNS, timeouts, or missing credentials |
| Test bug | Failure mentions assertion against stale data or hardcoded date |

### 3. Decide next action

- All real regressions → flag for the author, do not retry
- All flakes → suggest retry (subject to `no-parallel-ci.mdc`)
- Mixed → flag regressions, retry the rest
- All infra → escalate to the platform team

### 4. Update the registry

For any new flake confirmed, invoke the `known-issues-registry-update` skill.

## Output

```
✅/❌ build N — X passed / Y failed (Z flakes)

Regressions:
- testName1 — line, hint, suspected commit
Flakes:
- testName2 — last seen in build M
Infra:
- testName3 — DNS timeout on staging
```

Always match the format defined by `status-format.mdc`.
