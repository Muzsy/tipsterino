# FILE: canvases/localization/l10n_key_parity_check.md

# P1-4: L10n kulcs-paritás automata ellenőrzés (ARB key parity) + CI gate

## 🎯 Funkció
Cél: legyen **automatikus, determinisztikus ellenőrzés**, ami megfogja, ha az EN/HU ARB fájlok kulcskészlete eltér (hiányzó/extra kulcs), illetve ha placeholder-ek eltérnek.

Miért:
- Jelenleg csak minimál l10n teszt van: `app/test/widget/l10n_test.dart` (néhány stringet ellenőriz).
- A kulcs-paritás drift könnyen becsúszik, és a generált fájlok commitolása miatt későn derül ki.

Követelmény:
- Az ellenőrzés **automatikusan fusson CI-ben** (a repo gate részeként).

Nem cél:
- Új nyelvek bevezetése.
- Lokalizációs UI/nyelvváltó módosítás.
- Gen-l10n pipeline átalakítás.

## 🧠 Fejlesztési részletek

### Érintett forrásfájlok
- ARB-k:
  - `app/lib/l10n/app_en.arb`
  - `app/lib/l10n/app_hu.arb`
- Meglévő minimál teszt:
  - `app/test/widget/l10n_test.dart`
- CI gate:
  - `.github/workflows/ci.yml` → `./scripts/check.sh`
  - `scripts/check.sh` → `./scripts/flutter.sh test`

### Javasolt megoldás
1) Új **unit teszt**: `app/test/unit/l10n_key_parity_test.dart`
   - Beolvassa és JSON-ként parse-olja mindkét ARB-t.
   - Ellenőrzi:
     - a “valós” kulcsok halmaza megegyezik (minden nem-`@` kulcs).
     - nincs “árva” meta kulcs (pl. `@someKey` úgy, hogy `someKey` nincs).
     - ha placeholders vannak, a placeholder név-halmaz mindkét nyelvben egyezzen.

2) Dokumentáció frissítés, hogy ez mostantól kötelező QA:
   - `docs/localization/localization_logic.md` (QA/ARB szinkron részbe bekerül: parity test és fájlútvonal)

### CI-be kötés
- Mivel a CI a `./scripts/check.sh`-t futtatja (`.github/workflows/ci.yml`), és a check.sh futtatja a `./scripts/flutter.sh test`-et, az új unit teszt **automatikusan futni fog CI-ben**.

### DoD (pipálható)
- [ ] Létrejön `app/test/unit/l10n_key_parity_test.dart` és:
  - [ ] JSON parse + key set parity (EN vs HU)
  - [ ] árva meta kulcs guard
  - [ ] placeholder parity guard (ha van)
- [ ] `docs/localization/localization_logic.md` kiegészítve: hivatkozás az automata parity tesztre (file path + rövid elv).
- [ ] Codex checklist + report létrejön:
  - `codex/codex_checklist/localization/l10n_key_parity_check.md`
  - `codex/reports/localization/l10n_key_parity_check.md`
- [ ] Task zárás: lefut és rögzítve van:
  - `./scripts/verify.sh --report codex/reports/localization/l10n_key_parity_check.md`
  - log: `codex/reports/localization/l10n_key_parity_check.verify.log`

## 🧪 Tesztállapot
Kötelező task zárás:
- `./scripts/verify.sh --report codex/reports/localization/l10n_key_parity_check.md`

## 🌍 Lokalizáció
Közvetlenül érintett:
- `app/lib/l10n/app_en.arb`
- `app/lib/l10n/app_hu.arb`

## 📎 Kapcsolódások
- `.github/workflows/ci.yml`
- `scripts/check.sh`
- `scripts/flutter.sh`
- `docs/localization/localization_logic.md`
- Meglévő l10n teszt: `app/test/widget/l10n_test.dart`
- Report standard: `docs/codex/report_standard.md`
