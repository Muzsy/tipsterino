# Bonus system – RPC signup bonus: profile complete gate (DB enforce)

**TASK_SLUG:** `bonus_system_rpc_signup_bonus_profile_complete_gate`

---

## 🎯 Funkció

A `public.grant_signup_bonus_if_eligible()` RPC kapjon DB-szintű “profile complete” gate-et:

- Ha a profil nem teljes (pl. nickname hiányzik vagy avatar hiányzik), akkor:
  - `granted=false`
  - `reason='profile_incomplete'`
  - nincs DB mellékhatás (no grants/stats/events)

A “profile complete” definíció a jelenlegi regisztrációs szerződés szerint:
- nickname kötelező
- avatar kötelező (mező a profiles táblában / storage ref)

---

## 🧠 Fejlesztési részletek

### Előfeltételek (tény)

- profiles tábla és a “complete profile” követelmény dokumentálva van a regisztrációs anyagokban
- a signup bonus jelenleg email verified gate-re épít (reason: not_verified)

### Implementáció

1) Új migráció:
- `supabase/migrations/20260205000000_bonus_system_signup_bonus_profile_complete_gate.sql`

Tartalom:
- `CREATE OR REPLACE FUNCTION public.grant_signup_bonus_if_eligible()` módosítása:
  - auth.uid() után olvasd a `public.profiles` sort
  - ellenőrizd: nickname nem null/nem üres, avatar mező nem null/nem üres (a repo mezőnevei szerint)
  - ha nem teljes: return jsonb `{granted:false, reason:'profile_incomplete'}` (és exit)

2) Frissítsd a behavior checks fájlt:
- `supabase/sql_checks/bonus_system_rpc_signup_bonus_behavior_checks.sql`
  - új teszteset: verified, de profile incomplete → profile_incomplete + no side effects
  - granted csak profile complete esetén

---

## 🧪 Tesztállapot

Kötelező:

- `supabase db push` (vagy migrations futtatása a szokásos flow-val)
- utána psql checks futtatás (behavior checks)

---

## 🌍 Lokalizáció

Nincs (DB only).

---

## 📎 Kapcsolódások

- új migration
- behavior checks frissítés
- checklist + report
