🎯 Funkció
- A Tipsterino artefakt-pontosság helyreállítása: minden dokumentum és célfájl csak létező `app/...` útvonalat említ.
- A dotenv teljes kikapcsolása, kizárólag `--dart-define` alapú Supabase konfigurációval és eszközfelhasználással.
- A tesztfolyamat stabilizálása offline és konfigurált állapotban, az integration tesztet is beleértve.

🧠 Fejlesztési részletek
- P1: Globális keresés és csere `lib/` → `app/lib/`, `test/` → `app/test/`, `integration_test/` → `app/integration_test/`, `.env.example` → `app/.env.example` útvonalakra a canvasokban, YAML-okban, checklist-ekben, riportokban és dokumentációban.
- P2: `flutter_dotenv` eltávolítása (pubspec + `main.dart`), Supabase URL/Key `String.fromEnvironment`-nel olvasása, hiány esetén offline üzenet és gomb tiltás.
- P3: Widget és integration tesztek ellenőrzése, hogy ne keressenek `.env` fájlt; offline állapotban a login gomb disabled legyen, konfiguráltan pedig a home/login képernyő stabil legyen.
- Keresési minták: `app/lib/`, `app/test/widget`, `app/integration_test`, `.env`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `flutter_dotenv`.

🧪 Tesztállapot
- A `flutter test` lefut, figyelembe véve offline + defined környezetet.
- `flutter test integration_test -d <device>` lefedettség; ha fizikai eszköz nincs, az instrukciót dokumentálni kell.
- `flutter analyze` és `dart format .` futtatva a `app/` gyökérben.

🌍 Lokalizáció
- Az ARB-okban lehetőleg a `--dart-define` konfigurációról szóló szöveg szerepeljen, `.env`-hivatkozás nélkül; ha kell, frissíteni kell őket.

📎 Kapcsolódások
- `app/lib/main.dart`
- `app/pubspec.yaml`
- `documents/supabase_configuration.md`
- `app/integration_test`
- `app/test`
