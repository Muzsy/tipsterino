# AGENTS.md — Tipsterino (Codex / AI agent guide)

## Projekt cél

A Tipsterino újraépítése tiszta `app/` Flutter struktúrával, a régi rendszerből átemelhető minták kontrollált újrahasznosításával.

Ez a fájl az AI agent futás közbeni **elsődleges szabálygyűjteménye**. Minden Codex feladat előtt ezt kell elolvasni.

---

## Repo-szabályok (nem alkuképes)

* **`app/` az egyetlen fejlesztési célpont.**

  * `docs/`, `documents/`, `canvases/`, `codex/` dokumentáció/folyamat artefakt.
  * Ha van `legacy/` mappa: **read-only referencia** (nem módosítjuk, nem „tűzoltunk” benne).
* **Valós repó elv:** nem találhatsz ki nem létező fájlokat, route-okat, l10n kulcsokat, szolgáltatásokat.
* **Codex outputs szabály:** csak olyan fájlt hozhatsz létre / módosíthatsz, ami szerepel a feladat YAML step `outputs` listájában.
* **Semmilyen titok/kulcs/azonosító nem kerülhet commitolásra.** (még részben sem, logban sem)
* **Flutter parancsot nem futtatunk közvetlenül** `flutter ...` formában; mindig wrapperen keresztül.

---

## Dokumentációs „szabványcsomag” (current source of truth)

A Codex workflow és szabályrendszer a `docs/` alatt van rögzítve.

### Codex workflow

* `docs/codex/overview.md` – teljes workflow + DoD
* `docs/codex/prompt_template.md` – egységes Codex prompt sablon
* `docs/codex/yaml_schema.md` – az egyetlen elfogadott goal YAML séma

### QA / teszt

* `docs/qa/testing_guidelines.md` – tesztelési minimum és stabilitási szabályok
* `docs/qa/dry_run_checklist.md` – implementáció előtti ellenőrzőlista

### Architektúra

* `docs/architect/project_structure.md` – feature-first mappázási szabvány
* `docs/architect/routing_integrity.md` – routing/go_router szabályok
* `docs/architect/theme_rules.md` – Material 3 + token alapú theming szabályok
* `docs/architect/service_dependencies.md` – szolgáltatásfüggőségi réteghatárok (Supabase)

### Lokalizáció

* `docs/localization/localization_logic.md` – HU/EN i18n szabályok (ARB + AppLocalizations)

---

## Repo gyors térkép

* `app/` – Flutter app (minden implementáció ide kerül)
* `scripts/` – futtatási/ellenőrzési belépési pontok
* `docs/` – szabályok, architektúra, Codex workflow (source of truth)
* `documents/` – specifikációk, döntések, üzleti leírások
* `canvases/` – feladat specifikációk (canvasok)
* `codex/` – goal YAML-ek + checklistek + riportok

---

## Codex munkafolyamat (kötelező keret)

Minden feladat egy `TASK_SLUG` köré szerveződik, és a következő artefaktokat hozza létre/frissíti:

* `canvases/<TASK_SLUG>.md`
* `codex/goals/canvases/fill_canvas_<TASK_SLUG>.yaml`
* `codex/codex_checklist/<TASK_SLUG>.md`
* `codex/reports/<TASK_SLUG>.md`

Kötelező sorrend:

1. Felderítés (valós fájlok + minták)
2. Canvas megírása
3. Goal YAML (steps + outputs)
4. Implementáció a YAML szerint
5. Teszt/ellenőrzés futtatása (wrapper)
6. Checklist + report kitöltése

Részletek: `docs/codex/overview.md`

---

## Secrets / Supabase konfiguráció (DO NOT COMMIT)

A kliens futásához szükséges Supabase runtime értékek **lokális, gitignored** fájlban vannak:

* **Lokális fájl:** `app/.env` *(nem kerülhet gitbe)*
* **Sablon:** `app/.env.example` *(commitolható)*

Elvárás:

* `app/.env` tipikusan tartalmazza:

  * `SUPABASE_URL`
  * `SUPABASE_ANON_KEY`
* Az `ANON_KEY` a Supabase modellben „public”, de a repóba akkor sem kerülhet be; a védelem alapja az **RLS**.
* **Tilos** kliens oldalon tárolni (és tilos repo-ba írni): `SUPABASE_SERVICE_ROLE_KEY` / `service_role`, DB jelszó/connection string, JWT/encryption secret, webhook/3rd-party master API key.
* Edge Function „igazi” titkok: Supabase oldalon (Dashboard / CLI `supabase secrets set ...`).

Szolgáltatásfüggőségi elvek: `docs/architect/service_dependencies.md`

---

## Futtatás / tesztelés (kötelező belépési pontok)

A Flutter parancsokat **nem közvetlenül** kell futtatni, hanem a wrapper scripteken keresztül:

* **Minden Flutter parancs:** `./scripts/flutter.sh <cmd>`
* **Standard ellenőrzés:** `./scripts/check.sh`

Indok:

* A `scripts/flutter.sh` a lokális `app/.env` alapján biztosítja a szükséges runtime beállításokat (pl. `--dart-define` injektálás), így az app és a tesztek ugyanazzal a konfigurációval futnak.

Tesztelési minimum: `docs/qa/testing_guidelines.md`

---

## Routing / Lokalizáció / Theme – kötelező irányok

* **Routing:** router/go_router a központi router fájlban; tilos ad-hoc `Navigator.push`, ha router az alap.

  * Részletek: `docs/architect/routing_integrity.md`
* **Lokalizáció:** nincs hardcode UI szöveg; minden új szöveg EN+HU ARB.

  * Részletek: `docs/localization/localization_logic.md`
* **Theme:** token alapú UI (ColorScheme/TextTheme); tilos hardcode hex színek widgetekben.

  * Részletek: `docs/architect/theme_rules.md`

---

## Codex/AI agent „tiltások” (gyakori hibák)

* Ne módosíts `.env` fájlt és ne írd ki/logold a tartalmát.
* Ne vezess be új architektúrát/DI rendszert csak úgy; ha kell, külön canvas+yaml feladat.
* Ne szórd szét a konfigurációt (route/theme/l10n) több helyre; központosíts a docs szerint.
* Ne építs UI-ból közvetlen Supabase hívást; réteghatárok kötelezők.
* Ne hagyj félkész állapotot: ha valami nem megy (teszt/piros), dokumentáld a reportban és javasolj fixet.

---

## Forrás-igazság (prioritás, ha ellentmondás van)

1. `AGENTS.md`
2. `documents/` specifikációk (ha vannak az adott témára)
3. `docs/` szabályok (Codex/QA/Architect/Localization)
4. `app/` aktuális implementáció + tesztek
5. `canvases/` és `codex/` futási artefaktok (feladat-specifikusak)
6. `legacy/` csak referencia (nem mérvadó)
