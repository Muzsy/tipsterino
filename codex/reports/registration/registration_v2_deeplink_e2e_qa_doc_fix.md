## Mit találtunk?
- A QA doc az Android `adb` parancsban FlutterActivity komponenst és az `io.tipsterino` package-et használta, ami eltér az app valós `com.yourorg.tipsterino/.MainActivity` setupjától.
- A dokumentum összemosta a platform wiring smoke tesztet a valódi verify-email flow-val, így könnyen félrevezethette a QA csapatot a siker/hiba eredmények kapcsán.
- A resend CTA feltételeit nem emelte ki; enélkül a smoke teszt esetén is a gomb megjelenését várná az olvasó.

## Mit módosítottunk?
- Két külön szekcióra bontottuk a QA docot: (1) Smoke / wiring intent, amely component nélküli `adb` parancsot mutat be és explicit error/expired várakozást ír le; (2) Valódi verify-email E2E, ami a `?email=` query parammal fut és success + Continue eredményt vár.
- Az Android parancsok most a valós `com.yourorg.tipsterino/.MainActivity` komponenssel is mutatnak példát, de a preferált intent az OS-resolve-ot használja (component nélkül).
- Resend CTA kapott dedikált szekciót: a gomb csak akkor jelenik meg, ha a callback URI tartalmaz `?email=`, így a smoke tesztnél nem várható az extra opció.

## Tesztek
- `./scripts/check.sh` – PASS (doc-only változtatás).

## Ismert korlátok / TODO
- Nincs; ez dokumentációs változtatás.

## Következő javasolt lépések
1. QA csapattal futtassák újra a smoke parancsot és a verify-email flow-t valós eszközön, hogy megerősítsék a parancssoros leírások helyességét.
