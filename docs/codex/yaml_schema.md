# Tipsterino Codex – YAML séma (yaml_schema.md)

## 🎯 Funkció

Ez a dokumentum rögzíti a Tipsterino repóban használt **egyetlen elfogadott Codex goal YAML sémát**.

**Cél:** a Codex végrehajtás legyen determinisztikus és auditálható: minden lépés explicit, minden fájl érintettsége előre deklarált.

---

## 🧠 Fejlesztési részletek

## 1) Elfogadott séma (kötelező)

A Tipsterino goal YAML-ek **kizárólag** ezt a sémát használhatják:

```yaml
steps:
  - name: "<lépés neve>"
    description: >
      <részletes, végrehajtható utasítások>
    outputs:
      - "<fájl útvonal>"
      - "<fájl útvonal>"
```

### Kötelező mezők

* `steps` (lista)
* Minden stepben:

  * `name` (string)
  * `description` (multiline string, `>` ajánlott)
  * `outputs` (string lista)

### Opcionális mezők

* `inputs` (string lista) – csak akkor, ha a lépés konkrét bemeneti fájlokra támaszkodik, és ezt auditálni akarjuk.

Példa:

```yaml
steps:
  - name: "Felderítés és érintett fájlok rögzítése"
    description: >
      Keresd meg a releváns modulokat és meglévő mintákat a repóban. Írd össze a
      talált fájlokat és helyezd el őket a canvas kapcsolódó szekciójába.
    outputs:
      - "canvases/example_task.md"

  - name: "ARB kulcsok bővítése"
    description: >
      Adj hozzá új kulcsokat mindkét ARB fájlhoz. Ellenőrizd, hogy nincs hiányzó kulcs,
      és a generált lokalizáció felveszi a változást.
    outputs:
      - "app/lib/l10n/app_en.arb"
      - "app/lib/l10n/app_hu.arb"

  - name: "Repo gate (automatikus verify)"
    description: >
      Futtasd a standard ellenőrzést és frissítsd automatikusan a reportot.
      Parancs: ./scripts/verify.sh --report codex/reports/example_task.md
    outputs:
      - "codex/reports/example_task.md"
      - "codex/reports/example_task.verify.log"
```

---

## 2) Globális szabályok (nem alkuképes)

### 2.1 Outputs szabály – fájl érintettség

* A Codex **csak** olyan fájlt hozhat létre vagy módosíthat, ami szerepel a step `outputs` listájában.
* Ha egy fájl módosítása szükséges, de nem szerepel outputsban: a YAML-t előbb frissíteni kell.

### 2.2 Egy step = ellenőrizhető egység

* Egy step legyen **kicsi** és ellenőrizhető.
* Ideális: 1–4 fájl az outputsban.
* Nagy refaktor: több stepre bontva.

### 2.3 Kizárt "meta" parancsok

A YAML nem tartalmazhat:

* `analyze`, `summarize`, `plan` jellegű parancsokat
* „csak gondold át” jellegű lépéseket

A leírásnak végrehajthatónak kell lennie.

### 2.4 Módosítási célpont

* A fejlesztés célpontja a projekt alkalmazás kódja: tipikusan `app/`.
* `legacy/`, `backup_docs/` csak referencia.

---

## 3) Step típusok (javasolt minták)

### 3.1 Felderítés (Discovery)

**Cél:** a repó valós állapotának feltérképezése, releváns fájlok rögzítése.

* outputs: tipikusan a canvas vagy egy rövid belső feljegyzés frissítése.

### 3.2 Dokumentáció (Canvas/Docs)

**Cél:** canvas megírása vagy `docs/` alatti szabályfájl frissítése.

### 3.3 Implementáció (Code)

**Cél:** konkrét kódmódosítás.

* outputs: érintett Dart fájlok, configok.

### 3.4 Lokalizáció (L10n)

**Cél:** ARB kulcsok és felhasználás.

* outputs: mindkét ARB + érintett widget.

### 3.5 Routing

**Cél:** route definíció és navigation konvenció.

* outputs: router fájl(ok) + érintett screen.

### 3.6 Teszt / Minőségkapu

**Cél:** a repo standard minőségi kapujának futtatása és az eredmény *automatikus* rögzítése a reportban.

* Ajánlott parancs: `./scripts/verify.sh --report <report_path>`
* outputs: report fájl + a verify log (a report mellett).

---

## 4) Kötelező ellenőrző lépések (minőségi gate)

Minden feladat YAML-jának **legutolsó** stepje legyen egy minőségi kapu, ami:

* lefuttatja a standard ellenőrzést a `./scripts/verify.sh` wrapperen keresztül
* a **reportot automatikusan frissíti** (PASS/FAIL + log hivatkozás)
* a logot elmenti a report mellé

**Standard parancs:**

* `./scripts/verify.sh --report codex/reports/<feature>/<name>.md`

**Standard outputs (kötelező):**

* `codex/reports/<feature>/<name>.md`
* `codex/reports/<feature>/<name>.verify.log`

Ajánlott step name: **"Repo gate (automatikus verify)"**

---

## 5) Naming konvenciók

### 5.1 YAML fájlnév

* `codex/goals/canvases/fill_canvas_<TASK_SLUG>.yaml`

### 5.2 Step name

* rövid, cselekvő ige + tárgy
* magyar nyelv

Példa:

* "ARB kulcsok bővítése"
* "Új route bekötése"
* "Widget teszt frissítése"

### 5.3 Outputs útvonal

* teljes repo relatív útvonal
* mindig idézőjelben

---

## 🧪 Tesztállapot

### Kötelező minimum

* Minden YAML **legutolsó** stepje legyen a minőségi kapu (`./scripts/verify.sh`).
 * UI változás esetén legyen tesztfájl outputsban is (új vagy frissített).

### Report kötelező

* A minőségi kapu outputs listája tartalmazza a report fájlt **és** a `.verify.log` fájlt.

---

## 🌍 Lokalizáció

### Ha UI szöveg érintett

* A YAML tartalmazzon külön stepet ARB módosításra.
* Az outputs listában szerepeljen:

  * `app/lib/l10n/app_en.arb`
  * `app/lib/l10n/app_hu.arb`

---

## 📎 Kapcsolódások

* `docs/codex/overview.md` – workflow és DoD
* `docs/codex/prompt_template.md` – egységes prompt
* docs/codex/report_standard.md` – report struktúra + AUTO_VERIFY blokk (verify.sh frissíti)
* `docs/qa/testing_guidelines.md` – tesztelvek és parancsok
* `canvases/` – feladat specifikáció
* `codex/goals/canvases/` – goal YAML-ek
* `codex/codex_checklist/` – pipálható minőségkapu
* `codex/reports/` – futási riportok
