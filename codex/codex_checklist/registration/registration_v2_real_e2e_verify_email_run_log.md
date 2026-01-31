# Registration v2 real verify-email run log checklist

## C1 – QA doc alignment
- [x] `docs/qa/registration_v2_deeplink_e2e.md` real verify-email section no longer assumes `?email=` and describes success + Continue + auth shell expectations.
- [x] The doc now notes that real Supabase callbacks may or may not include `?email=`, describes the resend CTA restriction, and asks QA to log the callback path + query/fragment key names (no values).

## C2 – Debug visibility
- [x] `AuthCallbackHandler` now prints a sanitized URI summary and the outcome (success/expired/error) to aid future E2E logs without exposing tokens.

## C3 – Gate
- [x] `./scripts/check.sh`
