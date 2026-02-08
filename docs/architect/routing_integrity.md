# Tipsterino – Routing integritás (routing_integrity.md)

## 🎯 Funkció

Ez a dokumentum rögzíti a Tipsterino app routing szabályait, hogy a navigáció:

* konzisztens legyen,
* könnyen karbantartható maradjon,
* és a Codex ne vezessen be ad-hoc megoldásokat (pl. `Navigator.push`) ott, ahol a projekt router alapú.

**Cél:** minden route egyetlen, központi helyen definiált, tesztelhető és dokumentált.

---

## 🧠 Fejlesztési részletek

## 1) Alapelvek

* **Egyetlen forráshely:** a route definíciók központi router fájlban vannak.
* **Nincs ad-hoc navigáció:** ha router/go_router az alap, akkor tilos közvetlen `Navigator.push`-t használni.
* **Determinista route név:** a route-ok nevei stabilak, és konvenció szerint elnevezettek.
* **Képernyő = route:** a navigálható screeneknek route-ja van (kivéve belső dialog/bottomsheet).

---

## 2) Route definíciók helye

A Codex felderítéssel azonosítja a valós router fájl(oka)t.
Tipikusan (példa):

* `app/lib/src/router/app_router.dart`

**Szabály:** új route-ot csak itt (vagy a projekt által kijelölt router modulban) szabad felvenni.

---

## 3) go_router szabályok (ha a projekt ezt használja)

### 3.1 Route név konvenció

* `lower_snake_case`
* feature-first logika

Példa:

* `auth_login`
* `home`
* `ticket_detail`
* `profile_settings`

**Kerülendő:**

* `Screen1`, `pageA`, `testRoute`

### 3.2 Path konvenció

* rövid, olvasható
* paraméterek explicit

Példa:

* `/auth/login`
* `/ticket/:ticketId`

### 3.3 Params és extras

* Az URL-ben azonosító (`:id`) csak akkor, ha tényleg route-szintű paraméter.
* Komplex objektumot lehetőleg ne route extra-ként adj át, inkább id + repository fetch.

### 3.4 Redirect és guardok

* Auth-guard/redirect legyen központi, nem screenekben szétszórt.
* Redirect logikát unit teszttel (vagy widget smoke-kal) védd, ha kritikus.

---

## 4) Navigation használat a kódban

### 4.1 Router-alapú navigáció

* `context.goNamed('route_name')`
* `context.pushNamed('route_name')`
* `context.pop()`

**Szabály:** a navigáció a route névhez kötődik, nem direkt widget-példányhoz.

### 4.2 Tiltott minták

* `Navigator.push(...)`
* `MaterialPageRoute(...)`

Kivételek:

* csak akkor, ha a projektben kifejezetten engedélyezett egyedi modal flow-ra, és dokumentálva van.

---

## 5) Új képernyő (screen) bekötésének kötelező lépései

1. **Screen fájl létrehozása** a projekt mappázási szabvány szerint (feature-first).
2. **Route definíció** felvétele a központi router modulban.
3. **Navigation entry point** frissítése (pl. menü, gomb, tile, deep link).
4. **Lokalizáció**: a screen UI szövegek mind lokalizáltak.
5. **Teszt**: minimum 1 widget smoke teszt, hogy a route elérhető és renderel.
6. **Dokumentálás**: canvas + report frissítése.

---

## 6) Deep link és URL struktúra

Ha a projekt webet is céloz, vagy deep link támogatás kell:

* path-ok legyenek stabilak
* paraméterek validációja legyen megoldva (invalid id → error/404 screen)

**Szabály:** ha bevezetjük a deep linket, arról külön canvas+yaml feladat készül.

---

## 7) Routing tesztelés

### 7.1 Minimum: widget smoke teszt

* Betölti az appot a routerrel
* Navigál egy route-ra
* Ellenőrzi, hogy a screen kulcseleme megjelenik

### 7.2 Auth guard tesztelés

* Ha van auth redirect:

  * anonymous user → auth screen
  * logged-in user → protected screen

A konkrét megoldás a projekt auth architektúrájától függ.

---

## 8) Codex szabályok routing feladatoknál

### 8.1 Kötelező YAML step

Routing érintése esetén a YAML tartalmazzon külön lépést:

* route definíció módosítására
* és külön lépést:

  * widget smoke teszt hozzáadására/frissítésére
  * minőségkapu futtatására (`./scripts/verify.sh` vagy `./scripts/check.sh`; fallback: `flutter analyze` + `flutter test`)

### 8.2 Kötelező outputs

* router fájl(ok)
* érintett screen(ek)
* érintett tesztfájl(ok)
* report

---

## 🧪 Tesztállapot

### Definition of Done (Routing)

* [ ] Minden új route a központi routerben definiált
* [ ] Nincs `Navigator.push` (ha go_router a szabvány)
* [ ] Route név és path konzisztens
* [ ] Van legalább 1 widget smoke teszt a változásra
* [ ] `flutter analyze` + `flutter test` lefut (vagy dokumentált ok)

---

## 🌍 Lokalizáció

Routing önmagában nem lokalizációs téma, de:

* a navigációs címkék (menü, CTA) lokalizáltak
* error/404 screen szövegei lokalizáltak

---

## 📎 Kapcsolódások

* `docs/codex/overview.md`
* `docs/codex/prompt_template.md`
* `docs/codex/yaml_schema.md`
* `docs/qa/testing_guidelines.md`
* `docs/localization/localization_logic.md`
* `docs/architect/theme_rules.md`
