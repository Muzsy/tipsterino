# Tipsterino – Service dependencies (service_dependencies.md)

## 🎯 Funkció

Ez a dokumentum rögzíti a Tipsterino projekt **külső szolgáltatásfüggőségeinek** és a hozzájuk kapcsolódó kódszervezési szabályoknak a minimumát.

Cél:

* a Codex ne építsen be „közvetlen” klienshívásokat UI-ból,
* a szolgáltatásfüggőségek legyenek cserélhetők (mockolhatók),
* a Supabase-alapú stack integrációja konzisztens legyen.

---

## 🧠 Fejlesztési részletek

## 1) Alapelv: UI nem beszél közvetlenül szolgáltatással

**Tilos:**

* UI widgetből közvetlenül Supabase kliens hívása
* hálózati hívások a build() közben

**Kötelező rétegek (minimum):**

* UI → (controller/state) → service/use-case → repository → client adapter

A konkrét állapotkezelés (provider/riverpod/bloc) a projekttől függ, de a réteghatár elv kötelező.

---

## 2) Tipsterino backend stack

A projekt backendje **Supabase** (Auth + RLS + Realtime + Edge Functions + Storage).

**Szabály:** a Codex nem említhet Firebase-t és nem építhet be Firebase-hez kötődő mintákat.

---

## 3) Függőségek kategóriái

### 3.1 Auth

* Supabase Auth a hitelesítés forrása.
* UI csak a saját auth state/service rétegen keresztül kérdez.

### 3.2 Adatbázis

* Supabase Postgres + RLS.
* A kliens oldali repository réteg csak a számára kijelölt táblákhoz fér hozzá.

### 3.3 Edge Functions

* Csak indokolt üzleti logika kerüljön Edge Function-be.
* Kliens oldalon egy “function client”/adapter rétegen keresztül hívjuk.

### 3.4 Storage

* Fájlkezelés (pl. avatar) Storage-on keresztül.
* Feltöltés/letöltés adapteren keresztül, mockolható módon.

### 3.5 Realtime

* Realtime subscriptionokat ne screen-szinten szórjuk szét.
* Egy „realtime service” menedzselje, és csak a szükséges state-be csatolja be.

---

## 4) Konfiguráció és secret-kezelés

### 4.1 Secret-ek

* Supabase URL és anon key nem kerülhet commitba, ha a repó szabályai tiltják.
* A valós szabályokat az `AGENTS.md` és a repo `.env` minták határozzák meg.

### 4.2 Környezetek

* Dev/stage/prod csak akkor, ha a repó ezt támogatja.
* A Codex nem találhat ki új env rendszert; ha szükséges, külön canvas+yaml feladat.

---

## 5) Dependency Injection (DI) és mockolhatóság

### 5.1 Kötelező elv

* Minden külső szolgáltatás (Supabase, storage, function client) legyen **injektálható**.
* Tesztben mock/fake implementációval cserélhető.

### 5.2 Hol történik a bekötés?

* A projektnek legyen egy kijelölt „composition root” (pl. `main.dart` vagy `app_startup.dart`).
* A Codex felderítéssel azonosítja és ehhez igazodik.

**Szabály:** ne vezess be új DI rendszert (pl. get_it) csak úgy.
Ha DI refaktor kell, az külön feladat.

---

## 6) Repository szabvány

### 6.1 Interface + impl

* `XRepository` (interface)
* `SupabaseXRepository` (impl)

### 6.2 Domain model mapping

* A repository felelős a DTO ↔ domain mappingért.
* A UI csak domain modellel dolgozik.

### 6.3 Error kezelés

* A repository/service réteg adjon egységes hibastruktúrát a UI-nak.
* Ne dobáljunk nyers exceptiont UI-ig.

---

## 7) API változások és migrációk

### 7.1 Migrációk

* DB változás csak migrációval.
* A Codex migration fájlt csak akkor hoz létre, ha a feladat kifejezetten kéri.

### 7.2 RLS

* Minden új tábla/kolonna esetén RLS policy szükséges.
* Ha a projektnek van RLS standard doksija, azt kötelező követni.

---

## 8) Tesztelés külső szolgáltatásokkal

### 8.1 Unit teszt első

* Repository/service unit teszt mockolt klienssel.

### 8.2 Integration teszt csak indokoltan

* E2E flow-kra, ha a projekt rendelkezik környezettel és futtatási móddal.

**Szabály:** automata teszt ne függj élő Supabase környezettől, kivéve külön e2e suite.

---

## 9) Codex szabályok service feladatnál

### 9.1 Kötelező YAML lépések

* Interface és implementáció külön step
* UI bekötés külön step
* Teszt és report külön step

### 9.2 Kötelező outputs

* repository interface + impl
* érintett service/use-case
* érintett state/controller
* érintett UI
* teszt fájl
* report

---

## 🧪 Tesztállapot

### Definition of Done (Service dependencies)

* [ ] UI nem hív közvetlenül külső klienst
* [ ] Service/repository rétegek injektálhatók
* [ ] Van legalább 1 unit teszt a változásra
* [ ] Nincs valós hálózati hívás automata tesztben
* [ ] `flutter analyze` + `flutter test` lefut (vagy dokumentált ok)

---

## 🌍 Lokalizáció

Service logika nem lokalizáció, de:

* hibaüzenetek UI oldalon lokalizáltak legyenek
* technikai logok maradhatnak angolul (nem UI)

---

## 📎 Kapcsolódások

* `docs/codex/overview.md`
* `docs/codex/prompt_template.md`
* `docs/codex/yaml_schema.md`
* `docs/qa/testing_guidelines.md`
* `docs/architect/routing_integrity.md`
* `docs/architect/theme_rules.md`
* `docs/localization/localization_logic.md`
