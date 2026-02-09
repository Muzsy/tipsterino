# Tipsterino – Tesztelési irányelvek (testing_guidelines.md)

## 🎯 Funkció

Ez a dokumentum rögzíti a Tipsterino projektben a **kötelező tesztelési minimumot**, a javasolt teszttípusokat, a futtatási parancsokat (wrapperrel), valamint azt, hogyan kell a Codexnek tesztet írnia és frissítenie úgy, hogy a változtatások **auditálhatók és stabilak** legyenek.

Cél:

* Ne romoljon meglévő működés.
* Minden érdemi változtatásnál legyen legalább egy releváns automata teszt.
* A tesztek lokálisan és CI-ben is determinisztikusan fussanak.

---

## 🧠 Fejlesztési részletek

## 1) Alapelv: tesztpiramis (Tipsterino verzió)

Ajánlott arány:

* **Unit tesztek**: a legtöbb (üzleti logika, tiszta funkciók, state)
* **Widget tesztek**: a kritikus UI logika (láthatóság, interakciók, validációk)
* **Integration tesztek**: a legkevesebb (kritikus end-to-end flow)

A Codex akkor dolgozik jól, ha **előbb unit + widget**, és csak a valódi flow-hoz kell integration.

---

## 2) Kötelező minőségkapu parancsok

### 2.1 Standard (wrapperrel)

Ha a repó biztosít wrapper scripteket, az az elsődleges út:

* (Codex / report) `./scripts/verify.sh --report codex/reports/[<AREA>/]<TASK_SLUG>.md` *(a `check.sh`-t futtatja, logot ment és frissíti a reportot)*
* (lokál gyors) `./scripts/check.sh`

### 2.2 Fallback (ha nincs wrapper)

Minimum:

* `flutter analyze`
* `flutter test`

**Szabály:** a Codex reportba mindig írja bele, mit futtatott és mi lett az eredmény.

---

## 3) Mikor milyen teszt kötelező?

### 3.1 UI változás (screen, komponens, layout, interakció)

**Minimum:** 1 widget teszt.

* Példa: gomb aktív/inaktív állapot, validáció, error state, lista üres állapota.

### 3.2 Routing / navigáció változás

**Minimum:** 1 widget smoke teszt a fő flow-ra.

* Ellenőrizd, hogy a route elérhető, és legalább a képernyő címe/kulcseleme megjelenik.

### 3.3 Lokalizáció (új szöveg, új kulcs)

**Minimum:**

* mindkét ARB frissül (EN + HU)
* widget tesztben legalább 1 ellenőrzés, hogy a string kulcs tényleg megjelenik (nem hardcode)

### 3.4 Domain logika / state változás

**Minimum:** 1 unit teszt.

* Példa: reducer, service, repository metódus, számítások, validáció.

### 3.5 Supabase integráció (adatlekérés/írás, RLS, edge function)

**Minimum:**

* unit teszt a kliens-hívás köré épített repository/service rétegen (mockolt klienssel)
* ha kritikus flow: 1 integration teszt (opcionális, de ajánlott)

**Fontos:** automata tesztben ne függj élő Supabase környezettől, kivéve ha külön „e2e” suite van.

#### Bonus RPC integracios elvaras (P1)

* A bonus RPC-khez (`grant_signup_bonus_if_eligible`, `grant_daily_bonus_if_eligible`) legyen dedikalt integration suite:
  * `app/integration_test/bonus_rpc_integration_test.dart`
* CI DB gate-ben a sorrend legyen determinisztikus:
  * `supabase db reset --local --no-seed` -> `./scripts/check_db.sh` -> CI auth user provision + sign-in validation -> `./scripts/flutter.sh test integration_test/bonus_rpc_integration_test.dart -d linux --dart-define=BONUS_TEST_EMAIL=... --dart-define=BONUS_TEST_PASSWORD=...`
* A CI workflow referencia: `.github/workflows/ci_db.yml`
* Lokalis sokszori integration futtatasnal a `supabase/config.toml` `auth.rate_limit.email_sent` legyen eleg magas, hogy a signup alapu teszt ne legyen flaky.

---

## 4) Tesztstruktúra és naming

### 4.1 Ajánlott mappázás

* Unit tesztek: `app/test/unit/...`
* Widget tesztek: `app/test/widget/...`
* Integration: `app/integration_test/...`

Ha a repó mást használ, azt kell követni (a Codex felderítés után a meglévő mintára igazít).

### 4.2 Fájlnév konvenció

* `*_test.dart` kötelező
* legyen beszédes: `login_form_test.dart`, `app_router_smoke_test.dart`, `reward_grants_repository_test.dart`

---

## 5) Stabil, determinisztikus tesztek – kötelező szabályok

### 5.1 Idő és időzítők

* Ne legyen „valódi” várakozás (sleep/delay) tesztben.
* Használj `pump`, `pumpAndSettle`, és ahol kell, időt injektálj (pl. `Clock`/idő-provider mintával).

### 5.2 Random / sorrend / flakiness

