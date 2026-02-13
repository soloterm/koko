# Fork Setup Checklist (Manual Steps)

This repository includes the code/config changes from `solo-koko-fork-spec.md` that can be implemented in-source.

The following tasks must still be completed in GitHub/org settings and release operations:

## GitHub Repository Settings

- Set repo name to `soloterm/koko`
- Ensure visibility is `Public`
- Configure branch protection on `main`:
  - Require pull request reviews
  - Require status checks to pass (`CI` workflow)
  - Disallow force pushes/deletions on protected branch

## Git Remotes

```bash
git remote add kokorox https://github.com/WismutHansen/kokorox.git
git remote add kokoros https://github.com/lucasjinreal/Kokoros.git
git fetch --all
```

## Required GitHub Secrets

Add these repository secrets for release signing/notarization:

- `APPLE_CERTIFICATE`
- `APPLE_CERTIFICATE_PASSWORD`
- `APPLE_SIGNING_IDENTITY`
- `APPLE_ID`
- `APPLE_TEAM_ID`
- `APPLE_PASSWORD` (or `APPLE_APP_PASSWORD` as fallback)
- Windows signing secrets (provider-specific)

## Initial Validation Commands

```bash
cargo build --release
./target/release/koko text "Hello world" -o test.wav
./target/release/koko voices --format json
printf "Hello from stdin\n" | ./target/release/koko stream > stream.wav
printf "Hello from pipe\n" | ./target/release/koko pipe -o pipe.wav
```

## First Test Release

```bash
git tag v0.1.0-rc1
git push origin v0.1.0-rc1
```

Then verify release artifacts, checksums, signatures, and generated `manifest.json`.
