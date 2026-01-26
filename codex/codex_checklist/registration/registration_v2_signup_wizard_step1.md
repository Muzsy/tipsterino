# Registration v2 SignUp wizard (step 1) – Checklist

## DoD
- [x] Canvas + goal YAML + checklist + report elkészültek a wizard első lépéséhez.
- [x] Az ARB fájlok tartalmazzák a `common_*`, `auth_signup_step_*` és `auth_password_rule_*` kulcsokat, és a `./scripts/flutter.sh gen-l10n` lefutott.
- [x] A `/auth/register` route a `SignUpWizardScreen`-re mutat, létrejött a wizard state provider és a Step 1 UI, valamint készült widget teszt.
- [x] `./scripts/check.sh` lefutott (analyze + widget), és az eredmény a reportban szerepel (teszt > passz).

## Feladat-specifikus pontok
- [x] Offline módban a CTA inaktív és az offline notice megjelenik az első lépésen.
- [x] A „Tovább” gomb csak akkor aktív, ha az email/@ és az összes jelszó szabály teljesült, és a szabálylista valós időben frissül.
- [x] A 2. és 3. lépés placeholderként „coming next” állapotot mutat, de a navigation gombok megmaradnak.
