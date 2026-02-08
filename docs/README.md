# Tipsterino Documentation Structure

Ez a könyvtár az OutshotCoach mintájára rendezett képernyő- és architektúra-dokumentációt tartalmazza.

## 📁 Strukturált témák
- `architect/` – Architektúra áttekintés, komponens kapcsolatok, platform-specifikus megfontolások.
- `core_logic/` – Az üzleti logika főbb részei, provider- és state-implantációk, Supabase guardok.
- `data_model/` – Modellek, DTO-k, tesztadatok, mock struktúrák, ha később elkészülnek.
- `faq/` – Gyakori kérdések és válaszok a fejlesztők vagy tesztelők részére.
- `localization/` – Lokalizációs kulcsok jelentése, fordítási irányelvek, hozott lokalizációs pipeline.
- `qa/` – Minőségbiztosítási checklist, smoke/integration teszt minták, megfigyelések.
- `reference_tables/` – Szótárak, enumok, Supabase táblák rövidítései, kulcs-érték táblázatok.
- `screens/` – Képernyők specifikációi, vázlatok, acceptance kritériumok.

## 📝 Jövőbeli dokumentáció
Mindegyik almappa alá érdemes README-t/README.md-et tenni, amely leírja a mappában lévő fájlok látogatási célt és a kapcsolódó sablonokat.

## 🔗 Kapcsolódó anyagok
- `docs/architect/app_architecture.md` – részletes architektúra + környezet leírás.
- `docs/setup/supabase_configuration.md` – Supabase és `--dart-define` futtatási leírás.
- `canvases/tipsterino_foundation_bootstrap.md` és `canvases/tipsterino_stability_run.md` – a Codex-vásznak a fejlesztési sprint alapjául.
- `docs/screens/events_inbox_screen.md` – az Events Inbox UX filter/csatorna/guard logikáját, DoD-ját és a kapcsolódó teszteket összefoglaló dokumentum.

Megjegyzés: a `documents/` mappa deprecated/archív; új vagy naprakész tartalom csak a `docs/` fa alatt legyen karbantartva.
