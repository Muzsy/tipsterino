#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

"$DIR/flutter.sh" pub get
"$DIR/flutter.sh" analyze
"$DIR/flutter.sh" test

echo "[DONE] app/ analyze + test OK"
