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

1. **Canvas (feladatleírás):**

   * `canvases/<TASK_SLUG>.md`

2. **Goal YAML (végrehajtási lépések):**

   * `codex/goals/canvases/fill_canvas_<TASK_SLUG>.yaml`

3. **Codex checklist (pipálható minőségkapu):**

   * `codex/codex_checklist/<TASK_SLUG>.md`

4. **Codex report (futtatások + eredmények):**

   * `codex/reports/<TASK_SLUG>.md`

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

* Minden lépés legyen kicsi és ellenőrizhető (1–4 fájl ideális).
* **Csak** olyan fájlt szabad módosítani, ami szerepel az adott lépés `outputs` listájában.
* A lépések végén legyen legalább egy „ellenőrzés” jellegű lépés (analyze/test/run).

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
5. **Teszt/ellenőrzés futtatása:** wrapper scriptekkel.
6. **Checklist + report kitöltése:** auditálható végeredmény.

### 8) Definition of Done (DoD)

Egy feladat akkor tekinthető késznek, ha:

* [ ] Canvas és goal YAML létre van hozva, helyes könyvtárban
* [ ] Implementáció a YAML steps alapján elkészült
* [ ] Lokalizáció/route/theme szabályok teljesülnek (ha érintett)
* [ ] Tesztek és analyze lefutottak (vagy dokumentált okból nem)
* [ ] Checklist kipipálva
* [ ] Report tartalmazza: futtatott parancsok, eredmény, módosított fájlok listája

---

## 🧪 Tesztállapot

### Kötelező minimum ellenőrzések

A repóban rögzített standard wrapper parancsokat kell használni (ha vannak), tipikusan:

* `flutter analyze`
* `flutter test`

Ha a repó biztosít wrapper scripteket (ajánlott):

* `./scripts/check.sh`

### Mikor kell plusz teszt?

* Routing módosítás → legalább 1 widget smoke teszt a fontos flow-ra.
* Lokalizáció kulcsok → l10n teszt vagy egyszerű „kulcs létezik” ellenőrzés.
* Domain logika → unit teszt.

### Report kötelező mezők

A `codex/reports/<TASK_SLUG>.md` tartalmazza:

* futtatott parancsok (pontos)
* kimenet rövid összefoglaló
* hiba esetén: log részlet + javítási javaslat
* módosított/létrehozott fájlok listája

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
