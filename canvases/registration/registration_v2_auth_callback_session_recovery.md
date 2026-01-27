# Registration v2 – Auth callback session recovery + expired link védelem

## 🎯 Funkció
A cél, hogy a regisztráció utáni email link (verify / callback) megnyitása:
- **ne crashelje** az appot (lejárt/érvénytelen link esetén sem),
- a deeplink callback feldolgozás **kontrolláltan** történjen,
- legyen **userbarát UX** success/expired/error állapotokra,
- opcionálisan átvezetés legyen a **Verify pending + resend** képernyőre, ha az email ismert.

A projektben már létezik:
- `/auth/callback` route + `AuthCallbackScreen`,
- `/auth/verify-pending` + resend/cooldown logika,
- Signup wizard Step1–3, verify pending screen.

Ezt kell “production-grade” szintre hozni.

## 🧠 Fejlesztési részletek

### 1) Supabase deeplink auto session detection kikapcsolása
A Supabase initialize során állítsd be:
- `FlutterAuthClientOptions(detectSessionInUri: false)`

Cél: ne a supabase_flutter próbálja automatikusan feldolgozni a deeplinket.

Megkötés:
- a többi initialize opciót (pl. authFlowType, storage, stb.) ne törjük, csak egészítsük.

### 2) Globális crash-shield a specifikus expired/invalid link AuthException ellen
Az app entrypointban (ahol `runApp()` történik) vezess be globális hibakezelést:
- `runZonedGuarded(...)` és/vagy `PlatformDispatcher.instance.onError`
- csak a deeplinkes AuthException mintát “kezeljük le” úgy, hogy **ne crasheljen**:
  - tipikus minta: üzenet tartalmazza “invalid or has expired”, vagy `403`, vagy `access_denied` jellegű kód

Megkötés:
- ne legyen “mindent elnyelő” globális swallow: csak a fenti mintára legyen védőháló.

### 3) Auth callback feldolgozás providerrel (tesztelhető)
Hozz létre:
- `app/lib/src/features/auth/presentation/state/auth_callback_provider.dart`

Állapot:
- `processing`, `success`, `expired`, `error`

Bemenet:
- a callback teljes `Uri` (GoRouter `state.uri`)

Logika:
- ha Supabase nincs konfigurálva → `error`
- különben próbálj sessiont kinyerni a callback Uri-ból:
  - használd a repóban ténylegesen elérhető Supabase/gotrue metódust (pl. `getSessionFromUrl`, vagy verziófüggő alternatíva)
- hibakezelés:
  - expired/invalid minta → `expired`
  - egyéb → `error`

Tesztelhetőség:
- legyen felülírható handler provider (pl. `authCallbackHandlerProvider`), hogy widget tesztben ne kelljen valódi Supabase.

### 4) Router: /auth/callback kapja meg a teljes URI-t
`app/lib/src/app/router/app_router.dart`:
- `/auth/callback` route builder adja át a `state.uri`-t az `AuthCallbackScreen`-nek.

### 5) AuthCallbackScreen UX állapotokkal
`app/lib/src/features/auth/presentation/screens/auth_callback_screen.dart`:
- legyen `ConsumerStatefulWidget`
- `initState`-ben indíts feldolgozást (idempotensen)

UI:
- **Processing:** spinner + `auth_callback_processing`
- **Success:** `auth_callback_success` + CTA `auth_callback_continue` → `/home` (vagy a repó szerinti landing)
- **Expired:** `auth_callback_expired` + CTA1 `auth_callback_back_to_login` → `/auth/login`
- **Error:** `auth_callback_error_generic` + CTA1 login

Opcionális:
- ha email kinyerhető (query param vagy biztosan detektálható), jelenjen meg CTA2 `auth_callback_resend` → `/auth/verify-pending?email=...`
- ha email nem ismert, CTA2 ne jelenjen meg.

### 6) Lokalizáció
ARB bővítés (EN+HU):
- `auth_callback_title`
- `auth_callback_processing`
- `auth_callback_success`
- `auth_callback_continue`
- `auth_callback_expired`
- `auth_callback_error_generic`
- `auth_callback_back_to_login`
- `auth_callback_resend`

Majd: `./scripts/flutter.sh gen-l10n`

### 7) Dokumentáció frissítése
`documents/registration/registration_flow_V2-md`:
- írd le a callback feldolgozást (success/expired/error),
- indokold a detectSessionInUri false + crash-shield létezését,
- kösd a Verify pending + resend flow-hoz.

## 🧪 Tesztállapot
Új widget teszt:
- `app/test/widget/auth_callback_screen_test.dart`

Követelmények:
1) success state (override handler) → “Continue” CTA megjelenik
2) expired state (override handler) → expired szöveg + “Back to login” CTA megjelenik
3) opcionális: email esetén “Resend” CTA megjelenik

Nem lehet valódi Supabase hálózatfüggés.

## 🌍 Lokalizáció
Minden új UI string kizárólag az `auth_callback_*` kulcsokon keresztül menjen (EN+HU).

## 📎 Kapcsolódások
- `app/lib/src/app/router/app_router.dart`
- `app/lib/src/features/auth/presentation/screens/auth_callback_screen.dart`
- `app/lib/src/features/auth/presentation/screens/verify_email_pending_screen.dart`
- `app/lib/src/features/auth/presentation/state/verify_email_pending_provider.dart`
- Supabase initialize helye (a repóban keresd meg)
- `documents/registration/registration_flow_V2-md`
- **Automatikusan generálandó Codex artefaktok a futás végén:**
  - `codex/codex_checklist/registration/registration_v2_auth_callback_session_recovery.md`
  - `codex/reports/registration/registration_v2_auth_callback_session_recovery.md`
