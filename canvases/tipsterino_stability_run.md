# 🎯 Tipsterino stability + env resilience

## 🎯 Funkció

A Tipsterino app startupjához tartozó teendők (P1–P5) célja a dokumentációs/minták pontosságának, a `docs/` struktúra meglétének, a Supabase konfiguráció stabilitásának, a megbízható integration tesztnek és az analyze-t nem zavaró kódrészletek rendezésének biztosítása.
- P1: minden `canvases/`, `codex/`, `documents/`, `docs/` és `app/` hivatkozás valós fájlra mutasson (pl. az AppShell fájlát a `app/lib/src/screens/app_shell.dart` pontossággal írjuk).
- P2: a `docs/` OutshotCoach-váz ergo mappákba legalább egy README kerüljen és röviden megmagyarázza, hová kerülnek az anyagok.
- P3: a Supabase URL/ANON kulcs `--dart-define`-ból jöjjön, nincs `.env` fallback, a hiányzó konfiguráció offline módot jelent és ezt a dokumentáció/kulcsok is egyértelműen leírják.
- P4: az integration teszt ellenőrzi mind offline buildet (offline üzenet + gomb tiltva), mind konfigurált esetet (login/home jelenik meg), de nem szorít offlineNotice-re minden esetben.
- P5: unused importok/dedik kódrészek eltávolítása, a docok beállításai, checklist és report frissítése (magyarul) a végén.

## 🧠 Fejlesztési részletek

* `app/lib/main.dart` → `const` compile-time Supabase konstansok, nincs `.env` load, supabase guard provider override, `app/pubspec.yaml`-ból `flutter_dotenv` eltávolítva, `app/pubspec.lock` frissül.
* `app/lib/l10n/app_{en,hu}.arb` + generált `app/localizations.dart` → offline üzenet a dart-define beállításról szól (nem `.env`).
* `integration_test/app_test.dart` → pillanatnyi állapot olvasása (ha offline, ellenőrzi a `loc.offlineNotice`/`loc.offlineDescription` + tiltott gomb, ha konfigurált, akkor login vagy home képernyő), a teszt nem hagyatkozik offlineNotice-ra minden esetben.
* `documents/app_architecture.md`, `documents/supabase_configuration.md`, `canvases/tipsterino_foundation_bootstrap.md`, `codex/reports/tipsterino_foundation_bootstrap.md` → hivatkozások frissítve `app/...` prefixre, a Supabase infók naprakészek.
* `docs/README.md` → röviden leírja, mit várunk az egyes mappáktól (architect, core_logic, ...), hogy OutshotCoach stílusú struktúra legyen.
* Tesztparancsok: `dart format .`, `flutter analyze`, `flutter test`, `flutter devices`, `flutter test integration_test -d <eszköz>` (android). Ezek szerepelnek a canvas `Tesztállapot` részeként is.

## 🧪 Tesztállapot

* `cd app && dart format .`
* `cd app && flutter analyze`
* `cd app && flutter test`
* `cd app && flutter devices` → Android fizikai eszköz ID
* `cd app && flutter test integration_test -d <deviceId>` → offline/config statikus smoke

## 🌍 Lokalizáció

* `hu`, `en`: `AppLocalizations` `offlineNotice`, `offlineDescription` és auth stringek (log in/register, tab címek, gombok) a dart-define-specifikus üzeneteket mutatják.

## 📎 Kapcsolódások

* `documents/app_architecture.md` + új `documents/supabase_configuration.md`
* `docs/README.md` (OutshotCoach login structure)
* `codex/codex_checklist/tipsterino_stability_run.md`
* `codex/reports/tipsterino_stability_run.md`
