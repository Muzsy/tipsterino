**PASS** - Setup guide dokumentacio kesz, verify es check gate zold.

## 1) Meta
* **Task slug:** `setup_guide_supabase_env_fresh_machine`
* **Kapcsolodo canvas:** `canvases/setup/setup_guide_supabase_env_fresh_machine.md`
* **Kapcsolodo goal YAML:** `codex/goals/canvases/setup/fill_canvas_setup_guide_supabase_env_fresh_machine.yaml`
* **Futas datuma:** 2026-02-08
* **Branch / commit:** `main@b8ed414`
* **Fokusz terulet:** Docs

## 2) Scope
### 2.1 Cel
1. Kanonikus setup guide letrehozasa friss gepes fejlesztoi indulashoz.
2. Supabase local stack futtatasi lepesek rogzitese CI-vel konzisztensen.
3. Wrapper-hasznalat es secrets szabalyok egyertelmu rogzitese.

### 2.2 Nem-cel (explicit)
1. Supabase schema/migracio modositas.
2. App kod vagy CI workflow atirasa.

## 3) Valtozasok osszefoglalasa (Change summary)
### 3.1 Erintett fajlok
* `docs/setup/dev_setup.md`
* `docs/setup/supabase_setup.md`
* `README.md`
* `docs/README.md`
* `documents/supabase_configuration.md`
* `codex/codex_checklist/setup/setup_guide_supabase_env_fresh_machine.md`
* `codex/reports/setup/setup_guide_supabase_env_fresh_machine.md`
* `codex/reports/setup/setup_guide_supabase_env_fresh_machine.verify.log`

### 3.2 Miert valtoztak?
* Az uj setup guide-ok egyseges, wrapper-alapu inditast adnak fresh machine es Supabase local setup esetere.
* A README es docs index most mar kozvetlenul az uj kanonikus setup doksikra mutat.

## 4) Verifikacio (How tested)
### 4.1 Kotelezo parancs
* `./scripts/verify.sh --report codex/reports/setup/setup_guide_supabase_env_fresh_machine.md`

### 4.2 Opcionlis, feladatfuggo parancsok
* `./scripts/check.sh`

## 5) DoD -> Evidence Matrix (kotelezo)
| DoD pont | Statusz | Bizonyitek (path + line) | Magyarazat | Kapcsolodo teszt/ellenorzes |
| -------- | ------- | ------------------------ | ---------- | --------------------------- |
| `docs/setup/dev_setup.md` letrejott wrapper parancsokkal | PASS | `docs/setup/dev_setup.md:1` | A dokumentum a `flutter.sh`, `check.sh`, `verify.sh` parancsokra epit. | Doksi ellenorzes |
| `docs/setup/supabase_setup.md` letrejott CI-konzisztens local lepesekkel | PASS | `docs/setup/supabase_setup.md:1` | Tartalmazza a `start`, `db reset --local --no-seed`, `check_db.sh` lepest. | Doksi ellenorzes |
| Gitignored env + kulcs tiltasa rogzitve | PASS | `docs/setup/dev_setup.md:36` | A guide explicit tiltja a kulcsok commitjat es nevezi a gitignored env fajlokat. | Doksi ellenorzes |
| `README.md` + `docs/README.md` hivatkozik az uj guide-okra | PASS | `README.md:22` | A setup szekciokban linkelve vannak az uj doksik. | Doksi ellenorzes |
| `documents/supabase_configuration.md` deprecate/redirect blokkot kapott | PASS | `documents/supabase_configuration.md:1` | A fajl tetejen a `docs/setup/*` canonical hely szerepel wrapper szabalyokkal. | Doksi ellenorzes |
| Repo gate lefutott es log mentve | PASS | `codex/reports/setup/setup_guide_supabase_env_fresh_machine.verify.log:1` | A verify futas PASS, a log letrejott es az AUTO_VERIFY blokk frissult. | `./scripts/verify.sh --report ...` |

## 8) Advisory notes (nem blokkolo)
* A setup guide drift elkerulesere minden scripts valtozasnal erdemes a setup doksikat is ellenorizni.

## 9) Follow-ups (opcionalis)
* Nincs kotelezo follow-up.

<!-- AUTO_VERIFY_START -->
### Automatikus repo gate (verify.sh)

- eredmény: **PASS**
- check.sh exit kód: `0`
- futás: 2026-02-08T23:28:37+01:00 → 2026-02-08T23:29:16+01:00 (39s)
- parancs: `./scripts/check.sh`
- log: `/home/muszy/projects/tipsterino/codex/reports/setup/setup_guide_supabase_env_fresh_machine.verify.log`
- git: `main@b8ed414`
- módosított fájlok (git status): 9

**git diff --stat**

```text
 README.md                           |  4 ++++
 docs/README.md                      |  3 +++
 documents/supabase_configuration.md | 11 +++++++++--
 3 files changed, 16 insertions(+), 2 deletions(-)
```

**git status --porcelain (preview)**

```text
 M README.md
 M docs/README.md
 M documents/supabase_configuration.md
?? canvases/setup/
?? codex/codex_checklist/setup/
?? codex/goals/canvases/setup/
?? codex/reports/setup/
?? docs/setup/dev_setup.md
?? docs/setup/supabase_setup.md
```

<!-- AUTO_VERIFY_END -->
