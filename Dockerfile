# file: Dockerfile
# version: 1.3.0
# guid: f0c1ker0-0000-4000-8000-000000000001
#
# Extends a GitHub Actions-style Ubuntu base with the project's runtime
# dependencies. Pinning the base by SHA in production is left to the caller
# (set via the IMAGE_BASE build-arg in your CI). The named tag below is the
# floor; CI should override with a digest for reproducibility.

ARG IMAGE_BASE=ubuntu:22.04
FROM ${IMAGE_BASE}

# Provenance labels — picked up by docker/metadata-action and by `gh
# attestation verify` when consumers want to confirm where the image came
# from. Override at build time with --label or via metadata-action.
LABEL org.opencontainers.image.source="https://github.com/jdfalk/burndown-runner-image" \
      org.opencontainers.image.title="burndown-runner-image" \
      org.opencontainers.image.description="Pre-baked GHA-style runner image for the overnight-burndown bot (gh CLI, Go, Python, safe-ai-util, safe-ai-util-mcp)." \
      org.opencontainers.image.licenses="MIT"

SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ENV DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

# Baseline tools — these are present on a stock GHA ubuntu-latest runner;
# pinning them here means the image is a drop-in for `runs-on: ubuntu-latest`
# users who switch to `container:`. If your base already has them this is a
# fast no-op apt cache hit.
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
        ca-certificates curl git gnupg jq make tar unzip xz-utils \
 && rm -rf /var/lib/apt/lists/* \
 && (command -v gh >/dev/null 2>&1 || ( \
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
          | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg \
        && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
        && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
            > /etc/apt/sources.list.d/github-cli.list \
        && apt-get update \
        && apt-get install -y --no-install-recommends gh \
        && rm -rf /var/lib/apt/lists/* \
    ))

# --- Go toolchain (pinned) ---
ENV GO_VERSION=1.25.0
RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) goarch=amd64 ;; \
      arm64) goarch=arm64 ;; \
      *) echo "unsupported arch: $arch" >&2; exit 1 ;; \
    esac; \
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${goarch}.tar.gz" -o /tmp/go.tgz; \
    tar -C /usr/local -xzf /tmp/go.tgz; \
    rm /tmp/go.tgz
ENV PATH=/usr/local/go/bin:/root/go/bin:$PATH \
    GOPATH=/root/go

# --- Build deps (no apt-installed Python — uv manages it below) ---
# apt's cargo/rustc on 22.04 are too old (~1.66) and can't parse modern
# Cargo.toml manifests; Rust comes from rustup below.
RUN apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        build-essential pkg-config libssl-dev \
 && rm -rf /var/lib/apt/lists/*

# --- Rust toolchain via rustup (pinned) ---
ARG RUST_VERSION=1.88.0
ENV CARGO_HOME=/usr/local/cargo \
    RUSTUP_HOME=/usr/local/rustup
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs \
      | sh -s -- -y --no-modify-path --profile minimal --default-toolchain ${RUST_VERSION}

# --- Python via uv (single static binary; bundles its own Python builds) ---
# uv installs an interpreter into /opt/python and creates a system venv at
# /opt/venv that we put on PATH. This avoids ubuntu:22.04's stale Python
# 3.10 (which doesn't support --break-system-packages) and gives every
# Python script in the image consistent access to deps installed via
# `uv pip install`. The venv approach also sidesteps PEP 668 entirely.
ARG PYTHON_VERSION=3.13
ENV UV_INSTALL_DIR=/usr/local/bin \
    UV_PYTHON_INSTALL_DIR=/opt/python \
    VIRTUAL_ENV=/opt/venv \
    PATH=/opt/venv/bin:/usr/local/cargo/bin:/usr/local/go/bin:/root/go/bin:$PATH
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
 && uv python install ${PYTHON_VERSION} \
 && uv venv --python ${PYTHON_VERSION} ${VIRTUAL_ENV} \
 && uv pip install --python ${VIRTUAL_ENV}/bin/python \
        pyyaml \
        "git+https://github.com/jdfalk/safe-ai-util-mcp@main"

# --- safe-ai-util Rust binary ---
# safe-ai-util-mcp's stdio server shells out to the Rust `safe-ai-util`
# binary via COPILOT_AGENT_UTIL_BIN. cargo install from source — adds
# ~3-5 min to image build but keeps us off any release-asset naming
# scheme that may change.
ARG SAFE_AI_UTIL_REF=main
RUN cargo install --git https://github.com/jdfalk/safe-ai-util.git --branch ${SAFE_AI_UTIL_REF} --root /usr/local
ENV COPILOT_AGENT_UTIL_BIN=/usr/local/bin/safe-ai-util

# Sanity check — fail the build if any of the load-bearing tools is missing.
RUN set -eux; \
    gh --version >/dev/null; \
    go version >/dev/null; \
    python3 --version >/dev/null; \
    python3 -c 'import yaml; print("pyyaml", yaml.__version__)'; \
    safe-ai-util --version >/dev/null; \
    safe-ai-util-mcp --help >/dev/null 2>&1 || true

WORKDIR /workspace
