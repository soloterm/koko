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
- `pkg-config`
- Opus development libraries

Examples:

```bash
# macOS
brew install pkg-config opus

# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y pkg-config libopus-dev libasound2-dev
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
- `espeak-ng-data/` alongside `koko` in the macOS archive, copied from the
  `espeak-rs-sys` build so it matches the statically linked eSpeak library

Checksums are published alongside artifacts in GitHub Releases.

The macOS archive extracts to this layout:

```text
koko
espeak-ng-data/
  phontab
  ...
LICENSE
NOTICE
```

Keep `koko` and `espeak-ng-data/` together when installing the macOS binary.
At startup, `koko` uses the data beside its canonical executable path. You can
instead set `PIPER_ESPEAKNG_DATA_DIRECTORY` to the **parent** of
`espeak-ng-data/`; `ESPEAK_DATA_PATH` also accepts that parent or the data
directory itself. `koko` exits with an error when it cannot find `phontab`.

Model files are distributed separately. `just model-assets-prepare` downloads
`kokoro-v1.0.onnx` and `voices-v1.0.bin` from the
[`model-files-v1.0` upstream release](https://github.com/thewh1teagle/kokoro-onnx/releases/tag/model-files-v1.0)
to `target/model-v1.0/`, verifies their SHA-256 hashes, and writes `SHA256SUMS`.
`just model-assets-release` performs the same verification and uploads those
three files to a draft `model-v1.0` release. The model and voices are Apache-2.0;
see `NOTICE`.

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
