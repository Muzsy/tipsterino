## Mit találtunk?
- Supabase verifikációs emailek `emailRedirectTo` értéke `io.tipsterino://auth-callback/auth/callback`, de az Android/iOS platformok nem voltak konfigurálva, így a deep link nem érkezett vissza a mobil appba.
- Dokumentációs anyagok csak általánosságban beszéltek intent filterekről/associated domainről, nem rögzítették a pontos URI-t és az E2E parancsokat.

## Mit módosítottunk?
- Android: a `MainActivity` kapott egy új `VIEW` intent-filtert (DEFAULT + BROWSABLE), ami a `io.tipsterino` scheme-et, `auth-callback` hostot és `/auth/callback` path-prefixet kezeli.
- iOS: az `Info.plist` `CFBundleURLTypes` tömbje tartalmazza a `io.tipsterino` scheme-et, így a sim és a Supabase link is az appba irányul.
- `docs/core_logic/authentication_flow.md` és `docs/core_logic/registration_flow.md` a `io.tipsterino://auth-callback/auth/callback` URI-t, a Supabase redirect URI allowlistet, valamint a konkrét platform lépéseket tartalmazzák.
- `documents/registration/registration_flow_V2-md` hozzáadott deep link audit részeket és QA link hivatkozást arra, hogy a QA doc tartalmazza az adb/simctl parancsokat.
- Új QA doc (`docs/qa/registration_v2_deeplink_e2e.md`) létezik, amely krokodil lépésenként írja a Supabase allowlist ellenőrzést, Android/iOS parancsokat, valamint a sikeres/hibás UX elvárásokat.

## Tesztek
- `./scripts/flutter.sh gen-l10n` – PASS (nem változtatott generált fájlokat, csak biztonságosan újragenerálta).
- `./scripts/check.sh` – PASS (pub get + analyze + widget tesztek).

## Ismert korlátok / TODO
- A `flutter build apk --debug` opcionális parancs nem futott, mert a környezetben nem biztosított megbízható Android toolchain.

## Következő javasolt lépések
1. QA csapattal fusson le az adb/simctl parancs a valódi eszközökön, hogy megerősítsük a link időközi működését (app zárt és foreground állapotban is).
2. Ha később továbblépünk Universal Link / App Link irányába, frissítsük a doksit az új URI/assetlink fájlokra, de most a custom scheme flow működése a prioritás.
