# 🎯 Funkció

A regisztrációs v2 flow DB alapjait offline migrációként írjuk meg: egyetlen SQL fájlban definiáljuk a profil táblát, RLS-t, view-t, RPC-t és triggert. Ez a task **korai, CLI-független lépés**; a futtatás (Prompt #04B) külön környezetben történik.

### Nem cél
- A Supabase CLI vagy psql parancsok futtatása.
- Flutter app kód vagy ARB fájlok módosítása.
- Rewards/user_events/user_stats táblák létrehozása.

---

# 🧠 Fejlesztési részletek

### Talált releváns fájlok
- `docs/data_model/profiles_table_doc.md` – leírja a profil/adatmodel logikát (nickname, avatar_key, triggeres létrehozás).
- `supabase/README.md` és `supabase/migrations/` – meglévő scaffold a migrációs fájlok tárolására.
- `documents/authentication/auth_implementation_plan.md` – a triggeres auth flow követelményei (AUTH_NO_PROFILE, metadata a signupban).

### Pipálható teendők
- [ ] Létrehoztuk a `supabase/migrations/20260125000000_registration_v2_profiles_rls_trigger.sql` migrációs SQL-t mind a táblára, view-ra, RLS-re, RPC/triggerre.
- [ ] Írtunk egy `supabase/sql_checks/registration_v2_profiles_rls_trigger_checks.sql` fájlt a későbbi ellenőrzésekhez.
- [ ] Canvas + goal + checklist + report artefaktok elkészültek.
- [ ] `./scripts/check.sh` lefutott (CLI nélkül).

### Kockázatok + rollback terv
- **Kockázat:** SQL migráció nincs szinkronban a tényleges DB-vel (más taskban majd futtatáskor derül ki). **Rollback:** új migráció generálása, a meglévő SQL felülírása és újra átnézés.
- **Kockázat:** hibás trigger logika. **Rollback:** script módosítás, új SQL commit -> következő promptban újra lefuttatjuk.

---

# 🧪 Tesztállapot

- Teszt terv (offline):
  1. `./scripts/check.sh` (Flutter lint/test)
  2. Később (prompt #04B): Supabase CLI lekérdezések futtatása a `supabase/sql_checks/` fájlon.

---

# 🌍 Lokalizáció

- Egyik fájl sem érinti a lokalizációt; a szöveg változatlan.

---

# 📎 Kapcsolódások

- `documents/authentication/auth_implementation_plan.md`
- `docs/data_model/profiles_table_doc.md`
- `supabase/migrations/` (a migrációs content célhelye)
