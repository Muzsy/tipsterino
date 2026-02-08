#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

usage() {
  echo "Használat: $0 --report <codex/reports/.../valami.md>" >&2
  exit 2
}

REPORT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --report)
      REPORT="${2:-}"; shift 2;;
    -h|--help)
      usage;;
    *)
      echo "Ismeretlen arg: $1" >&2
      usage;;
  esac
done

[[ -n "$REPORT" ]] || usage

# biztosítsuk a könyvtárat
REPORT_DIR="$(dirname "$REPORT")"
mkdir -p "$REPORT_DIR"

# log fájl a report mellett
LOG="${REPORT%.md}.verify.log"

TS="$(date -Iseconds)"

# gyűjtsünk diffet (a jelenlegi working tree alapján)
DIFF_STAT="$(git diff --stat || true)"
DIFF_NAME_STATUS="$(git diff --name-status || true)"

# futtassuk a kaput úgy, hogy a log mentés megmaradjon FAIL esetén is
set +e
( ./scripts/check.sh ) 2>&1 | tee "$LOG"
EXIT_CODE=${PIPESTATUS[0]}
set -e

RESULT="PASS"
if [[ "$EXIT_CODE" -ne 0 ]]; then
  RESULT="FAIL"
fi

TAIL_LOG=""
if [[ "$RESULT" == "FAIL" ]]; then
  # elég a vége, hogy gyorsan lásd a bajt
  TAIL_LOG="$(tail -n 120 "$LOG" || true)"
fi

BLOCK="$(cat <<EOF
<!-- VERIFY:BEGIN -->
## Verification (automatikus)

- Dátum: \`$TS\`
- Parancs: \`./scripts/check.sh\`
- Eredmény: **$RESULT**
- Log: \`$LOG\`

### Git diff (stat)
\`\`\`text
$DIFF_STAT
\`\`\`

### Git diff (name-status)
\`\`\`text
$DIFF_NAME_STATUS
\`\`\`

EOF
)"

if [[ "$RESULT" == "FAIL" ]]; then
  BLOCK+=$'\n'"### Log vége (FAIL esetén)"$'\n'"```text"$'\n'"$TAIL_LOG"$'\n'"```"$'\n'
fi

BLOCK+="<!-- VERIFY:END -->"$'\n'

# report frissítése idempotensen marker-ekkel
if [[ -f "$REPORT" ]] && grep -q "<!-- VERIFY:BEGIN -->" "$REPORT"; then
  # csere a BEGIN/END között
  perl -0777 -pe 's/<!-- VERIFY:BEGIN -->.*?<!-- VERIFY:END -->/'"$(printf '%s' "$BLOCK" | perl -pe 's/\\/\\\\/g; s/\$/\\\$/g')"'/s' \
    "$REPORT" > "${REPORT}.tmp"
  mv "${REPORT}.tmp" "$REPORT"
else
  # ha nincs report, vagy nincs marker: appendeljük a blokkot
  if [[ ! -f "$REPORT" ]]; then
    cat > "$REPORT" <<EOF
## Report

EOF
  fi
  printf "\n%s\n" "$BLOCK" >> "$REPORT"
fi

if [[ "$RESULT" == "FAIL" ]]; then
  echo "[VERIFY] FAIL – részletek: $LOG (és a report frissítve: $REPORT)" >&2
  exit "$EXIT_CODE"
fi

echo "[VERIFY] PASS – report frissítve: $REPORT"
