# Registration v2 full E2E device run checklist

## C1 – QA runbook & docs
- [x] `docs/qa/registration_v2_full_e2e.md` documents the prerequisites, device command, log collection steps, the full manual flow (signup → verify pending → email link → callback), the negative smoke scenario, and the sanitized logging requirements (path + keys only).
- [x] `docs/qa/registration_v2_deeplink_e2e.md` now links to the full runbook and calls out the `adb logcat` commands plus the rule that only callback key names—not tokens—should be recorded.

## C2 – Integration regression test
- [x] `app/integration_test/registration_v2_full_flow_test.dart` runs the signup wizard through Step1–Step3 with fake providers, hits the verify pending screen (resend + snackbar), and navigates to `/auth/callback` to assert the success message and `Continue` button.
- [x] The integration test overrides the relevant providers so it does not rely on Supabase (auth notifier, supabase config, nickname checker, signup submitter, verify pending resender/cooldown, auth callback handler).

## C3 – Gate
- [x] `./scripts/check.sh`
- [x] `./scripts/flutter.sh test integration_test -d GAB7N18604000884` *(now passes after the deterministic integration test forces an English locale via `appLocaleProvider`, so the Register title can be found on-device; see the report for the prior failure log and locale mismatch fix)*
