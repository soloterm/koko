# soloterm/koko Agent Guide

## What This Repo Is

`soloterm/koko` is Solo Terminal's maintained distribution fork of Kokoro TTS.

- Upstream base: `WismutHansen/kokorox`
- Upstream lineage: `lucasjinreal/Kokoros`
- Shipping goal: Solo builds/signs/releases binaries from this repo only.
- License: GPL-3.0-only for this fork (see `LICENSE`).

This repo is intentionally maintained as a reviewed fork, not an auto-synced mirror.

## Non-Negotiable Safety Rules

1. Never auto-merge upstream into `main`.
2. Never ship unreviewed upstream commits.
3. Never rebase `main` onto upstream branches.
4. Only cherry-pick selected upstream commits onto an `upstream-sync/*` branch.
5. Keep `CHANGES.md` updated whenever upstream code is pulled in.

## Branch and Remote Strategy

- `main`: stable release branch
- `upstream-sync/*`: temporary review/integration branches
- `solo/*`: Solo-specific work

Expected remotes:

- Shipping remote: `origin` -> `soloterm/koko`
- Upstream remotes: `kokorox`, `kokoros`

If needed:

```bash
git remote set-url origin git@github.com:soloterm/koko.git
```

## Manual Upstream Sync Workflow (Recommended)

1. Check upstream drift:

```bash
just upstream-check
```

2. Create a dated sync branch from `main`:

```bash
just upstream-sync-branch
# or, if shipping remote isn't origin:
SHIP_REMOTE=<shipping-remote> just upstream-sync-branch
```

3. Cherry-pick reviewed commits:

```bash
just upstream-pick <sha> [<sha> ...]
```

4. Validate locally:

```bash
cargo check -p koko
cargo test -p koko
cargo clippy -p koko --all-targets --no-deps -- -D warnings
```

5. Open PR from `upstream-sync/*` into `main` and review before merge.

## Built-In Helpers in This Repo

`justfile` includes:

- `upstream-remotes`
- `upstream-check`
- `upstream-sync-branch`
- `upstream-pick`

`upstream-sync-branch` has a guard that refuses to pull if the selected shipping remote points to upstream.
`upstream-pick` has a guard that refuses to run outside `upstream-sync/*` branches.

## GitHub Reporting Workflow

`.github/workflows/upstream-report.yml` is reporting-only.

- Runs monthly and on manual dispatch
- Fetches upstream heads
- Reports commit drift in the workflow run summary and the `upstream-report` artifact (issues are disabled on this repository)

It does **not** merge, rebase, or modify code.

## Release Discipline

Before tagging a release:

1. Confirm `main` is clean and reviewed.
2. Confirm CI passes.
3. Update `CHANGES.md`.
4. Tag (`v*`) and publish through release workflow.
5. Verify release artifacts/signing/checksums.

## If You Are Unsure

Default to no-op and ask for review.
When in doubt, prefer manual review and cherry-pick over merge.