* Tilos randomra építeni (vagy seedelt randomot használj fix seed-del).
* Lista-sorrendet explicit állítsd be, ha a UI azt feltételezi.

### 5.3 Külső hálózat

* Tesztben nincs valós hálózati hívás.
* Minden repository/service kapjon mockolható interfészt.

### 5.4 Flutter binding és async

* Widget tesztnél mindig `TestWidgetsFlutterBinding.ensureInitialized()` implicit elég, de plugin initet ne erőltesd.
* Ha async: ellenőrizd, hogy `pumpAndSettle` nem akad be (ha igen, bontsd fel lépésekre).

---

## 6) Mockolás és függőségek (Tipsterino szabvány)

### 6.1 Mi mockolandó?

* Supabase kliens / repository hívások
* platform csatornák (pl. share, deep link) – lehetőleg adapteren keresztül
* idő, random, storage

### 6.2 Minta: Repository + Interface

* UI → use-case/service → repository interface → (valós implementáció)
* Tesztben: fake/mock repository

**Szabály:** a UI ne hívjon közvetlenül Supabase klienst.

### 6.3 Mit NE mockolj?

* tiszta funkciók, model mapping, egyszerű validation – ezek unit teszttel lefedendők

---

## 7) Widget teszt guideline (minimum receptek)

### 7.1 Mit ellenőrizz?

* alap render (nincs exception)
* kulcs UI elemek jelen vannak (pl. cím, CTA gomb)
* interakció: tap/enter → elvárt state
* error state: invalid input → hiba megjelenik

### 7.2 Lokalizáció widget tesztben

* `MaterialApp`-ot úgy építsd, hogy a l10n delegáltak be legyenek kötve.
* A tesztben válts `Locale('hu')` és `Locale('en')` között, ha a feladat érinti.

---

## 8) Integration teszt guideline (csak amikor kell)

### 8.1 Mikor kell?

* kritikus onboarding/auth flow
* ticket mentés + lista megjelenítés
* olyan bug, amit widget teszt nem tud megfogni (platform integráció, navigation stack)

### 8.2 Futatás

* A repó wrapperét kövesd (ha van `scripts/flutter.sh`).
* Tipikusan:

  * `./scripts/flutter.sh test integration_test -d <device>`

**Szabály:** ha device ID kell, azt a canvasban rögzítsd mint „lokális paraméter”.

---

## 9) Golden tesztek (csak indokoltan)

Golden tesztet csak akkor használj, ha:

* a projekt már bevezette a golden infrastruktúrát, és van stabil baseline
* vagy a feladat explicit UI regresszió-védelem

**Különben** widget teszt + smoke elég.

---

## 10) Codex kötelező dokumentálás (checklist + report)

### 10.1 Checklist tartalma (minimum)

* [ ] Érintett tesztek azonosítva
* [ ] Új/érintett logikához teszt hozzáadva/frissítve
* [ ] `flutter analyze` lefutott
* [ ] `flutter test` lefutott
* [ ] (ha releváns) integration/golden lefutott

### 10.2 Report tartalma (minimum)

A reportot **kötelezően** a `docs/codex/report_standard.md` szerint kell kitölteni (DoD→Evidence + Advisory).

* státusz: **PASS / FAIL / PASS_WITH_NOTES** (a report elején)
* futtatott parancsok (pontos) + rövid eredmény (PASS/FAIL)
* változások összefoglalója (módosított/létrehozott fájlok listája, csoportosítva: UI/State/DB/Docs)
* **DoD → Evidence Matrix**: minden DoD ponthoz bizonyíték (path + sorsáv) + 1–3 mondat
* hibák esetén: log kivonat + javítási javaslat
* nem-blokkoló UX/termék jellegű észrevételek kizárólag az **Advisory notes** blokkban (max 5 bullet)

---

## 🧪 Tesztállapot

### Definition of Done (DoD) teszt szempontból

Egy Codex feladat akkor kész, ha:

* [ ] A releváns tesztek léteznek és lefedik a változást (minimum policy szerint)
* [ ] A standard minőségkapu lefut (wrapper vagy fallback)
* [ ] A reportban dokumentálva van minden futás
* [ ] Nincs ismert flakiness (ha van: dokumentált ok + stabilizálási terv)

---

## 🌍 Lokalizáció

Tesztelési szabály lokalizáció esetén:

* Új UI string → EN+HU ARB frissítve
* Widget tesztben legalább 1 ellenőrzés, hogy a lokalizált szöveg jelenik meg
* Nincs „hardcode” UI szöveg, kivéve teszt-azonosítók (Key) és debug-only címkék

---

## 📎 Kapcsolódások

* `docs/codex/overview.md` – workflow és DoD
* `docs/codex/yaml_schema.md` – steps-séma kötelező
* `docs/codex/prompt_template.md` – prompt szabvány
* `docs/architect/routing_integrity.md` – routing szabályok
* `docs/architect/theme_rules.md` – UI/theme szabályok
* `docs/localization/localization_logic.md` – i18n szabályok
* `canvases/` – feladat specifikációk
* `codex/codex_checklist/` – feladat checklistek
* `codex/reports/` – futási riportok
