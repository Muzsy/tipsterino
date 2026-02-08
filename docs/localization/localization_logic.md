# Tipsterino – Lokalizációs logika (localization_logic.md)

## 🎯 Funkció

Ez a dokumentum rögzíti a Tipsterino projekt lokalizációs szabályait (HU/EN), a kulcsnév konvenciókat, a használati mintákat, és azt, hogy a Codex hogyan bővítheti biztonságosan a fordításokat úgy, hogy ne legyen hiányzó kulcs, ne legyen hardcode UI szöveg, és a kódgenerálás determinisztikus maradjon.

---

## 🧠 Fejlesztési részletek

## 1) Alapelvek

* **Nincs hardcode UI szöveg.** Minden felirat, gombszöveg, hibaüzenet, empty state, tooltip, snack, dialog szöveg lokalizált.
* **Két nyelv: HU + EN.** Minden új kulcs mindkét nyelvben kötelező.
* **Egy kulcs = egy jelentés.** Ne használd ugyanazt a kulcsot különböző kontextusokra.
* **Kulcs hiánya hiba.** Nincs „majd később”; hiányzó kulcs esetén a feladat nem kész.

---

## 2) Fájlok és generálás

### 2.1 ARB fájlok (forrás)

* `app/lib/l10n/app_en.arb`
* `app/lib/l10n/app_hu.arb`

### 2.2 Generált kód

* `AppLocalizations` (Flutter gen-l10n)
* A generált fájlokat **nem** szerkesztjük kézzel.

### 2.3 Generálás (elv)

* A projekt `flutter: generate: true` beállítással a build során generál.
* A Codex feladata: ARB módosítás után biztosítani, hogy `flutter pub get` / build / test lefut és a generált API elérhető.

---

## 3) Kulcsnév konvenciók

### 3.1 Feature-first prefix

Minden kulcs kapjon feature prefixet, pl.:

* `auth_...`
* `home_...`
* `ticket_...`
* `odds_...`
* `rewards_...`
* `profile_...`
* `settings_...`
* `common_...` (csak valóban univerzális szövegekhez)

### 3.2 Kulcs formátum

* `lower_snake_case`
* rövid, de egyértelmű
* kerülni kell a UI elem típusát a kulcsban (pl. ne: `loginButtonText`, inkább: `auth_login`)

Példák:

* ✅ `auth_login`
* ✅ `auth_email_hint`
* ✅ `ticket_save_success`
* ❌ `loginButtonText`
* ❌ `auth_login_btn_label_text`

### 3.3 Közös kulcsok

A `common_` prefixet csak akkor használd, ha a szöveg tényleg mindenhol ugyanazt jelenti:

* `common_ok`
* `common_cancel`
* `common_save`

Ha a gombszöveg kontextusfüggő (pl. „Mentés” vs „Szelvény mentése”), külön kulcs.

---

## 4) Használat a kódban

### 4.1 Hozzáférés

A Tipsterino kódban a lokalizált szöveg elérése:

* `final l10n = AppLocalizations.of(context)!;`
* majd: `l10n.<kulcsNév>`

Példa:

* `Text(l10n.auth_login)`

### 4.2 Nincs string literal UI-ban

Tilos:

* `Text('Bejelentkezés')`
* `Text("Login")`

Kivétel (szűk):

* teszt-azonosítók (`Key('...')`)
* debug-only logok (nem UI)

---

## 5) Paraméterezés és formázás

### 5.1 Interpoláció

Ha változót kell beszúrni (pl. név, szám), használj gen-l10n paramétert.

ARB példa:

```json
{
  "rewards_claim_success": "You received {amount} TippCoins!",
  "@rewards_claim_success": {
    "placeholders": {
      "amount": {}
    }
  }
}
```

Kód:

* `l10n.rewards_claim_success(amount)` (a pontos aláírás a generált kódtól függ)

**Szabály:** placeholder mindkét nyelvben azonos névvel szerepel.

### 5.2 Többes szám (plural)

Plural csak akkor, ha tényleg szükséges.

* Ha a projektben már van plural minta, azt kell követni.
* Ha nincs, előbb a docs-ban rögzíteni kell a mintát, majd bevezetni.

---

## 6) Lokalizációs QA ellenőrzések

### 6.1 ARB szinkron

* Minden új kulcs legyen mindkét ARB-ben.
* Ne legyen „árva” kulcs csak az egyik nyelvben.

### 6.2 UI ellenőrzés

* A UI ne törjön össze hosszabb szövegnél.
* Kritikus gomboknál figyelj a `softWrap`, `overflow`, `maxLines` beállításokra.

### 6.3 Tesztelés

Lokalizáció érintése esetén minimum:

* widget teszt, ami ellenőrzi, hogy a lokalizált string megjelenik
* mindkét locale-ra (ha a feladat érinti, vagy ha könnyen megoldható)

---

## 7) Codex szabályok lokalizációs feladatnál

### 7.1 Kötelező YAML step

Ha UI szöveg változik:

* legyen külön YAML step az ARB frissítésre
* outputs listában szerepeljen:

  * `app/lib/l10n/app_en.arb`
  * `app/lib/l10n/app_hu.arb`

### 7.2 Kötelező report tartalom

A reportot **kötelezően** a `docs/codex/report_standard.md` szerint kell kitölteni.

A reportban a lokalizációs részben kötelezően szerepeljen:

* milyen kulcsok kerültek hozzáadásra / módosításra
* mely UI elemek használják őket (konkrét file path alapján)
* futtatott parancsok és eredmények (analyze/test vagy `./scripts/check.sh` / `./scripts/verify.sh --report codex/reports/[<AREA>/]<TASK_SLUG>.md`)

Ajánlott formátum (táblázat):

| key | hu | en | used_in |
|---|---|---|---|
| `...` | `...` | `...` | `app/lib/...` |

---

## 🧪 Tesztállapot

### Definition of Done (L10n)

* [ ] Nincs hardcode UI szöveg
* [ ] Új kulcs mindkét ARB-ben szerepel
* [ ] Generált lokalizáció elérhető build/test után
* [ ] Van legalább 1 releváns widget teszt (ha UI-t érint)
* [ ] `./scripts/verify.sh --report codex/reports/[<AREA>/]<TASK_SLUG>.md` lefut (vagy dokumentált ok; fallback: `flutter analyze` + `flutter test`)

---

## 🌍 Lokalizáció

### Aktív nyelvek

* Magyar (hu)
* Angol (en)

### Nyelvváltás

* Ha a projekt támogat nyelvválasztót: a kiválasztott locale legyen tartós (pl. local storage), és az app újraindítás után is maradjon.
* Ha még nincs nyelvváltás: a bevezetést külön canvas+yaml feladatban kell elvégezni.

---

## 📎 Kapcsolódások

* `docs/codex/overview.md`
* `docs/codex/prompt_template.md`
* `docs/codex/yaml_schema.md`
* `docs/qa/testing_guidelines.md`
* `docs/architect/routing_integrity.md`
* `docs/architect/theme_rules.md`
* ARB források: `app/lib/l10n/app_en.arb`, `app/lib/l10n/app_hu.arb`
