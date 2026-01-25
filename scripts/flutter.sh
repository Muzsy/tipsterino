#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/app/.env"

# Load optional local env (not committed)
if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

cd "$ROOT/app"

EXTRA_ARGS=()
CMD="${1:-}"

# Only pass --dart-define to flutter subcommands that actually accept it.
case "$CMD" in
  run|build|test|drive)
    if [[ -n "${SUPABASE_URL:-}" ]]; then
      EXTRA_ARGS+=("--dart-define=SUPABASE_URL=${SUPABASE_URL}")
    fi
    if [[ -n "${SUPABASE_ANON_KEY:-}" ]]; then
      EXTRA_ARGS+=("--dart-define=SUPABASE_ANON_KEY=${SUPABASE_ANON_KEY}")
    fi
    ;;
  *)
    # No dart-defines for commands like: pub, analyze, format, doctor, clean, create, etc.
    ;;
esac

if [[ -z "${CMD}" ]]; then
  exec flutter "${EXTRA_ARGS[@]}"
else
  exec flutter "$CMD" "${@:2}" "${EXTRA_ARGS[@]}"
fi
