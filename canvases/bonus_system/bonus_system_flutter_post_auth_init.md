# Bonus system – Flutter: post-auth init (signup bónusz RPC bekötés)

**TASK_SLUG:** `bonus_system_flutter_post_auth_init`

---

## 🎯 Funkció

A kliens oldalon kerüljön bekötésre a **post-auth init** logika, ami az első autentikált sessionnél (illetve minden új sessionnél) meghívja a DB oldali RPC-t:

* `public.grant_signup_bonus_if_eligible()`

A hívás célja:

* a `signup_bonus` kiosztása **csak email-verifikáció után**
* idempotensen (DB oldalon már védve van)
* a kliens oldalon **csendes**, UI-t nem blokkoló módon

**Elvárt működés:**

* amikor az `AuthNotifier` állapota `authenticated` lesz és van session, a post-auth init lefut
* a kliens a visszatérő `reason` mezőt logolja/eltárolja, de nem mutat UI üzenetet

### Nem cél

* `user_events` inbox UI vagy értesítési képernyő
* push notification
* a `signup_bonus` összeg véglegesítése (maradhat 0, amíg nincs éles regisztráció)
* bármilyen új navigáció/routing

---

## 🧠 Fejlesztési részletek

### Forrás-igazság / meglévő építőelemek

* DB oldal:

  * `supabase/migrations/20260204000000_bonus_system_rpc_signup_bonus.sql` (RPC + helper)
  * `supabase/migrations/20260203000000_bonus_system_db_schema_rls.sql` (index + RLS)
* App oldal:

  * `app/lib/src/features/auth/presentation/state/auth_provider.dart` (AuthNotifier + onAuthStateChange)
  * `app/lib/src/core/clients/supabase_provider.dart` (Supabase client elérés)
  * minta RPC hívásra: `app/lib/src/features/auth/presentation/state/signup_wizard_provider.dart` (`client.rpc<bool>(...)`)

### Bekötési pont

A legstabilabb bekötés: **AuthNotifier session változáskor**.

* Inicializációkor, ha már van `currentSession` → futtassunk initet.
* `onAuthStateChange` streamben, amikor session nem null → futtassunk initet.

**Kritikus:** a post-auth init hívás ne blokkolja az auth state frissítést (ne várjuk meg a Future-t a stream callbackben).

### Kliens oldali API

Hozz létre egy kis “RPC kliens” réteget, ami:

* meghívja `grant_signup_bonus_if_eligible` RPC-t
* a választ egy típusos modelbe parse-olja:

  * `granted: bool`
  * `amount: int`
  * `reason: String`

### Állapotkezelés

Hozz létre egy `PostAuthInitNotifier`-t Riverpod StateNotifierként, ami:

* `isRunning` guard (ne fusson párhuzamosan)
* `lastUserId` / `lastRunAt` / `lastResult` (debug/telemetria cél)
* `runIfNeeded(Session session)` metódus

**Konvenció:**

* `reason=not_verified` nem hiba (várható állapot), csak eltároljuk.
* Exception esetén `lastError` kitöltése + debugPrint.

### Tesztelhetőség

A RPC hívást injektálható providerből add (pl. typedef function), hogy unit tesztben stubolható legyen Supabase nélkül.

---

## 🧪 Tesztállapot

Kötelező:

* új unit teszt a PostAuthInitNotifierhez (stubolt RPC callerrel)
* `./scripts/check.sh`

---

## 🌍 Lokalizáció

Nincs új UI szöveg.

---

## 📎 Kapcsolódások

Érintett / új fájlok (várható):

* `app/lib/src/features/rewards/data/signup_bonus_rpc.dart` (új)
* `app/lib/src/features/rewards/domain/signup_bonus_grant_result.dart` (új)
* `app/lib/src/features/rewards/application/post_auth_init_provider.dart` (új)
* `app/lib/src/features/auth/presentation/state/auth_provider.dart` (módosítás)
* `docs/core_logic/registration_flow.md` (kiegészítés a post-auth initről)
* `app/test/unit/bonus_system_post_auth_init_test.dart` (új)
* `codex/codex_checklist/bonus_system/bonus_system_flutter_post_auth_init.md`
* `codex/reports/bonus_system/bonus_system_flutter_post_auth_init.md`
