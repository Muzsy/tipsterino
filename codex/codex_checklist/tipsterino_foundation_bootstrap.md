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
- [x] Widget tesztek (`test/widget/`) ✅
- [x] Integration teszt (`integration_test/app_test.dart`) a fizikai `GAB7N18604000884` eszközön lefutott (build + install). 
- [x] `dart format .`, `flutter analyze`, `flutter test` végrehajtva.
