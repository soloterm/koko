# koko

`soloterm/koko` is the Solo-maintained fork of [`WismutHansen/kokorox`](https://github.com/WismutHansen/kokorox), itself based on [`lucasjinreal/Kokoros`](https://github.com/lucasjinreal/Kokoros).

This repository is the source of truth for `koko` binaries distributed to Solo users. Solo builds, signs, and publishes all binaries from this repo.

## Credits

- Original Kokoro/Kokoros work by Lucas Jin and contributors
- Rust fork and major extensions by the kokorox maintainers
- Ongoing distribution/maintenance in this fork by Solo Terminal, Inc.

## License

This fork is licensed under the GNU General Public License v3.0 (`GPL-3.0-only`). See `LICENSE`.

For third-party attribution details, see `NOTICE` and tracked local modifications in `CHANGES.md`.

## Build From Source

Prerequisites:

- Rust stable toolchain
- `espeak-ng` development libraries
- `pkg-config`

Examples:

```bash
# macOS
brew install espeak-ng pkg-config

# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y espeak-ng libespeak-ng-dev pkg-config
```

Build:

```bash
cargo build --release
```

## Basic Usage

```bash
# Generate speech from text
./target/release/koko text "Hello world" -o test.wav

# List voices as JSON
./target/release/koko voices --format json

# Stream from stdin
printf "Hello from stdin\n" | ./target/release/koko stream > output.wav

# Pipe mode
printf "Hello from pipe mode\n" | ./target/release/koko pipe -o pipe.wav
```

## Release Artifacts

Release workflows produce per-platform archives containing:

- `koko` / `koko.exe`
- `LICENSE`
- `NOTICE`

Checksums are published alongside artifacts in GitHub Releases.

## Upstream Maintenance

Use manual upstream review; do not auto-merge upstream into `main`.

```bash
# Review upstream drift
just upstream-check

# Create a dated sync branch from main
just upstream-sync-branch

# If your shipping remote is not 'origin'
SHIP_REMOTE=soloterm just upstream-sync-branch

# Cherry-pick reviewed commits onto upstream-sync/*
just upstream-pick <sha> [<sha> ...]
```

The `Upstream Report` GitHub workflow runs monthly (and on manual dispatch) to report upstream commit drift and update a tracking issue. It does not modify code.
