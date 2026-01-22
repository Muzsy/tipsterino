# Tipsterino foundation + auth skeleton checklist

## C1 – Dokumentáció és vásznak
- [x] A `documents/` struktúrát elkészítettem az új architektúra leírására (`documents/app_architecture.md`).
- [x] A Tipsterino specifikus vászon (`canvases/tipsterino_foundation_bootstrap.md`) elkészült.
- [x] A hozzá tartozó YAML (`codex/goals/canvases/fill_canvas_tipsterino_foundation_bootstrap.yaml`) lépésekre boncolja a feladatot.

## C2 – App/architektúra
- [x] `app/lib/main.dart`, go_router, Riverpod és Supabase provider logika összeállt az `app/lib/src/` alatt.
- [x] Login/regisztráció, tab navigáció és Supabase guardok is működnek offline környezetben.
- [x] L10n HU/EN gyűjtés és `flutter gen-l10n` generálta a `app_localizations.dart` fájlokat.

## C3 – Tesztelés + gate
- [x] Widget tesztek (`app/test/widget/`) ✅
- [x] Integration teszt (`app/integration_test/app_test.dart`) a fizikai eszközön lefutott (build + install) `cd app && flutter test integration_test/app_test.dart -d <deviceId>` parancssal.
- [x] `cd app && dart format .`, `cd app && flutter analyze`, `cd app && flutter test` végrehajtva.
