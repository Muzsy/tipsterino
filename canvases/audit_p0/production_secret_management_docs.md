# Audit P0-5: production secret management docs

## 🎯 Funkcio
Celfeladat: egyertelmu, commit-safe dokumentacio a production secret kezelesrol (Supabase URL/anon key, CI secret flow, tiltott kulcsok).

Nem cel:
- valos secret ertek rogzitese
- deployment pipeline teljes atirasa

## 🧠 Fejlesztesi reszletek
Valos forrasok:
- `AGENTS.md`
- `docs/setup/dev_setup.md`
- `README.md`
- `scripts/flutter.sh`
- `app/.env.example`

Tervezett kimenetek:
- uj doksi: `docs/setup/secret_management.md`
- setup doksi szinkron: `docs/setup/dev_setup.md`
- root hivatkozas: `README.md`
- pelda tisztitas: `app/.env.example`

DoD:
- [ ] a doksi kulon kezeli dev/stage/prod secret flow-t
- [ ] explicit tiltja a service_role es mas erzekeny kulcs commitjat
- [ ] wrapper alapu futtatasi minta szerepel (`./scripts/flutter.sh`, `./scripts/check.sh`)
- [ ] nincs valos secret vagy token a valtozasokban
- [ ] verify gate futas dokumentalt

Kockazat/rollback:
- Dokumentacios pontatlansag felreconfiguralhat buildet; reportban ellenorizni kell a mintaparancsokat.

## 🧪 Tesztallapot
Kotelezo futtatas (task vegen):
- `./scripts/check.sh`
- `./scripts/verify.sh --report codex/reports/audit_p0/production_secret_management_docs.md`

## 🌍 Lokalizacio
Nem erintett.

## 📎 Kapcsolodasok
- `AGENTS.md`
- `docs/setup/dev_setup.md`
- `README.md`
- `app/.env.example`
