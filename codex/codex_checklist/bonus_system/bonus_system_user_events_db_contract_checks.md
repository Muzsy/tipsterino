# Bonus system user_events DB contract checks checklist

## P1 – Canvas + terv
- [x] A canvas meghatározza az oszlop/típus követelményeket, az RLS-t, a privilege-szerződést és az index-sanityt (`user_id` + `created_at`).
- [x] A terv arra fókuszál, hogy a script `BEGIN; ... ROLLBACK;` blokkon belül fusson, `SET LOCAL search_path TO pg_catalog, public, auth;`-ot állítson be, és csak `DO $$ ... $$` blokkokban legyenek ellenőrzések.

## P2 – Implementációs blokkok
- [x] A `information_schema.columns` alapján ellenőröljük, hogy az `id`, `user_id`, `type`, `code`, `amount`, `payload`, `created_at` és `read_at` oszlopok léteznek és a repóban definiált típusokkal (UUID/text/integer/jsonb/timestamptz) szerepelnek.
- [x] Győződjünk meg, hogy RLS engedélyezett (`pg_class.relrowsecurity`) és az authenticated SELECT joggal rendelkezik, de INSERT/DELETE jog nincs.
- [x] Az oszlopszintű UPDATE jogoknál csak `read_at`-ra van engedély, a `type`, `code`, `amount` és `payload` tiltott.
- [x] Az index-sanityt `pg_index`, `pg_class` és `pg_attribute` join-nal ellenőrizzük, biztosítva, hogy legalább egy index tartalmazza a `user_id` és `created_at` oszlopokat.

## P3 – QA kapu
- [x] `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_user_events_db_contract_checks.sql` lefutott (jelen környezetben az authenticated még INSERT jogot kapott, ezért hibát dob a check).
