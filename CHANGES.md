# CHANGES

This file tracks modifications made in the `soloterm/koko` fork and corresponding source updates for GPLv3 distribution.

## 2026-11-12

- Validate eSpeak data at startup, find the bundle beside the canonical executable, and retain Linux system data paths.
- Bundle the matching compiled `espeak-ng-data/` in macOS release archives and verify its `phontab`.
- Add a checksum-verified preparation recipe for a draft `model-v1.0` assets release.
- Accept the pinned v1.0 ONNX model's `tokens` input and honor explicit model/voices files in the OpenAI server.
- Allow `-m` and `-d` after `openai` so Solo's sidecar launch command can pass explicit assets.
- Honor an explicit `voice` in OpenAI speech requests while retaining automatic voice selection when omitted.
- Build macOS release archives without AppleDouble entries. Release verification now rejects any entry outside `koko`, `LICENSE`, `NOTICE` and `espeak-ng-data/`, and requires the Solo signing Team ID.

## 2026-02-13

Base upstream:

- Forked from `WismutHansen/kokorox`
- Base commit: `a302012` (`chore: release 0.2.1`)

Fork bootstrap changes:

- Repositioned repository docs for Solo-maintained distribution fork (`README.md`)
- Added third-party attribution notice file (`NOTICE`)
- Added this change log (`CHANGES.md`)
- Updated package metadata to `soloterm/koko` URLs and Solo maintainer authorship
- Added release profile stripping (`[profile.release] strip = true`)
- Added/updated GitHub Actions workflows for CI and cross-platform release builds
- Added Dependabot configuration for Cargo and GitHub Actions updates
- Added `FORK_SETUP.md` to capture required manual GitHub-side setup steps
- Added CLI improvements for Solo integration (`--voices` alias, parseable version source, preflight path checks, structured exit codes)
- Added `just` upstream maintenance commands and a reporting-only upstream GitHub workflow
- Aligned macOS release signing/notarization with desktop-style secrets and stricter verification
- Added post-build macOS artifact verification gate in release workflow (`codesign`, `spctl`, checksums, packaged docs)
