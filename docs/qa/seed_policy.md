# Seed policy (Supabase local)

## Mi a seed szerepe ebben a repoban?
- A `supabase/seed.sql` jelenleg szandekosan no-op placeholder.
- A fajl azert letezik, mert a `supabase/config.toml` seed path-ja hivatik erre.
- A repo seed strategiaja nem feature-adatfeltoltesre epul.

## CI es DB contract check policy
- CI workflow: `.github/workflows/ci_db.yml`
- DB check guide: `docs/qa/db_checks.md`
- Mindketto `supabase db reset --local --no-seed` modban fut.
- Ez szandekos: a contract check legyen determinisztikus es seedtol fuggetlen.

## Miert nem seedelunk `auth.users`-t?
- Az `auth.users` seed brittlen es felrevezetoen modellez valos auth flow-t.
- User-bound adatok altalaban RLS-fuggoek, ezert altalanos seed nem stabil alap.
- A valos user-allapot app-flow-bol reprodukalhato.

## Hogyan keszul dev tesztadat seed nelkul?
1. Regisztracio / belepes app-flowval.
2. Daily bonus claim flow lefuttatasa felhasznaloi oldalon.
3. `user_events` es kapcsolodo adatok ellenorzese lokalis Supabase Studio-ban.

## Ha a jovoben megis kell seed
- Csak nem-user-bound, determinisztikus referenciaadat jon szoba.
- Schema valtozas tovabbra is migracioban tortenjen.
- CI policy marad: `--no-seed`.
