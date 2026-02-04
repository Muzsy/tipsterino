import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/user_event.dart';

class UserEventsRepository {
  const UserEventsRepository(this._client);

  final SupabaseClient _client;

  Future<List<UserEvent>> fetchPage({
    required int offset,
    required int limit,
  }) async {
    final response = await _client
        .from('user_events')
        .select('*')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);

    final records = response as List;

    return records.map((raw) {
      final record = _castToMap(raw);
      return UserEvent.fromMap(record);
    }).toList();
  }

  Future<void> markRead({required String id}) async {
    final nowIso = DateTime.now().toUtc().toIso8601String();
    await _client
        .from('user_events')
        .update({'read_at': nowIso})
        .eq('id', id);
  }

  static Map<String, dynamic> _castToMap(Object raw) {
    if (raw is Map<String, dynamic>) {
      return raw;
    }
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    throw StateError('Unexpected user_events record: $raw');
  }
}
