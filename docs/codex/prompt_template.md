# Tipsterino Codex – Prompt sablon (prompt_template.md)

> Ez a sablon a Tipsterino repóban futtatott Codex feladatok **egységes bemenete**. A cél a determinisztikus, auditálható végrehajtás: **felderítés → canvas → YAML → implementáció → teszt → report**.

---

## 🎯 Funkció

Egy olyan „minden feladatra jó” prompt váz, ami:

* kényszeríti a Codexet a repó-szabályok betartására,
* minden feladatnál legeneráltatja a kötelező artefaktokat (canvas+yaml+checklist+report),
* biztosítja a routing/theme/lokalizáció/test konzisztenciát.

---

## 🧠 Fejlesztési részletek

## 0) Használat

* Másold ki ezt a sablont.
* Töltsd ki a `<>` helyőrzőket.
* Add a Codexnek egyben.

**TASK_SLUG konvenció:**

* kisbetű
* szavak `_`-al elválasztva
* legyen beszédes, stabil

Példa: `user_events_table_doc`, `routing_go_router_guards`, `theme_tokens_phase1`.

---

## 1) Kötelező bemenetek (a prompt kitöltéséhez)

* **TASK_TITLE:** `<rövid cím>`
* **TASK_SLUG:** `<egyedi azonosító>`
* **CÉL:** `<1-3 mondat>`
* **NEM CÉL:** `<mi NEM része>`
* **SCOPE:** `<érintett modulok / képernyők / fájlcsoportok, ha ismert>`
* **KOCKÁZAT:** `<ha van, pl. routing refaktor>`
* **ELVÁRT TESZT:** `<minimum elvárás>`

---

## 2) Tipsterino Codex Task Prompt (COPY-PASTE)

```text
# Tipsterino Codex Task — <TASK_TITLE>
TASK_SLUG: <TASK_SLUG>

## 1) Kötelező olvasnivaló (prioritási sorrend)
Olvasd el és tartsd be, ebben a sorrendben:
1) AGENTS.md (repo-szabályok: fókusz, wrapper parancsok, secret-kezelés)
2) docs/codex/overview.md (Codex workflow és DoD)
3) docs/codex/yaml_schema.md (steps-séma kötelező)
4) docs/qa/testing_guidelines.md (tesztelési minimum és parancsok)
5) docs/architect/routing_integrity.md (ha routing érintett)
6) docs/architect/theme_rules.md (ha UI/theme érintett)
7) docs/localization/localization_logic.md (ha UI szöveg érintett)

Ha bármelyik fájl nem létezik: állj meg, és írd le pontosan mit kerestél, és hol.

## 2) Cél
<CÉL>

## 3) Nem cél
<NEM CÉL>

## 4) Kötelező kimenetek (hozd létre / frissítsd)
1) canvases/<TASK_SLUG>.md
2) codex/goals/canvases/fill_canvas_<TASK_SLUG>.yaml
3) codex/codex_checklist/<TASK_SLUG>.md
4) codex/reports/<TASK_SLUG>.md

## 5) Munkaszabályok (nem alkuképes)
- Valós repó elv: nem találhatsz ki fájlokat, osztályokat, route-okat, kulcsokat.
- Csak a ténylegesen létező fájlokra hivatkozz.
- A fejlesztési célpont az alkalmazás kódja: app/ (ha a repó így van felépítve).
- Referencia tartalom (legacy/backup_docs) nem módosítható, csak hivatkozható.
- Csak olyan fájlt módosíthatsz, ami szerepel az adott YAML step outputs listájában.
- Minimal-invazív változtatás: meglévő működés nem romolhat.

## 6) Kötelező workflow (nem ugorható át)
### 6.1 Felderítés
- Keresd meg a feladathoz releváns meglévő mintákat és fájlokat.
- Írj egy rövid listát: "Talált releváns fájlok" (útvonal + miért releváns).

### 6.2 Canvas létrehozása
Hozd létre a canvases/<TASK_SLUG>.md fájlt a kötelező szekciókkal:
- 🎯 Funkció
- 🧠 Fejlesztési részletek
- 🧪 Tesztállapot
- 🌍 Lokalizáció
- 📎 Kapcsolódások

A canvas tartalmazzon:
- pipálható feladatlistát
- érintett fájlok listáját (csak létező utak)
- kockázatok + rollback tervet
- teszt tervet (milyen tesztet bővítesz / írsz)

### 6.3 Goal YAML létrehozása
Hozd létre a codex/goals/canvases/fill_canvas_<TASK_SLUG>.yaml fájlt.
Kizárólag a Tipsterino steps-sémát használd:

steps:
  - name: "..."
    description: >
      ...
    outputs:
      - "..."

Szabály:
- minden módosított/létrehozott fájl szerepeljen valamely step outputs listájában
- legyen külön step a teszt/ellenőrzés futtatására

### 6.4 Codex checklist + report
- Hozd létre/frissítsd: codex/codex_checklist/<TASK_SLUG>.md
  - legyen benne pipálható DoD lista és feladat-specifikus pontok
- Hozd létre/frissítsd: codex/reports/<TASK_SLUG>.md
  - ide kerül a futtatások eredménye és a változások összefoglalója

### 6.5 Implementáció
- Hajtsd végre a YAML steps lépéseit sorrendben.
- Csak a step outputs fájlokat módosíthatod.

### 6.6 Teszt és ellenőrzés
- Futtasd a repó standard ellenőrzését wrapperrel (ha van):
  - ./scripts/check.sh
- Ha nincs wrapper, futtasd legalább:
  - flutter analyze
  - flutter test

### 6.7 Zárás
- Töltsd ki a checklistet (pipáld ami kész).
- A report tartalmazza:
  - futtatott parancsok
  - kimenet rövid összefoglaló
  - módosított/létrehozott fájlok listája
  - hiba esetén log + fix javaslat

## 7) Feladat-specifikus részletek
<SCOPE>

## 8) Output elvárás
A végén add meg a módosított/létrehozott fájlok teljes tartalmát (nem diffet), fájlonként külön blokkokban.

```

---

## 🧪 Tesztállapot

### Minimum elvárások (prompt szinten)

* UI változás → legalább 1 widget teszt frissítése vagy új widget teszt.
* Routing változás → widget smoke teszt a fő navigációs flow-ra.
* Lokalizáció változás → mindkét ARB frissítve, és nincs hiányzó kulcs.
* Domain logika → unit teszt.

---

## 🌍 Lokalizáció

### Kötelező szabályok a promptban (ha UI szöveg érintett)

* Új UI szöveg → `app/lib/l10n/app_en.arb` + `app/lib/l10n/app_hu.arb`.
* Nincs hardcode string.
* Kulcsnév prefix feature-first szerint.

---

## 📎 Kapcsolódások

### Kapcsolódó dokumentumok (várható)

* `docs/codex/overview.md`
* `docs/codex/yaml_schema.md`
* `docs/qa/testing_guidelines.md`
* `docs/architect/routing_integrity.md`
* `docs/architect/theme_rules.md`
* `docs/localization/localization_logic.md`

### Kapcsolódó repó könyvtárak

* `canvases/`
* `codex/goals/canvases/`
* `codex/codex_checklist/`
* `codex/reports/`
* `app/`
