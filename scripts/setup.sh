#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <path-to-client-secret.json>" >&2
  exit 1
fi

CLIENT_SECRET_PATH="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

if [[ ! -f "$CLIENT_SECRET_PATH" ]]; then
  echo "Client secret file not found: $CLIENT_SECRET_PATH" >&2
  exit 1
fi

CLIENT_SECRET_DIR="$(cd "$(dirname "$CLIENT_SECRET_PATH")" && pwd)"
CLIENT_SECRET_PATH="$CLIENT_SECRET_DIR/$(basename "$CLIENT_SECRET_PATH")"

if ! command -v uv >/dev/null 2>&1; then
  echo "uv is required for setup. Install it from https://docs.astral.sh/uv/." >&2
  exit 1
fi

echo "Starting OAuth login for gsc..."
uv run --project "$SKILL_DIR" gsc auth login --client-secret "$CLIENT_SECRET_PATH"

echo
echo "Setup complete."
echo "Run commands with:"
echo "  uv run --project \"$SKILL_DIR\" gsc site list"
echo "Optional: set a default site"
echo "  uv run --project \"$SKILL_DIR\" gsc config set default-site sc-domain:example.com"
