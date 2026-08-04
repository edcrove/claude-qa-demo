# Known issues registry

Single source of truth for "this is a flake, not a regression". Maintained by the
`known-issues-registry-update` skill and read by `ci-failure-triage`.

Never delete entries — they are the historical record.

## ChannelsApiTest.list_returnsAllChannels

- **Signature:** `TimeoutException: read timed out after 5000ms`
- **First seen:** build 33 (2026-04-28)
- **Last seen:** build 39 (2026-05-11)
- **Frequency:** occasional
- **Hypothesis:** stage fixture loader warms up lazily; the first list call after a
  deploy can exceed the 5s client timeout.
- **Owner:** platform (stage environment)

## ChannelsApiTest.list_paginates

- **Signature:** `TimeoutException: read timed out after 5000ms`
- **First seen:** build 35 (2026-05-04)
- **Last seen:** build 39 (2026-05-11)
- **Frequency:** occasional
- **Hypothesis:** same warm-up window as `list_returnsAllChannels` — both hit the
  channels collection endpoint.
- **Owner:** platform (stage environment)

## ItemsApiTest.list_sortsByRelevance

- **Signature:** `AssertionError: expected order [a, b, c] but got [b, a, c]`
- **First seen:** build 21 (2026-03-17)
- **Last seen:** build 28 (2026-04-09)
- **Frequency:** rare
- **Hypothesis:** relevance score ties are resolved non-deterministically; the test
  asserts a total order where only a partial order is guaranteed.
- **Owner:** items team
