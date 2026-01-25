# 🎯 Funkció

A `documents/authentication/auth_implementation_plan.md` iránymutatása alapján a regisztrációs/auth dokumentációt szinkronizáljuk úgy, hogy a jelszó, avatar és profil létrehozás szabályai azonosak legyenek a jelenlegi implementációs tervvel.

A dokumentum célja, hogy a `docs/core_logic/registration_flow.md`, a data-model leírások és a kapcsolódó referenciák ugyanazt a 3 lépéses wizardot és triggeres profil-létrehozást írják le, beleértve az új jelszó-szabályokat, az `avatar_key` preset logikát és a signUp kizárólagos 3. lépését.

### Nem cél
- `app/` kód módosítása.
- Supabase migrációk, trigger vagy SQL létrehozása.
- `documents/registration/registration_flow_V2-md` módosítása (csak referenciaként olvasva).
- Új onboarding/reward spec írása; ha a rewards-logika továbbra is keveredik, külön sprintre kell helyezni.

---

# 🧠 Fejlesztési részletek

### Célok
- A `docs/core_logic/registration_flow.md` frissítése: új jelszó-szabályok, nincs confirm password, signUp csak a 3. lépésen.
- A `docs/data_model/profiles_table_doc.md` átírása `avatar_key`-re, triggeres profil létrehozásra, és a kliens INSERT tiltására.
- A `docs/data_model/user_stats_table_doc.md` tükrözze, hogy a profil- és stat-létrehozás trigger alapú és az avatar preset `avatar_key` technikai rész.

### Talált releváns fájlok
- `documents/authentication/auth_implementation_plan.md` – a legfrissebb Spec-forrás, amely meghatározza a regisztráció wizardot, jelszó-szabályokat, avatar_key és triggeres profillétrehozást.
- `docs/core_logic/registration_flow.md` – ez a doc direkt ellentmondásban áll (jelszó kritériumok, avatar_path, signUp), ezért szinkronizálni kell.
- `docs/core_logic/authentication_flow.md` – a GUEST/AUTH állapotmodell és triggeres profilgarancia leírása, amit a regisztráció flow-nak is követnie kell.
- `docs/data_model/profiles_table_doc.md` – jelenleg `avatar_path`-ot említ és kliens INSERT-et feltételez.
- `docs/data_model/user_stats_table_doc.md` – leírja, hogy a regisztráció során a `profiles.avatar_path` és kliens INSERT kell; ezt a triggeres `avatar_key` logikára kell állítani.
- `documents/registration/registration_flow_V2-md` – a Codex task leírása, amely a konfliktusokat összegzi (csak referenciaként használva).

### Érintett fájlok
- `docs/core_logic/registration_flow.md`
- `docs/data_model/profiles_table_doc.md`
- `docs/data_model/user_stats_table_doc.md`
- `canvases/registration/registration_v2_spec_sync.md`
- `codex/goals/canvases/registration/fill_canvas_registration_v2_spec_sync.yaml`
- `codex/codex_checklist/registration/registration_v2_spec_sync.md`
- `codex/reports/registration/registration_v2_spec_sync.md`

### Pipálható teendők
- [x] Összefoglaltuk a talált dokumentum-ellentmondásokat és rögzítettük őket a canvasban.
- [x] Frissítettük a regisztráció flow dokumentációját a jelszó és signUp követelményekhez.
- [x] Átírtuk a data-model dokumentumokat az avatar_key + triggeres profil létrehozás logikára és tiltott kliens INSERT-re.
- [x] Hozzáadtuk a goal YAML lépéseit, tesztelési utasításokat, majd futtattuk `./scripts/check.sh`.
- [x] Kitöltöttük a checklistet és frissítettük a reportot a ellenőrzés kimenetével.

### Kockázatok + rollback terv
- **Kockázat:** nem vesszük észre más dokumentumokat, amelyek `avatar_path` vagy kliens INSERT feltevést tartalmaznak.
  **Rollback:** ha hibát találunk, visszaállítjuk a kapcsolódó docokat (`git checkout -- <file>`), és újra egyeztetünk a spec-eredménnyel.
- **Kockázat:** a jelszó-szabályok félreérthetők maradnak; a rollback a korábbi változat visszaállítása és a szabályok egyértelmű ismertetése a docban.

---

# 🧪 Tesztállapot

- Teszt terv (dok task): `./scripts/check.sh` futtatása a repó standard ellenőrzésének lefuttatásához.
- Dokumentációs validáció: `rg "avatar_path" docs/ docs/data_model/` használatával ellenőrizzük, hogy csak az új `avatar_key` logika maradt.
- További manuális ellenőrzés: ellenőrizzük, hogy a canvasban és a docokban nem maradt `confirm password` említés.

---

# 🌍 Lokalizáció

- Ez a task nem bővít UI szöveget; a létező lokalizációs kulcsok változatlanok.
- Ha a további flow-oknál új kulcs lesz szükséges, azt külön feladatban kell hozzáadni (nem része a current scope-nak).

---

# 📎 Kapcsolódások

- `documents/authentication/auth_implementation_plan.md`
- `docs/core_logic/authentication_flow.md`
- `documents/registration/registration_flow_V2-md`
- `docs/data_model/profiles_table_doc.md`
- `docs/data_model/user_stats_table_doc.md`
