# Tipsterino Codex – Áttekintés (overview.md)

## 🎯 Funkció

Ez a dokumentum rögzíti a Tipsterino repóban használt **Codex-munkafolyamatot**: hogyan készülnek a **canvas + goal YAML** fájlok, hogyan dolgozik a Codex a kódbázisban, és mik a **kötelező minőségkapuk** (lint/analyze/test + report).

**Cél:** a Codex feladatok végrehajtása legyen determinisztikus, auditálható és repo‑kompatibilis.

**Kimenet-alapú fejlesztés:** minden érdemi változtatás előtt előbb elkészül a canvas+yaml, és csak ezután történik implementáció.

---

## 🧠 Fejlesztési részletek

### 1) Alapelvek

* **Valós repó elv:** a Codex nem találhat ki fájlokat, route-okat, kulcsokat, szolgáltatásokat. Mindent kereséssel kell azonosítani.
* **Minimal-invazív módosítás:** meglévő funkciót nem törünk; csak a szükséges részeket érintjük.
* **Egy feladat = egy slug:** minden Codex feladat kap egy egyedi `TASK_SLUG` azonosítót (pl. `user_events_table_doc`, `routing_refactor_go_router_guards`).
* **Kimenetek kötelezőek:** a feladat akkor „kész”, ha a dokumentáció + kód + teszt + report együtt megvan.

### 2) Kötelező artefaktok (minden feladathoz)

A `TASK_SLUG` alapján mindig készüljön:

> **Megjegyzés:** az `<AREA>/` opcionális domain mappa (pl. `bonus_system/`, `events_inbox/`). Ha nincs ilyen mappa, maradhatnak a fájlok a gyökérben.

1. **Canvas (feladatleírás):**

   * `canvases/[<AREA>/]<TASK_SLUG>.md`

2. **Goal YAML (végrehajtási lépések):**

   * `codex/goals/canvases/[<AREA>/]fill_canvas_<TASK_SLUG>.yaml`

3. **Codex checklist (pipálható minőségkapu):**

   * `codex/codex_checklist/[<AREA>/]<TASK_SLUG>.md`

4. **Codex report (futtatások + eredmények):**

   * `codex/reports/[<AREA>/]<TASK_SLUG>.md`
   * `codex/reports/[<AREA>/]<TASK_SLUG>.verify.log`

> **Report szabvány:** a reportot kötelezően a `docs/codex/report_standard.md` (Report Standard v2) szerint kell kitölteni (DoD→Evidence + Advisory).

> A pontos könyvtárnevek a repóban rögzített struktúrát követik. Ha egy projektben eltér, azt először dokumentálni kell, és csak utána átállni.

### 3) Canvas kötelező tartalma

A canvas feladata, hogy a Codex számára **végrehajtható specifikációt** adjon. Minimum:

* Konkrét cél és nem-cél (mi NEM része a feladatnak)
* Fájlok és érintett modulok listája (csak létező, megtalált útvonalak)
* Pipálható feladatlista
* Kockázatok + rollback terv
* Lokalizációs és routing követelmények, ha érintettek

### 4) Goal YAML séma (Tipsterino szabvány)

A goal YAML **csak** a `steps` sémát használja:

```yaml
steps:
  - name: "<lépés neve>"
    description: >
      <részletes végrehajtási leírás>
    outputs:
      - "<módosított vagy létrehozott fájl útvonala>"
```

Szabályok:

* **Kötelező:** a YAML **legutolsó** stepje legyen a **"Repo gate (automatikus verify)"** (parancs: `./scripts/verify.sh --report codex/reports/[<AREA>/]<TASK_SLUG>.md`).
* Minden lépés legyen kicsi és ellenőrizhető (1–4 fájl ideális).
* **Csak** olyan fájlt szabad módosítani, ami szerepel az adott lépés `outputs` listájában.
* A Repo gate step `outputs` listája tartalmazza a reportot **és** a hozzá tartozó logot: `codex/reports/[<AREA>/]<TASK_SLUG>.verify.log`.

### 5) Repó fókusz és modulhatárok

* A fejlesztés célpontja az alkalmazás kódja: **`app/`** (ha a repó így van felépítve).
* A `legacy/` vagy `backup_docs/` jellegű tartalom **referencia**, nem fejlesztési célpont.
* Dokumentáció mindig a `docs/` alá kerüljön, a meglévő docs-struktúrához illesztve.

### 6) Routing, lokalizáció, theme – alap konvenciók

#### Routing

* Egyetlen forráshely a route-okhoz (pl. `app/lib/src/router/...`).
* Új képernyő → route definíció + navigation konvenció követése.
* Tilos „ad-hoc” navigációs megoldásokat bevezetni (pl. közvetlen `Navigator.push`), ha a projekt `go_router`/router alapú.

#### Lokalizáció

* Minden UI szöveg lokalizált.
* Új szöveg → ARB kulcsok bővítése + generált lokalizáció frissítése.
* Kulcsnevek legyenek konzisztensen, feature‑first logikával elnevezve.

#### Theme

* Ne legyen hardcode szín/typography a widgetekben.
* AppTheme / Theme.of(context) / ColorScheme használata.
* Új UI komponens esetén előbb theme‑kompatibilis megoldás, utána csak finomhangolás.

