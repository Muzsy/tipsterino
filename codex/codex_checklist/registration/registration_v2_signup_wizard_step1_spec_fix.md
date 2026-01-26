# Registration v2 SignUp wizard step1 spec fix – Checklist

## DoD
- [x] Jelszó mező alapértelmezetten plaintext (nincs `obscureText:true`), a szabálylista csak a nem teljesülő sorokat mutatja.
- [x] A negyedik szabály special char-t vár, a wizard state-en (`hasSpecialChar`) és `step1Valid`-en keresztül igazolt.
- [x] Lokalizációs kulcsok: `auth_password_rule_special` szerepel mindkét ARB-ben, és lefutott a `./scripts/flutter.sh gen-l10n`.
- [x] `app/test/widget/auth_signup_wizard_step1_test.dart` a special char jelszóval fut, és a szabálylista eltűnését illetve a „Tovább” engedését ellenőrzi.
- [x] `documents/registration/registration_flow_V2-md` Step 1 leírása esetén megjelenik a plaintext jelszó + special char követelmény.
- [x] `./scripts/check.sh` analyze + widget futások zöldek.

## Feladat-specifikus pontok
- [x] A special char szabály whitespace-mentes karaktert vizsgál (RegExp: nem alfanumerikus, nem whitespace).
- [x] A spec-nek megfelelő canvas és goal jobban leírja a fixet (plaintext és special char, nem number).
