# Registration v2 deep link E2E QA guide

## 1) Pre-check (Supabase)
- The Supabase Auth → Redirect URLs list must include `io.tipsterino://auth-callback/auth/callback`. Without it the deep link is rejected before it reaches the device.
- The `signUp` flow currently calls `emailRedirectTo: 'io.tipsterino://auth-callback/auth/callback'`, so the redirect URL has to match exactly (scheme, host, path).

## 2) Android smoke / wiring test (token-less intent)
1. Build or install the debug APK on a device/emulator.
2. Ensure the app is either completely closed **or** already running (test both).
3. Run the intent without an explicit component so the OS resolves the target activity:
   ```bash
   adb shell am start -a android.intent.action.VIEW \
     -d "io.tipsterino://auth-callback/auth/callback"
   ```
4. Optional debug variant with the real package/component:
   ```bash
   adb shell am start -a android.intent.action.VIEW \
     -d "io.tipsterino://auth-callback/auth/callback" \
     -n com.yourorg.tipsterino/.MainActivity
   ```
5. Expected:
   - Tipsterino launches (new or resumed activity) and GoRouter hits `/auth/callback`.
   - `AuthCallbackScreen` appears.
   - Without a valid Supabase token the screen typically shows the `error/expired` state (not `success`), and **no resend CTA** is expected since the smoke link lacks `?email=`.
   - Repeat from both closed and foreground states to verify intent handling.

## 3) Android / iOS real verify-email E2E
1. Complete a fresh registration (SignUp Step 3) so Supabase sends a verification email with the `io.tipsterino://auth-callback/auth/callback?email=...` link.
2. Open the verification email on the same device/emulator or a device that can launch the app.
3. Tap the magic link; the browser should redirect to `io.tipsterino://auth-callback/auth/callback?email=...`.
4. Expected:
   - Tipsterino opens, GoRouter handles `/auth/callback`, and `AuthCallbackScreen` shows the `success` state.
   - The `Continue` button becomes enabled and takes the user to `/home`.
   - Afterward, verify the profile is authenticated (not the guest shell).
5. Mirror the same steps on iOS simulators using `xcrun simctl openurl booted ...` for both smoke and real link flows (with and without `?email=`) so the platform configuration is also verified.

## 4) Resend CTA behavior
- The `AuthCallbackScreen` resend button appears **only when** the callback URI contains an `?email=...` query parameter.
- The smoke/wiring intent intentionally lacks `email`, so no resend UI should appear in that flow.
- If users need to resend, they should return to `VerifyEmailPendingScreen`, which always surfaces the resend control independent of the callback parameters.
