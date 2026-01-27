# Registration v2 Auth callback session recovery – Checklist

## DoD
- [x] `Supabase.initialize` élesben a `FlutterAuthClientOptions(detectSessionInUri: false)` beállítással fut.
- [x] Globális `runZonedGuarded`/`PlatformDispatcher.instance.onError` hibaellenőrzés az „invalid/expired/access_denied” `AuthException` mintákra épül, és ezek nem engedik a crash-t.
- [x] Új, felülírható `auth_callback_provider` + handler létezik, és a `/auth/callback` route a teljes `state.uri`-t adja át az `AuthCallbackScreen`-nek.
- [x] Az `AuthCallbackScreen` minden állapotban (processing/success/expired/error) a megfelelő lokalizált szöveget, CTA-kat (Continue, Back to login, opcionális Resend) és spinner-üzeneteket mutat.
- [x] Az `auth_callback_*` ARB kulcsok bekerültek mindkét nyelvbe, és lefutott `./scripts/flutter.sh gen-l10n`.
- [x] A `documents/registration/registration_flow_V2-md` leírja a kontrollált callback feldolgozást, a `detectSessionInUri=false` indokát és a crash-shield szerepét.
- [x] Új widget teszt fedi a success + expired flowokat, és `./scripts/check.sh` analyze + teszt futtatás zöld.
- [ ] `cd app && dart format .` *(nem futott le: `/home/muszy/flutter/bin/cache/engine.stamp` fájl írásakor „Engedély megtagadva” hiba)*
