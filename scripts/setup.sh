#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: $0 <path-to-client-secret.json> [--skip-install]" >&2
  exit 1
fi

CLIENT_SECRET_PATH="$1"
SKIP_INSTALL="${2:-}"

if [[ ! -f "$CLIENT_SECRET_PATH" ]]; then
  echo "Client secret file not found: $CLIENT_SECRET_PATH" >&2
  exit 1
fi

if ! command -v uv >/dev/null 2>&1; then
  echo "uv is required for setup. Install it from https://docs.astral.sh/uv/." >&2
  exit 1
fi

if [[ "$SKIP_INSTALL" != "--skip-install" ]]; then
  uv sync --extra dev
fi

if [[ ! -x ".venv/bin/gsc" ]]; then
  echo "Expected .venv/bin/gsc to exist. Run: uv sync --extra dev" >&2
  exit 1
fi

echo "Starting OAuth login for gsc..."
uv run gsc auth login --client-secret "$CLIENT_SECRET_PATH"

echo
echo "Setup complete."
echo "Run commands with:"
echo "  uv run gsc site list"
echo "Optional: set a default site"
echo "  uv run gsc config set default-site sc-domain:example.com"
