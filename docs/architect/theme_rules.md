# Tipsterino – Theme szabályok (theme_rules.md)

## 🎯 Funkció

Ez a dokumentum rögzíti a Tipsterino app UI/theming szabályait (Material 3), hogy:

* ne legyen szétszórt hardcode dizájn,
* a felület konzisztens maradjon,
* a Codex ne vezessen be össze nem illő stílusmegoldásokat.

**Cél:** minden UI a Theme/ColorScheme/Typography tokenekből épüljön, és a design döntések központosítva legyenek.

---

## 🧠 Fejlesztési részletek

## 1) Alapelv: Material 3 + token alapú UI

* **Material 3** komponensek az alap.
* A színek és tipográfia a **ThemeData** / **ColorScheme** / **TextTheme** alapján jön.
* UI kódban **tilos** hardcode hex színeket használni (kivéve ideiglenes debug).

---

## 2) Theme forrása és szerkezete

A Codex felderítéssel azonosítja a valós theme fájlokat.
Tipikusan (példa):

* `app/lib/src/theme/app_theme.dart`

**Szabály:** a globális theme módosítások itt történnek, nem screenekben.

---

## 3) Színek – kötelező szabályok

### 3.1 Mit szabad használni?

* `Theme.of(context).colorScheme` (elsődleges)
* `Theme.of(context).brightness` (ha szükséges)
* `Theme.of(context).textTheme`

Példa:

* `final cs = Theme.of(context).colorScheme;`
* `Container(color: cs.surface)`
* `TextStyle(color: cs.onSurface)`

### 3.2 Mit TILOS?

* `Color(0xFF...)` UI komponensben
* `Colors.red` / `Colors.green` a végleges UI-ban (kivéve explicit státusz-szín token)
* saját „random” palette screen-szinten

### 3.3 Státusz színek

Ha a projektnek kell „success/warn/error” token:

* azt központosítva kell bevezetni (pl. `AppColors` / theme extension), nem ad-hoc.
* első körben az M3 `colorScheme.error` használható, de „success” nincs alapból.

---

## 4) Typography – kötelező szabályok

* Text stílus: `Theme.of(context).textTheme.*`
* Egyedi fontWeight/size csak indokoltan, és preferáltan theme-ben.

Tilos:

* `TextStyle(fontSize: 17, ...)` mindenhol

Kivétel:

* kis, lokális finomhangolás, ha a design ezt kívánja, de a cél a theme-be emelés.

---

## 5) Spacing és layout konvenció

* Ne legyen „magic number” tömegével.
* Ajánlott: központi spacing konstansok (pl. `AppSpacing`) vagy design token.
* A Codex ha bevezet spacing tokent, azt külön canvas+yaml feladatban tegye.

Alap irány:

* 4/8/12/16/24 px rács

---

## 6) Component szabványok

### 6.1 Buttonok

* `FilledButton` / `OutlinedButton` / `TextButton` (Material 3)
* Style override csak indokoltan, lehetőleg theme-ben.

### 6.2 Card/Surface

* `Card` + `colorScheme.surface`
* Elevation és shape a theme-ből jöjjön.

### 6.3 Iconok

* `IconTheme` vagy theme alapú szín.

---

## 7) Dark mode

Ha a projekt támogatja:

* legyen `lightTheme` + `darkTheme`
* ugyanazok a tokenek konzisztensen

Ha még nincs:

* a Codex ne vezessen be félkész dark mode-ot.
* dark mode bevezetése külön feladat.

---

## 8) UI regresszió védelem (teszt)

### 8.1 Widget teszt minimum

UI változás esetén:

* legalább 1 widget teszt, ami a kritikus elemek jelenlétét ellenőrzi.

### 8.2 Golden teszt (csak ha a projekt használja)

* Golden akkor kell, ha már van infrastruktúra és baseline.
* Ha nincs, ne vezessük be „csak ezért”.

---

## 9) Codex szabályok theme feladatnál

### 9.1 Kötelező YAML lépések

* Theme forrásfájl módosítása külön stepben
* UI komponens frissítése külön stepben
* Teszt futtatás + report külön stepben

### 9.2 Outputs elv

* Theme fájl(ok)
* érintett widget/screen
* érintett teszt
* report

---

## 🧪 Tesztállapot

### Definition of Done (Theme/UI)

* [ ] Nincs hardcode hex szín a végleges UI-ban
* [ ] TextTheme/ColorScheme alapján épül a UI
* [ ] UI változás esetén van widget teszt (vagy dokumentált ok)
* [ ] `flutter analyze` + `flutter test` lefut (vagy dokumentált ok)

---

## 🌍 Lokalizáció

Theme nem lokalizáció, de:

* a theme ne befolyásolja negatívan a hosszú lokalizált szövegek megjelenését
* figyelni kell a line-wrap/overflow problémákra

---

## 📎 Kapcsolódások

* `docs/codex/overview.md`
* `docs/codex/prompt_template.md`
* `docs/codex/yaml_schema.md`
* `docs/qa/testing_guidelines.md`
* `docs/architect/routing_integrity.md`
* `docs/localization/localization_logic.md`
