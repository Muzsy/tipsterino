# Registration v2 SignUp wizard (step 3) – Checklist

## DoD
- [x] Canvas + goal YAML rögzítik a consent checkboxokat, summary kártyát és a verify pending flow-t.
- [x] A `signup_wizard_provider` kezeli a terms/privacy flageket, a submit állapotot és a felülírható `signupSubmitterProvider`-t.
- [x] A Step 3 UI summary-t, checkboxokat, offline notice-t és a Submit CTA-t rendereli, valamint a `VerifyEmailPendingScreen` és router entry elkészült.
- [x] Az ARB fájlok tartalmazzák a `auth_consent_*`, `auth_signup_submit_*` és `auth_verify_pending_*` kulcsokat, és a `./scripts/flutter.sh gen-l10n` lefutott.
- [ ] `cd app && dart format .` blokkolva: a Flutter megkísérelte frissíteni `/home/muszy/flutter/bin/cache/engine.stamp` fájlt, de "Engedély megtagadva" hiba miatt nem tudta végrehajtani.
- [x] `./scripts/check.sh` lefutott (analyze + widget tesztek, köztük az új Step 3 teszt, zöldek).

## Feladat-specifikus pontok
- [x] A Submit gomb csak akkor aktív, ha az első két lépés valid, mindkét consent bepipálva és nincs offline állapot.
- [x] Submit alatt spinner jelenik meg és siker után a `/auth/verify-pending` oldalra navigál a GoRouter segítségével.
- [x] A summary kártya email/nickname/avatar adatokat mutat, a checkboxok a provider állapotát frissítik, és az offline notice az offline státuszt jelzi.
