# Migration Report: Chat Feature Migration

**Task slug:** `chat_feature_migration`  
**Kapcsolódó canvas:** `canvases/chat_feature_migration.md` (to be created by this task)  
**Kapcsolódó goal YAML:** `codex/goals/canvases/fill_canvas_chat_feature_migration.yaml` (to be created by this task)  
**Futtás dátuma:** YYYY-MM-DD  
**Branch / commit:** tipmig session | openclaw workspace  
**Fókusz terület:** Migration | Feature Implementation

---

## 0) Kötelező kimeneti státusz

**IN_PROGRESS** — This stub will be finalized when `chat_feature_migration` task completes.

---

## 1) Meta

* **Task slug:** `chat_feature_migration`
* **Kapcsolódó canvas:** `canvases/tipsterino_first_migration_unit_scope_freeze.md`
* **Kapcsolódó goal YAML:** `codex/goals/canvases/fill_canvas_tipsterino_first_migration_unit_scope_freeze.yaml`
* **Futtás dátuma:** YYYY-MM-DD
* **Branch / commit:** tipmig session
* **Fókusz terület:** Migration | Feature Implementation

---

## 2) Scope

### 2.1 Cél

1:1 privát üzenetküldés (chat) migrálása TippmixApp-ből Tipsterino-ba:
- `messages` Supabase tábla migráció
- Domain/data/providers rétegek migrálása + Tipsterino adapter
- Chat screen Tipsterino-native implementáció
- HU/EN ARB kulcsok bővítése
- Widget teszt

### 2.2 Nem-cél

- Csoportos / club chat
- Push notifikációk
- Üzenet szerkesztés/törlés
- Firebase/Firestore kód
- Bottom-nav integráció (következő task)

---

## 3) Változások összefoglalója (Change summary)

*(To be filled by `chat_feature_migration` task)*

### Érintett fájlok

**DB Migration:**
- `supabase/migrations/<timestamp>_messages_table.sql`

**Domain:**
- `app/lib/src/features/chat/domain/chat_message.dart`
- `app/lib/src/features/chat/domain/chat_exception.dart`

**Data:**
- `app/lib/src/features/chat/data/chat_repository.dart`

**Providers:**
- `app/lib/src/features/chat/providers/chat_providers.dart`

**Presentation:**
- `app/lib/src/features/chat/presentation/screens/chat_screen.dart`

**Routing:**
- `app/lib/src/app/router/app_router.dart`

**L10n:**
- `app/lib/l10n/app_en.arb`
- `app/lib/l10n/app_hu.arb`

**Tests:**
- `app/test/widgets/chat_screen_test.dart`

---

## 4) Verifikáció

*(To be filled after CP9 — Repo gate)*

---

## 5) DoD → Evidence Matrix

*(To be filled after task completion)*

| DoD pont | Státusz | Bizonyíték (path + line) | Magyarázat | Kapcsolódó teszt/ellenőrzés |
| -------- | --------: | ------------------------ | ---------- | --------------------------- |
| CP1: DB migráció létrehozva | IN_PROGRESS | ... | ... | ... |
| CP2: Domain réteg migrálva | IN_PROGRESS | ... | ... | ... |
| CP3: Data réteg migrálva | IN_PROGRESS | ... | ... | ... |
| CP4: Provider réteg migrálva | IN_PROGRESS | ... | ... | ... |
| CP5: Chat screen létrehozva | IN_PROGRESS | ... | ... | ... |
| CP6: Route regisztrálva | IN_PROGRESS | ... | ... | ... |
| CP7: ARB kulcsok bővítve | IN_PROGRESS | ... | ... | ... |
| CP8: Widget teszt létrehozva | IN_PROGRESS | ... | ... | ... |
| CP9: Repo gate zöld | IN_PROGRESS | ... | ... | ... |
| CP10: Checklist kipipálva | IN_PROGRESS | ... | ... | ... |

---

## 6) Lokalizáció

*(To be filled after CP7)*

| key | hu | en | used_in |
|---|---|---|---|
| `chat_title` | ... | ... | `app/lib/src/features/chat/...` |
| ... | ... | ... | ... |

---

## 7) Advisory notes

*(Non-blocking observations — to be added during task)*

---

## 8) Follow-ups

- **Next task:** `friends_feature_migration` — 1:1 friend management feature
- **Rationale:** friends is the next most self-contained complete feature after chat
