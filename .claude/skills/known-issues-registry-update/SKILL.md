---
name: known-issues-registry-update
description: Use after CI triage when a new flake is confirmed. Appends an entry to the known-issues registry with the test name, failure signature, frequency, and first/last-seen build numbers.
---

# Known issues registry update

The registry is the single source of truth for "this is a flake, not a
regression". It lives at `memory/known-issues.md` (created on first use).

## Entry format

```markdown
## <testFullyQualifiedName>

- **Signature:** <one-line failure message snippet, regex-safe>
- **First seen:** build N (YYYY-MM-DD)
- **Last seen:** build M (YYYY-MM-DD)
- **Frequency:** rare / occasional / frequent
- **Hypothesis:** one sentence about probable cause
- **Owner:** team or person to escalate to
```

## Workflow

1. **Find or create entry** by test name.
2. **Update last-seen** if entry exists.
3. **Bump frequency** based on the seen count:
   - rare: ≤ 2 sightings in last 30 days
   - occasional: 3–10
   - frequent: > 10
4. **If frequency just hit "frequent":** suggest opening a ticket to actually fix it.

## Never

- Do not delete entries — keep them as historical record.
- Do not mark a test as flake without 2+ sightings; one failure is not a pattern.
