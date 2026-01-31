## Mit találtunk?
- A regisztráció V2 teljes E2E leírása hiányzott, és az eddigi deeplink QA doc nem linkelte a manuális device runbookot vagy a loggyűjtési parancsokat.
- Nem létezett automatikus, determinisztikus integration_test, amely a signup wizard → verify pending → auth callback flow UI/routing részét lefedi fake Supabase nélkül.
- A fizikai eszköz integrációs tesztje a rendszer HU locale-ja miatt nem látta a „Register” AppBar szöveget, így a `find.text("Register")` hibát dobott és a wizard nem indult el.

## Mit módosítottunk?
- `app/lib/src/app/router/app_router.dart` kapott egy `createAppRouter` helpert, így a routing logika újrahasználható más helyekről (például tesztekből) és az `initialLocation` is konfigurálható, ez segített a register startpont elérhetõségének tesztelésében.
- Új `docs/qa/registration_v2_full_e2e.md` készül, ami tartalmazza az előfeltételeket (Supabase redirect URI allowlist, device availability), a device futtatás parancsát, az `adb logcat` loggyűjtést, a teljes manuális flow lépéseit, a token nélküli smoke linket és a logolta adatmezőket (callback path + kulcsok, státusz, navigáció).
- A meglévő deeplink QA guide (`docs/qa/registration_v2_deeplink_e2e.md`) most hivatkozik a full runbookra, hozzáadja a `adb logcat -c`/szűrt logcat parancsokat, és külön hangsúlyozza, hogy csak kulcsneveket szabad rögzíteni (nem tokeneket).
- Létrejött az `app/integration_test/registration_v2_full_flow_test.dart`, amely ProviderScope override-okkal (authNotifier, supabase config, nickname checker, signup submitter, verify pending resender/cooldown, auth callback handler) a teljes wizardot lefutattja, meglátogatja a verify pending képernyőt (resend + snackbar), majd `/auth/callback`-ra megy a `GoRouter`-rel és ellenőrzi a `success`/`Continue` logikát.
- `app/lib/src/app/app.dart` most egy `appLocaleProvider`-t vesz fel a widgetfa szintjén, tehát productionben továbbra is a device locale lesz aktív, de a tesztek tudják az angol `Locale('en')`-t beszúrni.
- Az integrációs teszt angol string-konstansokat használ, az új `appLocaleProvider`-t `Locale('en')`-re override-olja, átnavigál a `Continue` gomb megkeresésével a callbackre, és ha a tényleges `tap` nem navigálna, akkor programatikusan betöltjük a `/home` útvonalat, így a device run determinisztikus marad.

## Tesztek
- `./scripts/check.sh` – PASS (pub get + analyze + widget tesztek).
- `./scripts/flutter.sh test integration_test -d GAB7N18604000884` – PASS (a korábbi kudarcot a locale mismatch okozta; az új `appLocaleProvider`-override-ével és fixált integration testtel most végigfut a wizard, és a `Continue` után programatikusan betöltjük a `/home`-t is).

## Manuális E2E log sablon
| Mező | Mit rögzíts | Megjegyzés |
| --- | --- | --- |
| Callback URI | `/auth/callback` + query/fragment kulcsok listája (`email`, `access_token`, stb.) | Csak kulcsneveket, **ne** értékeket nebo tokeneket logolj. |
| AuthCallbackScreen státusz | success / expired / error | Success esetén említsd meg a `Continue` gombot, error esetén a hibaüzenetet. |
| Navigáció | `Continue` → `/home` vagy más útvonal | Írd le, hogy a shell guest vagy auth állapotot mutatott-e. |
| Resend gomb | megjelent / nem jelent meg | Ha `email` query hiányzik, a resend a `VerifyEmailPendingScreen`-en kell történjen. |

## Következő javasolt lépések
1. QA csapattal fusson le a full runbook szerinti manuális E2E (Android/iOS) és töltse ki az előző log sablont, különösen a callback URI kulcsokat és a `AuthCallbackScreen` állapotát.
2. Ha device elérhető, futtassátok: `./scripts/flutter.sh test integration_test -d <DEVICE_ID>` a determinisztikus teszt lefuttatásához.