### 7) Ajánlott Codex futási sorrend

1. **Felderítés:** releváns fájlok, szabályok, meglévő minták megkeresése.
2. **Canvas elkészítése:** specifikáció és checklist alap.
3. **Goal YAML elkészítése:** lépések + outputs.
4. **Implementáció:** lépésről lépésre, a YAML szerint.
5. **Repo gate futtatása:** `./scripts/verify.sh --report codex/reports/[<AREA>/]<TASK_SLUG>.md` (ez futtatja a standard ellenőrzést és automatikusan frissíti a reportot).
6. **Checklist + report lezárása:** checklist kipipálása + a reportban az esetleges **Advisory notes** kiegészítése (ha szükséges).

### 8) Definition of Done (DoD)

Egy feladat akkor tekinthető késznek, ha:

* [ ] Canvas és goal YAML létre van hozva, helyes könyvtárban
* [ ] Implementáció a YAML steps alapján elkészült
* [ ] Lokalizáció/route/theme szabályok teljesülnek (ha érintett)
* [ ] Repo gate lefutott (`./scripts/verify.sh`), eredmény rögzítve a reportban
* [ ] `codex/reports/[<AREA>/]<TASK_SLUG>.verify.log` létrejött és a report hivatkozik rá
* [ ] Checklist kipipálva
* [ ] Report tartalmazza: futtatott parancsok, eredmény, módosított fájlok listája, és a **Verification** blokkot (automatikusan frissítve)

---

## 6) Teszt / minőségkapu (kötelező)

A task végén minimum:

* `./scripts/verify.sh --report codex/reports/[<AREA>/]<TASK_SLUG>.md` *(a `check.sh`-t futtatja, logot ment és frissíti a reportot; ez a Codex gate)*
* `./scripts/check.sh` *(lokál gyors kapu; ha nincs verify, ez a fallback)*

---

## 🧪 Tesztállapot

### Kötelező minimum ellenőrzések

A standard minőségi kapu futtatása kötelező a wrapperen keresztül:

* `./scripts/verify.sh --report codex/reports/[<AREA>/]<TASK_SLUG>.md`

A `verify.sh` a repóban definiált ellenőrzést futtatja (tipikusan `./scripts/check.sh`, ami `flutter analyze` + `flutter test`), és elmenti a futási logot a report mellé (`codex/reports/[<AREA>/]<TASK_SLUG>.verify.log`).

### Mikor kell plusz teszt?

* Routing módosítás → legalább 1 widget smoke teszt a fontos flow-ra.
* Lokalizáció kulcsok → l10n teszt vagy egyszerű „kulcs létezik” ellenőrzés.
* Domain logika → unit teszt.

### Report kötelező mezők

A `codex/reports/[<AREA>/]<TASK_SLUG>.md` **kötelezően** a `docs/codex/report_standard.md` szerint készül.

Minimum tartalom:

* státusz: **PASS / FAIL / PASS_WITH_NOTES** (a report elején)
* futtatott parancsok (pontos) + eredmények röviden
* `verify` log hivatkozás: `codex/reports/[<AREA>/]<TASK_SLUG>.verify.log` (FAIL esetén kötelezően legyen log részlet is)
* változások összefoglalója (módosított/létrehozott fájlok listája, csoportosítva)
* **DoD → Evidence Matrix** (minden DoD ponthoz: path + sorsáv + rövid magyarázat)
* hiba esetén: log részlet + javítási javaslat
* nem-blokkoló UX/termék észrevételek kizárólag az **Advisory notes** szekcióban

---

## 🌍 Lokalizáció

### Nyelvi alapelv

* A UI-ban nincs „hardcode” szöveg.
* Minden új felirat/hibaüzenet/CTA lokalizált kulcs.

### Kulcsnév konvenció

* Feature-first jellegű prefix, pl. `auth_...`, `home_...`, `ticket_...`, `rewards_...`.
* Egy kulcs egy jelentés: ne használj „generic_ok” kulcsot mindenre, ha eltér a kontextus.

### Fallback és hiányzó kulcs

* Ha hiányzik kulcs, az hiba (nem „majd később”).
* A hiányzó kulcsokat a checklistben külön tételként jelöld.

---

## 📎 Kapcsolódások

### Kapcsolódó szabálydokumentumok (javasolt hely)

* `docs/codex/prompt_template.md` – egységes Codex prompt szabvány
* `docs/codex/yaml_schema.md` – steps-séma + példák
* `docs/codex/report_standard.md` – egységes report szabvány (DoD→Evidence + Advisory)
* `docs/qa/testing_guidelines.md` – tesztelési minimum és parancsok
* `docs/architect/routing_integrity.md` – routing szabályok
* `docs/architect/theme_rules.md` – theme/design szabályok
* `docs/localization/localization_logic.md` – l10n konvenciók

### Kötelező repó-gyökér szabályfájl

* `AGENTS.md` – a Codex futás közbeni repo-szabályok elsődleges forrása

### Tipikus feladat-sablonok

* Új képernyő bekötése (routing + l10n + UI)
* Feature-first modul bontás / refaktor
* Supabase integráció (RLS + edge function + kliens)
* User events / reward grants dokumentáció és implementáció
