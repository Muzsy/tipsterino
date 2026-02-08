# Report Standard v2 (Codex)

**Cél:** egységes, auditálható report minden canvas+yaml futás után, amelyből gyorsan ellenőrizhető:

* mi készült el,
* hogyan lett verifikálva (parancsok + eredmények),
* a DoD pontok hol teljesülnek a kódban (bizonyítékokkal),
* és milyen nem-blokkoló UX/termék észrevételek merültek fel.

Ez a dokumentum a **kötelező** report struktúrát írja le. A Codex csak akkor adhat **PASS** státuszt, ha a **DoD → Evidence Matrix** minden pontja ki van töltve, és a kötelező verifikációs parancsok lefutottak.

---

## 0) Kötelező kimeneti státusz

A report elején pontosan egyet válassz ezek közül:

* **PASS** – minden DoD teljesült, verifikáció zöld.
* **FAIL** – legalább egy DoD nem teljesült VAGY verifikáció piros.
* **PASS_WITH_NOTES** – DoD teljesült és verifikáció zöld, de vannak nem-blokkoló megjegyzések.

> **Szabály:** UX/termék jellegű észrevétel **nem lehet FAIL oka** önmagában. Ezek az **Advisory notes** szekcióba kerülnek.

---

## 1) Meta

* **Task slug:** `<pl. events_inbox_filter_bar>`
* **Kapcsolódó canvas:** `<canvases/...>`
* **Kapcsolódó goal YAML:** `<codex/goals/...>`
* **Futás dátuma:** `<YYYY-MM-DD>`
* **Branch / commit:** `<branch + commit hash>`
* **Fókusz terület:** `UI | State | DB | Docs | Localization | Routing | Mixed`

---

## 2) Scope

### 2.1 Cél

1–5 bulletben foglald össze, mit kellett elérni.

### 2.2 Nem-cél (explicit)

1–5 bullet: mi **nem** része ennek a feladatnak.

---

## 3) Változások összefoglalója (Change summary)

### 3.1 Érintett fájlok

**Kötelező:** sorold fel a módosított/létrehozott fájlokat csoportosítva.

Példa:

* **UI:**

  * `app/lib/.../events_inbox_screen.dart`
  * `app/lib/.../filter_bar.dart`
* **State / Logic:**

  * `app/lib/.../user_events_state.dart`
* **Docs:**

  * `docs/screens/events_inbox.md`

### 3.2 Miért változtak?

1–2 mondat / csoport (UI/State/DB/Docs), nem fájlonként regényt.

---

## 4) Verifikáció (How tested)

### 4.1 Kötelező parancsok

**Kötelező:** minden futtatott parancsot listázz, és írd oda a kimenetet röviden.

* `./scripts/check.sh` → `PASS|FAIL` + 1 sor összegzés

### 4.2 Opcionális, feladatfüggő parancsok

Csak ha releváns:

* DB migráció / RLS / RPC:

  * `./scripts/supabase.sh db push` → eredmény
  * `psql ... -f supabase/sql_checks/<...>.sql` → eredmény
* Lokalizáció:

  * `<nálatok használt parancs>` → eredmény
* Flutter / Dart extra:

  * `flutter test ...` (ha külön futott) → eredmény

### 4.3 Ha valami kimaradt

Ha bármely kötelező/elfogadott ellenőrzés nem futott:

* miért maradt ki,
* milyen kockázat,
* mi az elvárt pótlólagos ellenőrzés.

---

## 5) DoD → Evidence Matrix (kötelező)

**Ez a report legfontosabb része.**

### Szabályok

* A canvas DoD pontjait **1:1-ben** sorold fel.
* Minden ponthoz adj **bizonyítékot**:

  * fájlútvonal + sorsáv (pl. `app/lib/.../file.dart:L120-L180`),
  * rövid magyarázat (1–3 mondat),
  * és ha van: kapcsolódó teszt/ellenőrzés.
* Ha nincs bizonyíték vagy a DoD nem teljesült: **FAIL**.

### Minta táblázat

| DoD pont |   Státusz | Bizonyíték (path + line) | Magyarázat | Kapcsolódó teszt/ellenőrzés |
| -------- | --------: | ------------------------ | ---------- | --------------------------- |
| #1 …     | PASS/FAIL | `app/lib/...:Lx-Ly`      | …          | `./scripts/check.sh`        |
| #2 …     | PASS/FAIL | `...`                    | …          | `...`                       |

---

## 6) Lokalizáció (ha releváns)

Ha a feladat érint lokalizációt:

### 6.1 Új/módosított kulcsok

Ajánlott táblázat:

| key   | hu    | en    | used_in       |
| ----- | ----- | ----- | ------------- |
| `...` | `...` | `...` | `app/lib/...` |

### 6.2 Megjegyzések

* fallback logika, plural, formázás, stb.

---

## 7) Doksi szinkron (ha releváns)

* Mely doksik frissültek?
* Hol lett linkelve (README / docs index)?
* Van-e új canvas hivatkozás?

---

## 8) Advisory notes (nem blokkoló)

**Cél:** ide kerül minden olyan észrevétel, ami nem build/test hiba és nem DoD-sértés, hanem termék/UX döntés vagy finomhangolás.

Szabályok:

* **Max 5 bullet.**
* Legyen tömör és döntés-orientált ("A vagy B").
* Ne írj hosszú esszét.

Példa:

* (UX) A filterek között van olyan, ami garantáltan üres; döntés: elrejtsük MVP-ben vagy tegyük disabled + “coming soon” jelzéssel?
* (Termék) Üres állapot szöveg (title/body) konzisztencia: egységesítsük most vagy későbbi finomítási task?

---

## 9) Follow-ups (opcionális)

Ha vannak javasolt következő lépések:

* 1–5 bullet
* mindegyikhez: miért, és milyen kockázat/nyereség.

---

## 10) Appendix (opcionális)

* Releváns log kivonatok (max 30–50 sor)
* Linkek belső docokra/canvasekre
* Diagramok (ha tényleg segít)
