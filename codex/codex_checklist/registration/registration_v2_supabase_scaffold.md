# Registration v2 Supabase scaffold – Checklist

## DoD
- [x] Canvas + goal YAML létrehozva a Supabase CLI scaffold céljáról.
- [x] `supabase/README.md`, `supabase/migrations/.gitkeep` és `supabase/functions/.gitkeep` létrehozva a Supabase helyi struktúrához.
- [x] A `.gitignore` biztosítja, hogy a CLI lokális állapotfájljai (`.temp/`, `.branches/`, `.cache/`, `.local/`) ne kerüljenek commitba.
- [x] A `scripts/supabase.sh` wrapper létezik, ellenőrzi a CLI telepítését és csak `supabase` parancsokat futtat (titkokat nem echo-ol).
- [x] `bash -n scripts/supabase.sh` és `./scripts/check.sh` lefutottak.

## Feladat-specifikus pontok
- [x] A `supabase/README.md` röviden leírja a célokat és tiltja a titkokat.
- [x] A `.gitignore` új bejegyzései csak a CLI állapotát takarják, a `supabase/migrations/` továbbra is verziózható.
- [x] A wrapper script nem ír ki environment változót vagy token értéket, és a PATH-ot ellenőrzi.

## Nyitott kérdések / teendők
- Ha később Supabase CLI futtatás szükséges, győződjünk meg róla, hogy a runner környezete rendelkezik a CLI-val, vagy a `scripts/supabase.sh` használatakor összhangban marad a secret policy-val.
