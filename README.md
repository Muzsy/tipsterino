# Tipsterino – monorepo (új app + legacy referencia)

Struktúra:
- `app/` – az új Flutter alkalmazás (EZ a fejlesztési célpont)
- `legacy/` – a régi alkalmazás (csak referencia; alapból nem verziózott)
- `canvases/` + `codex/` – Codex workflow (canvases + goals + reports)
- `docs/` – canonical fejlesztői dokumentáció (single source of truth)
- `documents/` – deprecated/archív dokumentumok és átirányító stubok
- `scripts/` – bootstrap + wrapper script-ek
- `tool/` – segédprogramok/validátorok (ha lesz)

## Gyors start
1) Flutter app létrehozása az `app/` mappába:
   - `./scripts/bootstrap_flutter_app.sh com.yourorg tipsterino`

2) Futás:
   - `./scripts/flutter.sh pub get`
   - `./scripts/flutter.sh run`

3) Ellenőrzés:
   - `./scripts/check.sh`

## Legacy használat
A `legacy/` mappa alapból:
- ki van zárva VS Code-ból (ne indexelje / ne analizálja)
- ki van zárva Gitből (ne nőjön a repo és ne legyen zaj)

Ha mégis keresnél benne:
- VS Code-ban kapcsold ki ideiglenesen a `files.exclude/search.exclude` legacy sorait.
