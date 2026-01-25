#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if ! command -v supabase >/dev/null 2>&1; then
  echo "Supabase CLI nem található. Telepítsd és győződj meg róla, hogy a PATH-ban van." >&2
  exit 1
fi

cd "$ROOT"
exec supabase "$@"
