# Registration v2 full E2E runbook

## Cél
Az end-to-end regisztrációs flow (signup wizard → verify pending → email magic link → auth callback → continue) manuális futtatásának reprodukálható, logolt leírása fizikai eszközön vagy emulátoron.

## Előfeltételek
- Supabase Auth → Redirect URLs allowlist tartalmazza: `io.tipsterino://auth-callback/auth/callback`.
- A teszteléshez legyen elérhető Android eszköz/emulátor (`adb devices` listázza a device-ot) vagy iOS simulator (`xcrun simctl list devices`).
- A manuális runhoz legyen kéznél a regisztrációs wizard adatsora (email + jelszó + nickname).

## Device futtatás
1. Telepítsd/indítsd el az appot az adott device-on:
   ```bash
   ./scripts/flutter.sh run -d <DEVICE_ID>
   ```
2. Ha Androidot használsz, készítsd elő a logokat:
   ```bash
   adb logcat -c
   adb logcat | grep -E "AuthCallbackHandler|AuthCallback"
   ```
   - A `AuthCallbackHandler` debug logjai már csak a URI path-ját és a query/fragment kulcsneveit írják ki (nem az értékeket vagy tokeneket).
   - A szűrt logot rögzítsd, de soha ne commitolj tokeneket vagy titkokat.

## Manuális flow lépések
1. A guest home képernyőn nyomj az `Auth` register CTA-ra (`HomeGuestRegisterCta`), hogy megnyisd a signup wizardot.
2. **Step 1 (Account)**
   - Add meg az emailt (pl. `qa+user@example.com`) és egy érvényes jelszót (`Min8Ch@r`).
   - Győződj meg róla, hogy a jelszó természetesen teljesíti a szabályokat (minimum 8 karakter, kisbetű, nagybetű, speciális karakter).
   - Nyomd meg a `Next` gombot.
3. **Step 2 (Profile)**
   - Írd be a `nickname`-et (pl. `qa_tester`) és várj a debounce után az elérhetőségre (`nicknameAvailabilityChecker` logoltan sikeres, mivel a teszt override-olja).
   - Az avatar hozzáadása opcionális, a default `neutral` is jó.
   - `Next` gomb megnyomásával lépj tovább.
4. **Step 3 (Consent)**
   - Pipáld be az ÁSZF és Adatkezelés checkboxokat, majd nyomd meg a `Fiók létrehozása` gombot.
5. **Verify Pending**
   - Győződj meg róla, hogy a `VerifyEmailPendingScreen` jelenik meg, a `resend` gomb aktív (cooldown=0).
   - Nyomd meg a `resend` gombot, ellenőrizd a `Snackbar` megjelenését (`auth_verify_pending_resend_sent`).
6. **Verify email link**
   - Nyisd meg a Supabase által küldött email linket a teszt device-on; a redirect a custom scheme-re (`io.tipsterino://auth-callback/auth/callback`) vigyen vissza.
   - 1) Smoke: futtasd az `adb shell am start` parancsot token nélkül (lásd lenti rész) és ellenőrizd az `AuthCallbackScreen` `expired`/`error` állapotát.
   - 2) Valódi link: győződj meg róla, hogy a `success` állapot jelenik meg, a `Continue` gomb `/home`-ra visz, és a shell már auth state-ben van.

## Negatív smoke ellenőrzés
Futtasd az alábbi parancsot, hogy ellenőrizd a platform wiringot token nélkül:
```bash
adb shell am start -a android.intent.action.VIEW \
  -d "io.tipsterino://auth-callback/auth/callback"
```
- A `AuthCallbackScreen` ebben az esetben tipikusan `expired` vagy `error` üzenetet mutat, és **nem** jelenik meg `Continue` gomb, illetve a resend CTA sem aktív (`email` param hiányzik).

## Mit rögzíts a logban/reportban
- A callback URI „alakja”: path (`/auth/callback`) és a query/fragment kulcsnevek (`email`, `access_token`), **értékek nélkül**.
- Az `AuthCallbackScreen` státusza (success/expired/error) és hogy megjelent-e a `Continue` gomb.
- A navigációs eredmény (`Continue`-t követően `/home`), valamint a guest/auth shell megjelenése.
- Ha a `resend` gomb fut, írd fel, hogy megjelent-e és látható volt-e a `Snackbar`.
- Jelezd, ha `email` query hiányzik: ilyenkor nem szabad tokenhez/secrethez hozzáférni; a resend a `VerifyEmailPendingScreen`-en történik.
- A logokban kizárólag kulcsneveket (pl. `queryKeys=[email]`) rögzíts, soha ne írj ki tokeneket/secret értékeket.

## Jegyzet
- A QA runbook mellett mindig tartalmazzon a napló egy rövid szöveget arról, hogy a Supabase callback link melyik pathot/paramot tartalmazta, és milyen UI állapot következett be (success/expired/error).
- Ha iOS-en tesztelsz, használd `xcrun simctl openurl booted "io.tipsterino://auth-callback/auth/callback"` és rögzíts ugyanazokat az adatokat.
