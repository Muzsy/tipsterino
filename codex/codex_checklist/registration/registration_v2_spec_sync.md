# Registration v2 spec sync – Checklist

## DoD
- [x] Canvas + goal YAML készen a feladat leírására.
- [x] A `docs/core_logic/registration_flow.md` frissítve az új jelszó-szabályokra, confirm password hiányára és a 3. lépésben történő `signUp`-ra.
- [x] A `docs/data_model/profiles_table_doc.md` és a `docs/data_model/user_stats_table_doc.md` az `avatar_key` + triggeres profil létrehozás logikáját tükrözi; kliens INSERT tiltva.
- [x] `./scripts/check.sh` futtatva (elemzés és tesztek lefutottak, a wrapperben a `--dart-define` csak a támogatott alparancsok után kerül hozzáadva).

## Feladat-specifikus pontok
- [x] `avatar_key` preset logika dokumentálva, a `public_profiles` view is csak erre hivatkozik.
- [x] A dokumentációban megszűnt minden `avatar_path` referencia a profil/registration témában.
- [x] Automatizált ellenőrzési parancs futtatása sikeresen lefutott (analyze + test).

## Nyitott kérdések / teendők
- A `./scripts/check.sh` runnál a `flutter` kiadása figyelmeztetett, hogy új verzió érhető el, és több csomagban is elérhető upgrade; ezek ugyan nem blokkolták a futást, de érdemes figyelni későbbi frissítések kapcsán.
