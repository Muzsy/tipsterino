# Bonus system daily bonus docs/spec sync checklist

## P1 – Canvas + terv
- [x] Canvas preflight ellenőrizte a `docs/core_logic/bonus_system.md` létezését és a `documents/` célját, így a konkrét fájlokra hivatkozás realisztikus.
- [x] Canvasban foglalt célok (spec import + core doc frissítés) illeszkednek a repo valós struktúrájához.

## P2 – Implementációs blokkok
- [x] `documents/bonus_system/daily_bonus.md` megkapta a reward definition/gate/rpc/UI/localization/DoD részleteket.
- [x] `docs/core_logic/bonus_system.md` új „Daily bonus” szekcióval linkeli a specet, rögzíti a standard grant pipeline használatát és jelzi, hogy az implementáció külön taskban készül.

## P3 – QA kapu
- [x] `./scripts/check.sh` lefutott (passz állapot, a standard analyze + widget/unit tesztek hibátlanul futottak).
