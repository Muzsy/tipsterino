# AGENTS.md — Tipsterino (Codex / AI agent guide)

## Projekt cél
A Tipsterino újraépítése tiszta `app/` Flutter struktúrával, a régi rendszerből átemelhető minták kontrollált újrahasznosításával.

## Repo-szabályok
- **`app/` az egyetlen fejlesztési célpont.**
- Doksik: `canvases/`, `codex/`, `documents/`, `docs/`.
- Ha van `legacy/` mappa: **read-only referencia** (nem módosítjuk, nem „tűzoltunk” benne).
- **Semmilyen titok/kulcs/azonosító nem kerülhet commitolásra.**
- Flutter parancsot nem futtatunk közvetlenül `flutter ...` formában; mindig wrapperen keresztül.

## Repo gyors térkép
- `app/` – Flutter app (ide kerül minden implementáció).
- `scripts/` – futtatási/ellenőrzési belépési pontok.
- `documents/` – specifikációk, döntések, konfigurációs leírások.
- `canvases/`, `codex/` – agent workflow artefaktok.

## Secrets / Supabase konfiguráció (DO NOT COMMIT)
A kliens futásához szükséges Supabase runtime értékek **lokális, gitignored** fájlban vannak:
- **Lokális fájl:** `app/.env` *(nem kerülhet gitbe)*
- **Sablon:** `app/.env.example` *(commitolható)*

Elvárás:
- `app/.env` tipikusan tartalmazza:
  - `SUPABASE_URL`
  - `SUPABASE_ANON_KEY`
- Az `ANON_KEY` a Supabase modellben „public”, de a repóba akkor sem kerülhet be; a védelem alapja az **RLS**.
- **Tilos** kliens oldalon tárolni (és tilos repo-ba írni): `SUPABASE_SERVICE_ROLE_KEY` / `service_role`, DB jelszó/connection string, JWT/encryption secret, webhook/3rd-party master API key.
- Edge Function „igazi” titkok: Supabase oldalon (Dashboard / CLI `supabase secrets set ...`).

## Futtatás / tesztelés (kötelező belépési pontok)
A Flutter parancsokat **nem közvetlenül** kell futtatni, hanem a wrapper scripteken keresztül:
- **Minden Flutter parancs:** `./scripts/flutter.sh <cmd>`
- **Standard ellenőrzés:** `./scripts/check.sh`

Indok:
- A fejlesztői környezetben a `scripts/flutter.sh` a lokális `app/.env` alapján biztosítja a szükséges runtime beállításokat (pl. `--dart-define` injektálás), így az app és a tesztek ugyanazzal a konfigurációval futnak.

Megjegyzés:
- Ha több env kell, a wrapper támogathat override-ot (pl. `TIPSTERINO_ENV_FILE=/abs/path/to/.env`). A konkrét mechanizmus a `scripts/flutter.sh` aktuális implementációja.

## Codex/AI agent elvárások
- Ne írd ki és ne logold a titkokat (még részben sem).
- Ne javasolj olyan megoldást, ami kulcsokat `.dart`, `.json`, `.yaml`, `.vscode/*` vagy bármilyen verziózott fájlba ír.
- Ha build/run/test hibát vizsgálsz, **elsőként** ellenőrizd:
  1) a futtatás a `./scripts/flutter.sh`-on keresztül történt-e,
  2) az `app/.env` létezik-e lokálisan,
  3) a szükséges `--dart-define` paraméterek ténylegesen átmentek-e (a wrapper feladata).
- Ha új környezeti kulcs kell, akkor:
  - add hozzá az `app/.env.example`-hez,
  - dokumentáld itt az AGENTS.md-ben,
  - a wrapper injektálási logikáját is frissítsd,
  - az `app/.env` továbbra is lokális és gitignored.

## Forrás-igazság
Ha ellentmondás van:
1) `documents/` specifikáció (ha van)
2) `app/` aktuális implementáció + tesztek
3) `legacy/` csak referencia (nem mérvadó)
