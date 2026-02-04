## Mit találtunk?
- A Supabase MCP preflight olvasása (`codex mcp list`/resources) megpróbálta ellenőrizni, hogy a reward_* / user_* táblák nem léteznek, de a handshake az OAuth token frissítésénél (`failed to parse server response`) meghiúsult, ezért a reportban dokumentáljuk, és a valós ellenőrzést a helyi `.env.local` + `./scripts/supabase.sh db push` + `psql ... -f ...` párossal végezzük.
- A `pg_policies` tábla helytelen `polname` oszlopnévre hivatkozó ellenőrzése hibát dobott az első `psql` futtatásnál, ezt átírtuk `policyname`-re a checks fájlban, majd a javított változat futott sikeresen.

## Mit módosítottunk?
- A canvas kibővült a preflight részleteivel, a seed/migráció/checks fájlokra és a `.env.local` betöltésére vonatkozó wrapper parancsokkal, valamint az MCP olvasó ellenőrzésének dokumentálásával.
- Létrehoztuk a 20260203000000-as migrációt, amely a táblák leírását, az `updated_at` trigger szettet, az RLS/policy/grant szekvenciát, valamint az ideiglenes (`amount = 0`) `signup_bonus` bootstrap rekordot tartalmazza.
- Elkészítettük a checks fájlt, amely táblák, RLS, policy-k, indexek és a `signup_bonus` rekord meglétét validálja, valamint a kötelező `supabase/seed.sql` placeholdert.

## Módosított/létrehozott fájlok
- `canvases/bonus_system/bonus_system_db_schema_rls.md`
- `supabase/seed.sql`
- `supabase/migrations/20260203000000_bonus_system_db_schema_rls.sql`
- `supabase/sql_checks/bonus_system_db_schema_rls_checks.sql`
- `codex/codex_checklist/bonus_system/bonus_system_db_schema_rls.md`
- `codex/reports/bonus_system/bonus_system_db_schema_rls.md`

## Tesztek
- `set -a; source .env.local; set +a; ./scripts/supabase.sh db push` – PASS (extension/policy/trigger hiány miatt a CLI NOTICE-okat dobott, de a migráció alkalmazva lett és a `signup_bonus` sor is beszúródott).
- `set -a; source .env.local; set +a; psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f supabase/sql_checks/bonus_system_db_schema_rls_checks.sql` – PASS (az egyetlen előzetes hiba a `polname`-ról `policyname`-re való javítás volt; a script most már lefut és megerősíti a táblák, policy-k, indexek és a `signup_bonus` rekord létezését).
- `./scripts/check.sh` – PASS (repo standard gate). 

## Következő javasolt lépések
1. A Supabase MCP authentikációs hitelesítési problémáját orvosolni, hogy a táblák real-time meglétének preflight ellenőrzése automatikusan megbízható legyen.
2. A `docs/core_logic/registration_flow.md` és az Edge Functionok dokumentációja legyen összhangban a verifikáció utáni `signup_bonus` triggerrel.
3. A `reward_definitions.signup_bonus` pontos értékét későbbi migráción át kell állítani a végleges összegre, a jelenlegi 0 érték csupán placeholder az onboarding során.
