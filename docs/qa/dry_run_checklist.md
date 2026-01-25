# Tipsterino – Codex Dry Run Checklist (dry_run_checklist.md)

## 🎯 Funkció

Ez a checklist egy **„száraz futás”** (dry run) ellenőrzőlista Codex feladatokhoz.

Célja:

* még a kódmódosítás előtt kiszűrni a tipikus hibákat (rossz fájlútvonal, hiányzó szabály, rossz scope, hiányzó tesztterv),
* biztosítani, hogy a canvas+yaml **végrehajtható**, a repó szabályoknak megfelelő és auditálható.

**Szabály:** a dry run checklistet a Codex **mindig** kitölti a tényleges implementáció előtt, és a feladat artefaktjai közé menti.

---

## 🧠 Fejlesztési részletek

### Kötelező fájl

* `codex/codex_checklist/<TASK_SLUG>.md`

Ebben a fájlban a DoD checklist mellett legyen benne ez a dry run rész is (vagy hivatkozás rá).

---

## 🧪 Tesztállapot

## Dry Run Checklist – pipálható

### 0) Alapok

* [ ] `TASK_SLUG` egyedi, beszédes, stabil (kisbetű, `_` elválasztás)
* [ ] A feladat célja 1–3 mondatban egyértelmű
* [ ] A „nem cél” lista konkrét (mi NEM része)
* [ ] A scope (érintett modulok/képernyők) rögzítve van

### 1) Repó-szabályok és források

* [ ] `AGENTS.md` elolvasva és a szabályok beépítve a megoldásba
* [ ] A releváns docs szabályfájlok (routing/theme/l10n/testing) azonosítva
* [ ] Ha valamelyik docs hiányzik: dokumentáltam, és nem találtam ki helyette szabályt

### 2) Valós fájlok ellenőrzése (no-hallucination)

* [ ] Minden hivatkozott fájl valóban létezik a repóban
* [ ] Minden új fájlnak megvan a pontos célkönyvtára (repo-konvenció szerint)
* [ ] Nincs kitalált route, kitalált i18n kulcs, kitalált service/endpoint

### 3) Canvas minőség (canvases/<TASK_SLUG>.md)

* [ ] A canvas tartalmazza a kötelező szekciókat:

  * [ ] 🎯 Funkció
  * [ ] 🧠 Fejlesztési részletek
  * [ ] 🧪 Tesztállapot
  * [ ] 🌍 Lokalizáció
  * [ ] 📎 Kapcsolódások
* [ ] Van pipálható feladatlista, és lépésenként végrehajtható
* [ ] Van kockázat és rollback terv (ha érint kritikus részt: routing/auth/data)
* [ ] Van konkrét tesztterv (milyen tesztet írok/frissítek)

### 4) YAML minőség (fill_canvas_<TASK_SLUG>.yaml)

* [ ] Csak a `steps/name/description/outputs` séma van használva
* [ ] A lépések kicsik és ellenőrizhetők (ideális 1–4 fájl / step)
* [ ] Minden step `description` végrehajtható, nem „gondolkodós”
* [ ] A YAML nem tartalmaz `analyze/summarize/plan` jellegű meta utasítást
* [ ] Minden módosított/létrehozott fájl szerepel valamely step `outputs` listájában
* [ ] Van külön teszt/ellenőrzés step (wrapperrel, ha létezik)

### 5) Scope és módosítási határok

* [ ] A változtatás célpontja az app kódja (tipikusan `app/`)
* [ ] Legacy/backup tartalom csak referencia, nincs módosítva
* [ ] Nem nyúlok indokolatlanul konfigurációhoz (pubspec, build files) – csak ha a feladat szükségessé teszi
* [ ] Nincs szétszórt "quick fix" több modulban; refaktor lépései világosak

### 6) Routing ellenőrzés (ha érintett)

* [ ] A route-ok egyetlen központi router fájlban vannak kezelve (repó konvenció szerint)
* [ ] Nem használok `Navigator.push`-t, ha router/go_router a szabvány
* [ ] Új route esetén: elnevezés konzisztens, és van smoke teszt terv

### 7) Lokalizáció ellenőrzés (ha UI szöveg érintett)

* [ ] Nincs hardcode UI szöveg
* [ ] Új szöveg esetén mindkét ARB frissül (EN + HU)
* [ ] Kulcsnevek feature-first prefixet használnak
* [ ] Van teszt/ellenőrzés terv a string megjelenésére

### 8) Theme/UI ellenőrzés (ha UI érintett)

* [ ] Nincs hardcode szín/typography a widgetekben
* [ ] Theme.of / ColorScheme / AppTheme használat
* [ ] UI változás esetén van widget teszt terv

### 9) Teszt és minőségkapu

* [ ] Az elvárt teszttípus kiválasztva (unit/widget/integration)
* [ ] A tesztfájl(ok) szerepel(nek) a YAML outputs listában
* [ ] A futtatási parancs rögzítve:

  * [ ] `./scripts/check.sh` (ha létezik)
  * [ ] fallback: `flutter analyze` + `flutter test`

### 10) Dokumentálás (report)

* [ ] A report fájl útvonala rögzítve: `codex/reports/<TASK_SLUG>.md`
* [ ] A reportban helye van:

  * [ ] futtatott parancsoknak
  * [ ] eredményeknek
  * [ ] módosított fájlok listájának
  * [ ] hibák log részletének + javítási javaslatnak

---

## 🌍 Lokalizáció

Ha a feladat UI-t érint, a dry run részeként ellenőrizd:

* [ ] mindkét nyelv (EN/HU) lefedett
* [ ] nincs „TODO later” lokalizáció

---

## 📎 Kapcsolódások

* `docs/codex/overview.md`
* `docs/codex/prompt_template.md`
* `docs/codex/yaml_schema.md`
* `docs/qa/testing_guidelines.md`
* `codex/codex_checklist/` (feladatspecifikus checklistek)
* `codex/reports/` (futtatási riportok)
