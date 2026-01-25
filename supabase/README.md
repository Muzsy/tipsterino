# Supabase scaffolding

Ez a mappa a Supabase CLI migrációk, trigger-ek és kapcsolódó fájlok otthona lesz. A cél, hogy a `supabase/` könyvtárból futtatható legyen a migrációs pipeline és a Supabase CLI parancsai.

## Következő lépések
1. `supabase init` (külön task). 
2. `supabase link <project-ref>` + migrációk létrehozása.
3. RLS/trigger/SQL tartalom committed migráció fájlokban.

## Titkok kezelése
- Titkok, kulcsok (SUPABASE_URL, ANON_KEY, SERVICE_ROLE stb.) **sosem** kerülnek ide.
- Az app `app/.env` vagy CI konfig biztosítja a `--dart-define`-eket.
