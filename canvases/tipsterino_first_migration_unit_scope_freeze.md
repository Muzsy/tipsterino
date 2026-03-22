# Canvas: First Migration Unit Scope Freeze

## 🎯 Funkció

Ez a canvas a `tippmixapp` → `tipsterino` migráció **első konkrét migrációs egységét** rögzíti: a `chat` (1:1 közvetlen üzenetküldés) feature-t. A canvas Scope Freeze dokumentumként szolgál a következő implementációs feladathoz.

## 📌 Migrációs egység: `chat` — 1:1 Direct Messaging

**Forrás (read-only reference):** `tippmixapp/lib/features/chat/`  
**Cél (implementációs célpont):** `tipsterino/app/lib/src/features/chat/`  
**DB referencia:** `tippmixapp/supabase/migrations/20250922180200_messages_table.sql`

---

## ✅ In-Scope (Bounded)

### Funkcionális viselkedés
- 1:1 privát üzenetküldés két autentikált felhasználó között
- Valós idejű üzenet stream Supabase realtime-on keresztül (`messages` tábla)
- Szöveges üzenet küldése (max 2000 karakter, trimmed)
- Beszélgetési előzmények megtekintése
- Olvasottnak jelölés implicit módon (`read_at` mező)

### Technikai követelmények
- Feature-first mappastruktúra: `domain/`, `data/`, `providers/`, `presentation/screens/`
- Repository minta: interface + Supabase implementáció
- Auth-gated: csak bejelentkezett felhasználók érik el
- Riverpod state management (Tipsterino konvenciók szerint)
- HU + EN lokalizáció minden UI szövegre
- GoRouter kompatibilis screen

### Érintett fájlok (migráció + új)

#### Migrálandó (TippmixApp → Tipsterino adapterrel)
- `tippmixapp/lib/features/chat/domain/chat_message.dart` → `app/lib/src/features/chat/domain/chat_message.dart`
- `tippmixapp/lib/features/chat/domain/chat_exception.dart` → `app/lib/src/features/chat/domain/chat_exception.dart`
- `tippmixapp/lib/features/chat/data/chat_repository.dart` → `app/lib/src/features/chat/data/chat_repository.dart` (adapter: Tipsterino `supabaseConfigProvider`)
- `tippmixapp/lib/features/chat/providers/chat_providers.dart` → `app/lib/src/features/chat/providers/chat_providers.dart` (adapter: Tipsterino `authProvider`)

#### Újonnan létrehozandó (Tipsterino-native)
- `app/lib/src/features/chat/presentation/screens/chat_screen.dart` — UI a Tipsterino theme/l10n konvenciók szerint
- `supabase/migrations/<timestamp>_messages_table.sql` — DB séma TippmixApp referencia alapján
- `app/lib/l10n/app_en.arb` — bővítés chat kulcsokkal
- `app/lib/l10n/app_hu.arb` — bővítés chat kulcsokkal

---

## 🚫 Explicitly Out-of-Scope

- Csoportos / club chat (külön `club_chat` feature TippmixApp-ben)
- Push notifikációk üzenetekre
- Üzenet szerkesztés vagy törlés
- Felhasználó blokkolás/még nem figyelés
- Online státusz indikátorok
- Üzenet keresés
- Kép vagy fájl mellékletek
- Bármilyen Firebase/Firestore kód migrálása

---

## 🔗 Kapcsolódó dokumentumok (implementáció előtt olvasandó)

1. `docs/architect/project_structure.md` — feature-first mappaszerkezet szabályai
2. `docs/architect/service_dependencies.md` — Supabase kliens injektálási minta
3. `docs/localization/localization_logic.md` — ARB kulcs konvenciók
4. `docs/architect/routing_integrity.md` — GoRouter minták
5. `docs/architect/theme_rules.md` — nincs hardcoded színek
6. `docs/qa/testing_guidelines.md` — minimális tesztkövetelmények
7. `app/lib/src/features/auth/presentation/state/auth_provider.dart` — auth minta
8. `app/lib/src/features/events/presentation/screens/events_inbox_screen.dart` — Tipsterino screen minta (poll/stream kezelés)
9. `canvases/tipsterino_first_migration_unit_scope_freeze.md` — ez a canvas (Scope Freeze)

---

## 📋 Feladatlista ( checkpoints )

- [ ] **CP1:** DB migráció létrehozva a `messages` táblához (`supabase/migrations/`)
- [ ] **CP2:** Domain réteg migrálva: `chat_message.dart`, `chat_exception.dart`
- [ ] **CP3:** Data réteg migrálva + adapterelve: `chat_repository.dart` (Tipsterino `supabaseConfigProvider`)
- [ ] **CP4:** Provider réteg migrálva + adapterelve: `chat_providers.dart` (Tipsterino `authProvider`)
- [ ] **CP5:** Chat screen létrehozva Tipsterino-native módon (`chat_screen.dart`)
- [ ] **CP6:** GoRouter route regisztrálva (`app_router.dart` vagy `app_shell.dart` según scope)
- [ ] **CP7:** ARB kulcsok bővítve HU + EN nyelven
- [ ] **CP8:** Widget teszt létrehozva chat screen-hez
- [ ] **CP9:** `./scripts/verify.sh --report codex/reports/migration/chat_feature_migration.md` → zöld
- [ ] **CP10:** Checklist kipipálva + report lezárva

---

## ⚠️ Kockázatok és Rollback

### Kockázatok
| Kockázat | Valószínűség | Hatás | Mitigation |
|----------|-------------|-------|-----------|
| `messages` tábla RLS policy túl széles vagy túl szűk | Közepes | Közepes | TippmixApp RLS mintát követni; review előtt nem megy production-be |
| Tipsterino auth provider nem kompatibilis chat provider-rel | Alacsony | Közepes | Auth provider már kész — adapter réteg feladata |
| Realtime subscription memory leak | Alacsony | Közepes | `autoDispose` Riverpod provider; `dispose` hívás ellenőrzése |

### Rollback határ
- Ha DB migráció hibás: migration fájl visszaállítása; chat kód marad de nem működik DB nélkül
- Nincs irreducibilis Supabase változtatás — standard CRUD

---

## ❓ Open Questions

1. A chat screen a bottom-nav tab-on legyen elérhető, vagy csak deep-linkről (friends/profile)?
   → Döntés: implementációs feladat (jelen scope csak a screen létrehozását tartalmazza)
2. Tipsterino Supabase projektnek már van `messages` táblája? → Ellenőrizve: NEM — létre kell hozni
3. Club chat benne van ebben az unit-ban? → Döntés: NEM — explicit out-of-scope

---

## 📎 Kapcsolódások

- Következő feladat: `chat_feature_migration`
- TippmixApp referencia: `tippmixapp/lib/features/chat/`
- TippmixApp DB referencia: `tippmixapp/supabase/migrations/20250922180200_messages_table.sql`
