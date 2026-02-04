# Bonus system – Events: core feature (domain + repository + provider)

**TASK_SLUG:** `bonus_system_events_core_feature`

---

## 🎯 Funkció

Készüljön el az **Events (user_events)** feature technikai alapja **UI és routing nélkül**:

- `UserEvent` domain modell
- `UserEventsRepository` Supabase query/update réteg
- Riverpod StateNotifier provider az eseménylista állapotkezeléséhez, **offline / not_configured** támogatással

### Nem cél

- `/events` képernyő
- routing + Settings belépési pont
- lokalizációs kulcsok
- widget teszt (külön task)

---

## 🧠 Fejlesztési részletek

### Forrás-igazság

- `docs/data_model/user_events_table_doc.md`
- `app/lib/src/core/clients/supabase_provider.dart` (jelenleg default: isConfigured=false)
- mintastílus: `app/lib/src/features/rewards/application/post_auth_init_provider.dart`

### Új feature mappák

Hozd létre / használd:

- `app/lib/src/features/events/domain/`
- `app/lib/src/features/events/data/`
- `app/lib/src/features/events/application/`

### Domain modell – `UserEvent`

Mezők:

- `id`, `type`, `code`, `amount`, `payload`, `createdAt`, `readAt`

Követelmények:

- `factory UserEvent.fromMap(Map<String, dynamic> map)`
  - mezőnevek Supabase-ből: `created_at`, `read_at`
  - dátum parse: `DateTime.parse(...)`
- `bool get isUnread => readAt == null`

### Repository – `UserEventsRepository`

Követelmények:

- `fetchPage({required int offset, required int limit})`
  - order: `created_at desc`
  - paging: `range(offset, offset + limit - 1)`
- `markRead({required String id})`
  - kizárólag `read_at` update: `update({'read_at': nowIso}).eq('id', id)`

### Provider / Notifier

- `userEventsRepositoryProvider`: ha nincs konfigurált Supabase → `null`, különben repo példány
- `userEventsProvider`: StateNotifier + state

State minimum mezők:

- `items: List<UserEvent>`
- `isNotConfigured: bool`
- `isLoading: bool`
- `isLoadingMore: bool`
- `hasMore: bool`
- `errorMessage: String?`

Metódusok minimum:

- `loadInitial()`, `refresh()`, `loadMore()`, `markRead(UserEvent event)`

---

## 🧪 Tesztállapot

Ebben a taskban nem kötelező új teszt (külön task fogja).

---

## 🌍 Lokalizáció

Nincs új UI szöveg.

---

## 📎 Kapcsolódások

Új / érintett fájlok:

- `app/lib/src/features/events/domain/user_event.dart`
- `app/lib/src/features/events/data/user_events_repository.dart`
- `app/lib/src/features/events/application/user_events_provider.dart`
