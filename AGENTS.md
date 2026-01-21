# AGENTS.md — Tipsterino (Codex / AI agent guide)

## Projekt cél
A Tipsterino újraépítése tiszta `app/` Flutter struktúrával.

## Repo-szabályok
- `app/` az egyetlen fejlesztési célpont.
- `legacy/` read-only referencia (ne javítgass benne, ne ott “tűzolj”).
- Minden futtatás (run/test/analyze/build) `app/`-ből induljon.

## Forrás-igazság
Ha ellentmondás van:
1) `documents/` specifikáció (ha van)
2) `app/` aktuális implementáció + tesztek
3) `legacy/` csak mintakód (nem mérvadó)
