# Known issues registry

Single source of truth for "this is a flake, not a regression". Maintained by the
`known-issues-registry-update` skill and read by `ci-failure-triage`.

Never delete entries — they are the historical record.

## GET /api/v1/channels > returns all channels

- **Signature:** `Test timed out in 5000ms`
- **First seen:** build 33 (2026-04-28)
- **Last seen:** build 39 (2026-05-11)
- **Frequency:** occasional
- **Hypothesis:** stage fixture loader warms up lazily; the first list call after a
  deploy can exceed the 5s test timeout.
- **Owner:** platform (stage environment)

## GET /api/v1/channels > paginates

- **Signature:** `Test timed out in 5000ms`
- **First seen:** build 35 (2026-05-04)
- **Last seen:** build 39 (2026-05-11)
- **Frequency:** occasional
- **Hypothesis:** same warm-up window as `returns all channels` — both hit the
  channels collection endpoint.
- **Owner:** platform (stage environment)

## GET /api/v1/items > sorts by relevance

- **Signature:** `expected [ 'a', 'b', 'c' ] to deeply equal [ 'b', 'a', 'c' ]`
- **First seen:** build 21 (2026-03-17)
- **Last seen:** build 28 (2026-04-09)
- **Frequency:** rare
- **Hypothesis:** relevance score ties are resolved non-deterministically; the test
  asserts a total order where only a partial order is guaranteed.
- **Owner:** items team
