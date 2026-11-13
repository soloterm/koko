# koko - Solo Kokoro TTS fork
# https://github.com/soloterm/koko

set positional-arguments

# === Default ===

# List available commands
default:
    @just --list

# === Build ===

# Build debug binaries
build:
    cargo build

# Build release binaries
build-release:
    cargo build --release

# Fast compile check
check:
    cargo check --workspace

# === Test ===

# Run tests
test:
    cargo nextest run --no-fail-fast

# Run tests with cargo test (fallback)
test-cargo:
    cargo test

# === Lint & Format ===

# Run clippy linter
clippy:
    cargo clippy --all-features --tests -- -D warnings

# Alias for clippy
lint: clippy

# Auto-fix lint warnings
fix *args:
    cargo clippy --fix --all-features --tests --allow-dirty "$@"

# Format code
fmt:
    cargo fmt -- --config imports_granularity=Item

# Check formatting
fmt-check:
    cargo fmt -- --check

# === Install ===

# Interactive install with GPU acceleration selection
install-all:
    ./scripts/install-koko.sh

# Install koko CLI to ~/.cargo/bin (CPU only, default)
install:
    cargo install --path koko --force

# Install koko CLI with CUDA support
install-cuda:
    cargo install --path koko --features cuda --force

# Install koko CLI with CoreML support (macOS only)
install-coreml:
    cargo install --path koko --features coreml --force

# Install to ~/.local/bin (for non-cargo users)
install-local:
    cargo build --release --package koko
    mkdir -p ~/.local/bin
    cp target/release/koko ~/.local/bin/
    @echo "Installed koko to ~/.local/bin/koko"

# Uninstall from ~/.cargo/bin
uninstall:
    cargo uninstall koko || true

# Uninstall from ~/.local/bin
uninstall-local:
    rm -f ~/.local/bin/koko
    @echo "Removed koko from ~/.local/bin"

# === Docs ===

# Generate documentation
docs:
    cargo doc --no-deps --workspace --open

# === Clean ===

# Clean build artifacts
clean:
    cargo clean

# === Development ===

# Run koko CLI
run *args:
    cargo run --package koko -- {{args}}

# Run koko CLI (release mode)
run-release *args:
    cargo run --package koko --release -- {{args}}

# Watch for changes and rebuild
watch:
    cargo watch -x check

# === Dependencies ===

# Fetch dependencies
fetch:
    rustup show active-toolchain
    cargo fetch
    ./scripts/install.sh

# Update dependencies
update:
    cargo update

# === Upstream Sync ===

# Ensure upstream remotes exist locally
upstream-remotes:
    @if ! git remote | grep -qx 'kokorox'; then git remote add kokorox https://github.com/WismutHansen/kokorox.git; fi
    @if ! git remote | grep -qx 'kokoros'; then git remote add kokoros https://github.com/lucasjinreal/Kokoros.git; fi
    @echo "Configured upstream remotes:"
    @git remote -v | sed -n '/kokorox/p;/kokoros/p'

# Fetch upstream branches and show incoming commits
upstream-check: upstream-remotes
    git fetch kokorox --prune
    git fetch kokoros --prune
    @echo ""
    @echo "=== kokorox commits not in main ==="
    @if git rev-parse --verify -q kokorox/main >/dev/null; then git log --oneline main..kokorox/main | sed -n '1,40p'; else echo "kokorox/main not found"; fi
    @echo ""
    @echo "=== kokoros commits not in main ==="
    @if git rev-parse --verify -q kokoros/main >/dev/null; then git log --oneline main..kokoros/main | sed -n '1,40p'; else echo "kokoros/main not found"; fi
    @echo ""
    @echo "Commit counts:"
    @echo "  kokorox: $(git rev-list --count main..kokorox/main 2>/dev/null || echo 0)"
    @echo "  kokoros: $(git rev-list --count main..kokoros/main 2>/dev/null || echo 0)"
    @echo ""
    @echo "Next: run 'just upstream-sync-branch' and cherry-pick selected commits."

# Create a dated upstream sync branch from main
upstream-sync-branch: upstream-remotes
    @ship_remote="${SHIP_REMOTE:-origin}"; \
    if ! git remote get-url "$ship_remote" >/dev/null 2>&1; then \
      echo "Remote '$ship_remote' not found. Set SHIP_REMOTE or configure origin."; \
      exit 1; \
    fi; \
    ship_url="$(git remote get-url "$ship_remote")"; \
    case "$ship_url" in \
      *WismutHansen/kokorox*|*lucasjinreal/Kokoros*) \
        echo "Refusing to pull main from upstream remote ($ship_remote -> $ship_url)."; \
        echo "Set your shipping remote first (e.g. origin -> soloterm/koko), or run with SHIP_REMOTE=<remote>."; \
        exit 1; \
        ;; \
    esac
    git checkout main
    git pull --ff-only "${SHIP_REMOTE:-origin}" main
    git fetch kokorox --prune
    git fetch kokoros --prune
    @branch="upstream-sync/$(date +%Y-%m)"; \
    if git show-ref --verify --quiet "refs/heads/$branch"; then \
      branch="$branch-$(date +%d)"; \
    fi; \
    git checkout -b "$branch"; \
    echo "Created $branch"

# Cherry-pick reviewed upstream commits onto an upstream-sync branch
upstream-pick *commits:
    @if [ "{{commits}}" = "" ]; then \
      echo "Usage: just upstream-pick <sha> [<sha> ...]"; \
      exit 1; \
    fi
    @branch="$(git rev-parse --abbrev-ref HEAD)"; \
    case "$branch" in \
      upstream-sync/*) ;; \
      *) \
        echo "Refusing to cherry-pick outside upstream-sync/* branch (current: $branch)"; \
        exit 1; \
        ;; \
    esac
    git cherry-pick -x {{commits}}
    @echo "Cherry-picked: {{commits}}"

# === Release ===

# Download and verify the pinned Kokoro v1.0 model assets without uploading them
model-assets-prepare:
    #!/usr/bin/env bash
    set -euo pipefail
    out="${MODEL_ASSETS_DIR:-target/model-v1.0}"
    mkdir -p "$out"
    base="https://github.com/thewh1teagle/kokoro-onnx/releases/download/model-files-v1.0"
    curl --fail --location --retry 3 --output "$out/kokoro-v1.0.onnx" "$base/kokoro-v1.0.onnx"
    curl --fail --location --retry 3 --output "$out/voices-v1.0.bin" "$base/voices-v1.0.bin"
    cat > "$out/SHA256SUMS" <<'EOF'
    7d5df8ecf7d4b1878015a32686053fd0eebe2bc377234608764cc0ef3636a6c5  kokoro-v1.0.onnx
    bca610b8308e8d99f32e6fe4197e7ec01679264efed0cac9140fe9c29f1fbf7d  voices-v1.0.bin
    EOF
    (cd "$out" && shasum -a 256 -c SHA256SUMS)

# Create a draft model-v1.0 release after downloading and verifying the assets
model-assets-release: model-assets-prepare
    #!/usr/bin/env bash
    set -euo pipefail
    out="${MODEL_ASSETS_DIR:-target/model-v1.0}"
    gh release create model-v1.0 \
      "$out/kokoro-v1.0.onnx" "$out/voices-v1.0.bin" "$out/SHA256SUMS" \
      --draft --latest=false --title "model-v1.0" \
      --notes "Kokoro-82M v1.0 model assets (Apache-2.0). Original ONNX export and voices: thewh1teagle/kokoro-onnx model-files-v1.0. See NOTICE in this repository."

# Bump version and release (requires cargo-release)
release *args:
    cargo release {{args}}
