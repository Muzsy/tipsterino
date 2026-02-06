## Mit találtunk?
- A daily bonus specifikáció eddig nem volt a repo-ban; csak scatter külön dokumentumok utaltak rá, így hiányzott a „single source of truth”.
- A bonus rendszer core logikája nem hivatkozott explicit módon a daily bonusra, ezért a dokumentum nehezen mutatta, hogyan illeszkedik a standard grant pipeline-hoz.

## Mit módosítottunk?
- `documents/bonus_system/daily_bonus.md` létrejött a reward definition, gate-ek, napi limit, RPC szerződés, mellékhatások, UI állapotok, lokalizációs kulcsok és DoD felsorolással.
- `docs/core_logic/bonus_system.md` új „Daily bonus” szekciót kapott, amely linkeli a spec fájlt, megerősíti a standard grant pipeline használatát, és világosan jelzi, hogy az implementáció (migráció/RPC/UI) külön taskokban készül.
- A checklistben rögzítettük a spec import, a core doksi frissítés és a repo gate lépéseit.

## Tesztek
- `./scripts/check.sh` – PASS (a Flutter analízis és az összes widget/unit teszt lefutott, részletes log: dependencia ellenőrzés + `app/test/widget/*.dart` + `app/test/unit/bonus_system_post_auth_init_test.dart` sikeresen futott).

## Következő lépések javasolt
1. A jövőbeni daily bonus implementációs taskokban (migráció, RPC, Flutter) hivatkozzanak a dokumentációban leírt specifikációra.
2. Ha további bónuszok jönnek, a spec-link/contract logikát más dokumentumokban is alkalmazzuk, hogy mindig legyen single source of truth.
