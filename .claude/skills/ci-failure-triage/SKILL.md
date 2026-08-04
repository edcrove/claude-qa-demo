---
name: ci-failure-triage
description: Use when a CI build has failed tests. Categorizes failures into real regression, known flake, or infrastructure, then suggests a next action (retry, fix, ignore).
---

# CI failure triage

## Inputs

- The failure list (JSON or text) — in this demo: `mocks/jenkins/build-N.json`
- The known-issues registry: `memory/known-issues.md`, maintained by the
  `known-issues-registry-update` skill

## Steps

### 1. Parse failures

For each failed test, extract:
- Test name
- Failure message (first 3 lines)
- Failing step / line

### 2. Categorize

Read `memory/known-issues.md` **first** — a registry match wins over every other
signal. Categorize on the evidence (test name, message, stack), never on a
`category` field supplied by the build itself.

| Category | Signal | Precedence |
|----------|--------|------------|
| Known flake | Test name + message match a registry entry | 1 (checked first) |
| Infrastructure | The environment is unreachable, not the assertion wrong: connection refused, DNS, TLS, missing credentials | 2 |
| Test bug | Assertion against stale data, hardcoded date, or an order the API never guaranteed | 3 |
| Real regression | Not in the registry, the assertion is about behavior, and the change under test touches related code | 4 (default) |

A bare `TimeoutException` is **not** automatically infrastructure: if the test is in
the registry with that signature, it is a known flake. Only escalate to infra when
the failure shows the environment itself is down.

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
