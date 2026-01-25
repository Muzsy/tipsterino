#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$ROOT/app"

mkdir -p "$APP_DIR"
cd "$APP_DIR"

if [[ -f "pubspec.yaml" ]]; then
  echo "[OK] Flutter project already exists in app/ (pubspec.yaml present)."
  exit 0
fi

ORG="${1:-com.example}"
NAME="${2:-tipsterino}"

# Safety: don't run flutter create into a non-empty directory without pubspec.yaml
shopt -s dotglob nullglob
files=("$APP_DIR"/*)

if (( ${#files[@]} > 0 )); then
  echo "[ERROR] app/ is not empty but pubspec.yaml is missing."
  echo "Refusing to run 'flutter create' into a dirty directory."
  echo "Fix: restore pubspec.yaml or clean app/ first."
  ls -la
  exit 1
fi

flutter create --org "$ORG" --project-name "$NAME" .

echo "[DONE] Flutter project created in app/."
