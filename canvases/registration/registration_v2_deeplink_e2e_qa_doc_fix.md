// canvases/registration/registration_v2_deeplink_e2e_qa_doc_fix.md

# 🎯 Funkció

Az existing `docs/qa/registration_v2_deeplink_e2e.md` QA walkthrough rossz Android `adb` package-et és FlutterActivity-komponenst használ, továbbá összemossa a platform wiring smoke tesztet a valódi verify-email E2E ellenőrzéssel, ami téves eredményeket adhat.

Cél:
- javítsuk a QA docot úgy, hogy (1) a platform wiring intent a valós `com.yourorg.tipsterino/.MainActivity`-t használja, (2) legyen külön Smoke/Wiring teszt és Valódi verify-email E2E rész, (3) jelezze, hogy a resend CTA csak `?email=` esetén jelenik meg.

## DoD

- Smoke parancs: component nélküli `adb` + opcionális `-n com.yourorg.tipsterino/.MainActivity`.
- QA doc külön kezeli Smoke/Wiring és Valódi E2E lépéseket, az eredmények (error vs success) és a resend CTA feltételei egyértelműek.
- `./scripts/check.sh` lefutott, checklist + report frissültek.
