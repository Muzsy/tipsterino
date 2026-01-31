# Registration v2 deep link E2E QA guide

## 1) Pre-check (Supabase)
- The Supabase Auth → Redirect URLs list must include `io.tipsterino://auth-callback/auth/callback`. Without it the deep link is rejected before it reaches the device.
- The `signUp` flow currently calls `emailRedirectTo: 'io.tipsterino://auth-callback/auth/callback'`, so the redirect URL has to match exactly (scheme, host, path).

## 2) Android manual test (adb)
1. Build or install the debug APK on a device/emulator.
2. Ensure the app is either completely closed **or** already running (test both states).
3. Run:
   ```bash
   adb shell am start -a android.intent.action.VIEW \
     -d "io.tipsterino://auth-callback/auth/callback" \
     -n io.tipsterino/io.flutter.embedding.android.FlutterActivity
   ```
4. Expected:
   - The system launches Tipsterino (new or resumed activity).
   - GoRouter hits `/auth/callback` and the `AuthCallbackScreen` is shown.
   - If the Supabase session is valid, the screen resolves to AUTH_READY; if the token is expired, the UI surfaces the localized error + resend control.
5. Repeat the command with the app already running to confirm the existing activity handles the link the same way.

## 3) iOS manual test (simctl)
1. Boot an iOS simulator (`xcrun simctl boot <device>`).
2. Install the app/simulate the build (if needed).
3. Run:
   ```bash
   xcrun simctl openurl booted "io.tipsterino://auth-callback/auth/callback"
   ```
4. Expected behavior mirrors Android: the simulator opens the app, GoRouter handles `/auth/callback`, and the `AuthCallbackScreen` appears with success or error UI.
5. Test both from a closed app (simulate by terminating) and when the app is already in the foreground.

## 4) Error cases
- Use an expired/malformed redirect URI (e.g. wrong scheme or path) to confirm the app shows the localized error message from `AuthCallbackScreen` and offers a resend option.
- Confirm the log/analytics track the failure reason so the user sees guidance for re-sending the verification email.

## 5) Notes
- This doc is specifically for the custom scheme flow (no Universal Links / App Links).
- Share the adb/simctl commands with QA so they can reproduce in device labs.
