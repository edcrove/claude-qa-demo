# Memory Index

`CLAUDE.md` imports this file, so everything imported below is present in
every session — that is what "survives the `/clear`" actually means.

## Always loaded

@memory/feedback-local-build-before-ci.md

## Loaded on demand

- [Known issues registry](known-issues.md) — flake signatures with
  first/last-seen builds. **Not** imported: it grows with every confirmed
  flake, so the `ci-failure-triage` skill reads it when a build fails
  instead of carrying it in every session.
