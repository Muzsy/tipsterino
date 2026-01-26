# Registration v2 SignUp wizard (step 2) – Checklist

## DoD
- [x] Canvas + goal YAML dokumentálják a Step 2 (nickname + avatar) követelményeit.
- [x] A `signup_wizard_provider` és a `SignUpWizardScreen` Step 2 logikája megvalósítja a nickname validációt, availability státuszokat és az avatar picker UI-t.
- [x] Az ARB fájlok tartalmazzák az új `common_done`, `auth_nickname_*` és `auth_avatar_*` kulcsokat, és újra generálódott az AppLocalizations.
- [x] Létrejött a Step 2 widget teszt, ami a `nicknameAvailabilityCheckerProvider` felülírásával ellenőrzi a Next aktiválódását.
- [x] `./scripts/flutter.sh gen-l10n` lefutott a frissített lokalizációs kulcsokkal.
- [ ] `./scripts/flutter.sh format .` futtatása blokkolva: a Flutter próbálta frissíteni `/home/muszy/flutter/bin/cache/engine.stamp` fájlt, de „Engedély megtagadva” hiba miatt nem ment végig.
- [x] `./scripts/check.sh` lefutott (analyze + widget tesztek + új step2 teszt sikeresen zöld).

## Feladat-specifikus pontok
- [x] Nickname mező helper szöveggel, inline státuszüzenetekkel (too short / checking / available / unavailable / error) és lowercase normalizálással reagál.
- [x] Avatar preview megjelenik, és a „Változtatás” gomb megnyitja a három presetet tartalmazó bottom sheetet.
- [x] A „Tovább” gomb Step 2-nél csak akkor aktív, ha a nickname elérhető és az offline állapot nem engedi a továbbhaladást.
- [x] Step 3 marad placeholder, de a wizard navigáció (back/next) továbbra is működik.

