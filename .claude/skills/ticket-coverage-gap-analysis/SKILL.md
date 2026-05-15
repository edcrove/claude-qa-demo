---
name: ticket-coverage-gap-analysis
description: Use when given a QA/STE ticket about adding or modifying test coverage for an API endpoint or feature. Analyzes existing tests, identifies gaps, and proposes a concrete list of new test cases with an effort estimate.
---

# Ticket coverage gap analysis

When the user asks you to plan work for a coverage ticket, follow this exact
workflow:

## 1. Read the ticket

Find the ticket JSON (in this demo: `mocks/jira/`) or fetch via the ticketing
system. Extract:
- Endpoint or feature under test
- Acceptance criteria
- Any links to related tickets

## 2. Map existing coverage

Search the test directory for tests that already touch the endpoint:

```bash
grep -rn "<endpoint-or-symbol>" demo-app/tests/
```

List each test file with a one-line description of what it covers.

## 3. Identify gaps

For each acceptance criterion, mark it as:
- ✅ already covered (and by which test)
- ⚠️ partially covered (and what's missing)
- ❌ not covered

## 4. Propose new test cases

Write a TodoWrite list with one item per missing test case. Each item should
include the test name and a one-line behavior description.

## 5. Estimate effort

For each new test, estimate small / medium / large based on:
- small: single assertion against a deterministic response
- medium: needs setup data or multiple steps
- large: needs new fixtures or cross-service coordination

## Output format

Reply with three sections in this order:
1. **Coverage map** (table)
2. **Gaps** (bulleted list)
3. **Proposed work** (TodoWrite + estimate)
