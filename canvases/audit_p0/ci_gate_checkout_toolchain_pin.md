# Audit P0-5: CI gate checkout + toolchain pin

## 🎯 Funkcio
Celfeladat: CI gate determinisztikus stabilizalasa a checkout action es toolchain verziok explicit pinelesével.

Miert P0:
- ha a checkout tag ervenytelen/instabil, a gate nem ved semmit;
- `latest` toolchain drift random CI tor eseket okozhat.

Nem cel:
- teljes CI pipeline redesign
- uj job matrix bevezetese
- release pipeline epites

## 🧠 Fejlesztesi reszletek
Valos forrasok:
- `.github/workflows/ci.yml`
- `.github/workflows/ci_db.yml`
- `docs/qa/db_checks.md`
- `docs/qa/testing_guidelines.md`

Tervezett kimenetek:
- workflow pin frissites mindket CI fajlban (`actions/checkout`, Flutter, Supabase CLI)
- QA doksi frissites a valasztott pinelt verziokkal es upgrade policy rovid indoklassal

DoD:
- [ ] `ci.yml` es `ci_db.yml` nem hasznal lebego checkout taget
- [ ] Flutter action/csatorna explicit pinelt (nem driftelo)
- [ ] Supabase CLI verzio explicit pinelt (`latest` helyett)
- [ ] docs/qa oldalon dokumentalt a valasztott pin es frissitesi policy
- [ ] verify gate futas dokumentalva

Kockazat/rollback:
- Tulsagosan regi pin tooling incompatibilitast okozhat; rollback uj commitban kontrollalt verzioemelessel.

## 🧪 Tesztallapot
Kotelezo futtatas (task vegen):
- `./scripts/verify.sh --report codex/reports/audit_p0/ci_gate_checkout_toolchain_pin.md`

## 🌍 Lokalizacio
Nem erintett.

## 📎 Kapcsolodasok
- `docs/qa/db_checks.md`
- `docs/qa/testing_guidelines.md`
- `.github/workflows/ci.yml`
- `.github/workflows/ci_db.yml`
