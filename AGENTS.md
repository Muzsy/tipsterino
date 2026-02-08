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
* `docs/codex/report_standard.md` – Report Standard v2 (DoD→Evidence + Advisory)

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
* `docs/` – szabályok, architektúra, Codex workflow (source of truth, canonical)
* `documents/` – deprecated/archív specifikációk, átirányító stubok
* `canvases/` – feladat specifikációk (canvasok)
* `codex/` – goal YAML-ek + checklistek + riportok

---

## Codex munkafolyamat (kötelező keret)

Minden feladat egy `TASK_SLUG` köré szerveződik, és a következő artefaktokat hozza létre/frissíti:

* `canvases/[<AREA>/]<TASK_SLUG>.md`
* `codex/goals/canvases/[<AREA>/]fill_canvas_<TASK_SLUG>.yaml`
* `codex/codex_checklist/[<AREA>/]<TASK_SLUG>.md`
* `codex/reports/[<AREA>/]<TASK_SLUG>.md`
* `codex/reports/[<AREA>/]<TASK_SLUG>.verify.log` *(automatikus, a `verify.sh` írja)*

Kötelező sorrend:

1. Felderítés (valós fájlok + minták)
2. Canvas megírása
3. Goal YAML (steps + outputs)
4. Implementáció a YAML szerint
5. Repo gate futtatása (automatikus verify + log + report frissítés)

   * Kötelező parancs: `./scripts/verify.sh --report codex/reports/[<AREA>/]<TASK_SLUG>.md`
6. Checklist + report kitöltése

   * A reportot kötelezően a `docs/codex/report_standard.md` szerkezete szerint kell kitölteni.
   * A nem-blokkoló UX/termék észrevételek kizárólag az **Advisory notes** szekcióba kerülhetnek; ezek nem lehetnek FAIL okai önmagukban.
   * Használható státuszok: **PASS**, **FAIL**, **PASS_WITH_NOTES**.
  
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



## Supabase MCP (Codex) – használati szabályok

Ha a feladat **Supabase adatbázist / sémát / RLS-t / migrációt / RPC-ket / táblákat / oszlopokat / indexeket** érint, akkor **használd a Supabase MCP-t** a valós állapot ellenőrzésére, és **ne feltételezz** semmilyen mezőnevet, policy-t vagy SQL részletet.

* **Nem kötelező mindig használni.** UI-only vagy tisztán Flutter refaktor feladatnál általában nincs rá szükség.
* **Kötelező használni, ha a DB részletei befolyásolják a megoldást**, például:
  * új oszlop/constraint/index hozzáadása
  * RLS policy vagy `SECURITY DEFINER` RPC módosítás
  * query-k, filterek, joinok, view-k, trigger-ek, edge function DB-hívások
  * “mi a tábla pontos szerkezete?” típusú kérdések
* **Mindig a megfelelő projektre scopolva dolgozz** (pl. `.codex/config.toml` `project_ref=...`), és ellenőrizd a kapcsolatot (`codex mcp list`) mielőtt DB-re hivatkozol.
* **Approval / safety:** tool-hívás előtt kérj jóváhagyást az aktuális `approval_policy` szerint, és írd le röviden, mit fogsz lekérdezni / módosítani.
* **Ne dolgozz production projekten kísérletezéssel.** Ha nincs külön utasítás, feltételezd, hogy csak olvasás / felmérés megengedett.
* **Ne logolj szenzitív adatot.** Ne másolj ki rekordokat, kulcsokat, tokeneket; a cél a **séma és policy-k** ellenőrzése, nem a tartalmak dumpolása.

## Futtatás / tesztelés (kötelező belépési pontok)

A Flutter parancsokat **nem közvetlenül** kell futtatni, hanem a wrapper scripteken keresztül:

* **Minden Flutter parancs:** `./scripts/flutter.sh <cmd>`
* **Standard ellenőrzés (lokál):** `./scripts/check.sh`
* **Standard ellenőrzés (Codex / report + log):** `./scripts/verify.sh --report codex/reports/[<AREA>/]<TASK_SLUG>.md`

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
2. `docs/` szabályok (Codex/QA/Architect/Localization)
3. `documents/` deprecated/archív specifikációk (csak ha nincs frissebb `docs/` megfelelő)
4. `app/` aktuális implementáció + tesztek
5. `canvases/` és `codex/` futási artefaktok (feladat-specifikusak)
6. `legacy/` csak referencia (nem mérvadó)
