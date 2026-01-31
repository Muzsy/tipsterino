# Registration v2 deeplink E2E QA doc fix checklist

## C1 – Correct Android wiring checks
- [x] `docs/qa/registration_v2_deeplink_e2e.md` now lists the component-less `adb shell am start ... io.tipsterino://auth-callback/auth/callback` smoke intent and the optional `-n com.yourorg.tipsterino/.MainActivity` debug variant (no FlutterActivity/curious package).

## C2 – Clear smoke vs real E2E flows
- [x] The doc now splits Smoke/Wiring vs Real verify-email E2E flows, calls out the expected `error/expired` state for token-less links, and describes success + Continue navigation for real verify links.
- [x] Resend CTA behavior is spelled out: it appears only when `?email=...` is present, so the smoke test does not surface the button.

## C3 – Gate
- [x] `./scripts/check.sh`
- [ ] `./scripts/flutter.sh gen-l10n` *(not run; not part of documentation change)* 
