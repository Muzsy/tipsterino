🎯 Funkció
- A Tipsterino artefaktok (canvas, checklist, report) konzisztens útvonalaira és a dokumentáció pontos Supabase leírására fókuszálunk.
- Tisztázzuk, hogy az `app/.env.example` csupán sablon, nem futtatási dependency, és a Supabase kulcsokat kizárólag `--dart-define`-on keresztül adjuk meg.
- Megerősítjük, hogy a dokumentumok tényleges `app/` struktúrára hivatkoznak, a lokalizációs kulcslista ragaszkodik a valós ARB fájlokhoz, és a widget smoke teszt a lokalizált stringeket használja.

🧠 Fejlesztési részletek
- P1: `app/.env.example` kommentjét frissítjük, hogy világos legyen: nincs `.env` load, csak `--dart-define`, csupán template/notes.
- P2: `canvases/tipsterino_stability_run.md` és `codex/codex_checklist/tipsterino_stability_run.md` hivatkozásai `app/integration_test/app_test.dart`-ra és `app/lib/l10n/app_localizations.dart`-ra mutatnak, ahol repo path szükséges.
- P3: `canvases/tipsterino_foundation_bootstrap.md` lokalizációs lista kizárólag az `app/lib/l10n/app_{en,hu}.arb` kulcsait sorolja fel.
- P4 (opcionális): `app/test/widget/app_smoke_test.dart` lokalizációs delegált `AppLocalizations`-t használ a locale pumpolásánál, hogy ne hardcode-oljon angol stringet.

🧪 Tesztállapot
- `cd app && dart format .`
- `cd app && flutter analyze`
- `cd app && flutter test`
- `cd app && flutter test integration_test/app_test.dart -d <deviceId>` (fizikai Android eszköz)

🌍 Lokalizáció
- Az `app/lib/l10n/app_en.arb` és `app/lib/l10n/app_hu.arb` kulcsait használjuk a tesztekben és a dokumentációban; nincs másik lokalizációs string lista.

📎 Kapcsolódások
- `app/.env.example`
- `canvases/tipsterino_stability_run.md`
- `codex/codex_checklist/tipsterino_stability_run.md`
- `canvases/tipsterino_foundation_bootstrap.md`
- `app/test/widget/app_smoke_test.dart`
