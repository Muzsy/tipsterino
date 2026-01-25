# Registration v2 feature-first előkészítés – Checklist

## DoD
- [x] Canvas + goal YAML készen a feature-first átstrukturálás leírására.
- [x] Az app entry/router/theme fájlok az `src/app` + `src/shared/theme` helyre kerültek, és a `main.dart`/smoke test a csomag importokon keresztül hivatkoznak rájuk.
- [x] Az `auth_provider`, `supabase_provider`, login/register képernyők az új `core/clients` és `features/auth/presentation/{screens,state}` mappákban vannak, és minden érintett import frissült.
- [x] A régi `screens/auth`/`providers`/`router` mappákból nincs duplikált fájl.
- [x] `dart format .` és `./scripts/check.sh` lefutottak (analyze + test zöld).

## Feladat-specifikus pontok
- [x] A `GoRouter` továbbra is az új router/app struktúrából hívja a screeneket (AppShell, home/tickets/leaderboard/settings).
- [x] A settings screen és az auth képernyők a package importokon keresztül hivatkoznak az auth/supabase provider-okra, nem relatív `../providers`-ra.
- [x] A `TipsterinoApp` és a smoke test a `src/app/app.dart` Podról importálja a MaterialApp routert (nincs direct `src/app.dart`).
- [x] A `core/clients/supabase_provider.dart` és az auth provider a package importokat használják, így más feature-ek is új helyről férnek hozzá.

## Nyitott kérdések / teendők
- A Flutter CLI jelezte, hogy több dependency (pl. `flutter_riverpod`, `material_color_utilities`, `riverpod`) frissebb verzióval rendelkezik; ezek kompatibilitási korlátok miatt most nem frissültek, de érdemes lehet később ellenőrizni.
