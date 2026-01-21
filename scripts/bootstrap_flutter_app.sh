#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/../app"

if [ -f pubspec.yaml ]; then
  echo "[OK] Flutter project already exists in app/ (pubspec.yaml present)."
  exit 0
fi

ORG="${1:-com.example}"
NAME="${2:-tipsterino}"

flutter create --org "$ORG" --project-name "$NAME" .

echo "[DONE] Flutter project created in app/."
