import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'package:tipsterino/src/core/clients/supabase_provider.dart';

import '../domain/friend_operation_exception.dart';
import '../domain/friendship.dart';

/// Friends feature repository backed by Supabase.
///
/// Uses the `friends` table with realtime subscriptions to deliver
/// live friend lists and incoming requests.
///
/// NO notification service integration. NO AppError/AppErrorMapper.
class FriendsRepository {
  FriendsRepository(this._config);

  final SupabaseConfiguration _config;

  /// Watches accepted friends for [currentUserId].
  ///
  /// Returns a stream that emits the full accepted-friends list ordered
  /// by `created_at` descending (most recent first).
  Stream<List<Friendship>> watchAcceptedFriends(String currentUserId) {
    return _watchFriendships(
      currentUserId,
      allowedStatuses: const {FriendStatus.accepted},
    );
  }

  /// Watches incoming pending friend requests for [currentUserId].
  ///
  /// Only returns records where the current user is the ADDRESSEE
  /// (isRequester == false), i.e. someone sent them a request.
  Stream<List<Friendship>> watchPendingRequests(String currentUserId) {
    return _watchFriendships(
      currentUserId,
      allowedStatuses: const {FriendStatus.pending},
    );
  }

  Stream<List<Friendship>> _watchFriendships(
    String userId, {
    Set<FriendStatus>? allowedStatuses,
  }) {
    if (userId.isEmpty) {
      return Stream.value(const <Friendship>[]);
    }

    final client = _config.client;
    if (client == null) {
      return Stream.value(const <Friendship>[]);
    }

    final controller = StreamController<List<Friendship>>.broadcast();
    StreamSubscription<List<Map<String, dynamic>>>? userSub;
    StreamSubscription<List<Map<String, dynamic>>>? friendSub;
    var isActive = false;

    Future<void> emitLatest() async {
      try {
        final data = await _fetchFriendships(
          userId,
          allowedStatuses: allowedStatuses,
        );
        if (!controller.isClosed) {
          controller.add(data);
        }
      } catch (error, stackTrace) {
        if (!controller.isClosed) {
          controller.addError(error, stackTrace);
        }
      }
    }

    controller
      ..onListen = () {
        if (isActive) return;
        isActive = true;
        unawaited(emitLatest());

        final userQuery = client
            .from('friends')
            .stream(primaryKey: const ['user_id', 'friend_id'])
            .eq('user_id', userId);

        final friendQuery = client
            .from('friends')
            .stream(primaryKey: const ['user_id', 'friend_id'])
            .eq('friend_id', userId);

        userSub = userQuery.listen(
          (_) => unawaited(emitLatest()),
          onError: (error, stackTrace) {
            if (!controller.isClosed) {
              controller.addError(error, stackTrace);
            }
          },
        );

        friendSub = friendQuery.listen(
          (_) => unawaited(emitLatest()),
          onError: (error, stackTrace) {
            if (!controller.isClosed) {
              controller.addError(error, stackTrace);
            }
          },
        );
      }
      ..onCancel = () async {
        if (controller.hasListener) return;
        await userSub?.cancel();
        userSub = null;
        await friendSub?.cancel();
        friendSub = null;
        isActive = false;
      };

    return controller.stream;
  }

  Future<List<Friendship>> _fetchFriendships(
    String userId, {
    Set<FriendStatus>? allowedStatuses,
  }) async {
    final client = _config.client;
    if (client == null) return const [];

    final statusFilter = allowedStatuses
        ?.map((s) => s.value)
        .toList();

    var query = client.from('friends').select(
          'user_id, friend_id, status, created_at',
        ).or('user_id.eq.$userId,friend_id.eq.$userId');

    if (statusFilter != null && statusFilter.isNotEmpty) {
      final statusLiteral = statusFilter.map((s) => '"$s"').join(',');
      query = query.filter('status', 'in', '($statusLiteral)');
    }

    final response = await query.order('created_at', ascending: false);
    final rows = (response as List).cast<Map<String, dynamic>>();

    // Collect all profile IDs referenced in the friendship rows.
    final profileIds = <String>{};
    for (final row in rows) {
      final ownerId = row['user_id'] as String? ?? '';
      final targetId = row['friend_id'] as String? ?? '';
      if (ownerId.isNotEmpty) profileIds.add(ownerId);
      if (targetId.isNotEmpty) profileIds.add(targetId);
    }

    // Batch-fetch profiles from public_profiles view.
    final profileMap = await _fetchProfiles(client, profileIds);

    final list = <Friendship>[];
    for (final row in rows) {
      final friendship = Friendship.fromMap(row, userId, profileMap);
      if (friendship.profile.id.isEmpty) continue;
      list.add(friendship);
    }
    return list;
  }

  Future<Map<String, FriendProfile>> _fetchProfiles(
    sb.SupabaseClient client,
    Set<String> ids,
  ) async {
    if (ids.isEmpty) return {};

    final idsLiteral = ids.map((e) => '"$e"').join(',');
    final profileResponse = await client
        .from('public_profiles')
        .select('id, nickname, avatar_key')
        .filter('id', 'in', '($idsLiteral)');

    final profileRows =
        (profileResponse as List).cast<Map<String, dynamic>>();
    final profileMap = <String, FriendProfile>{};
    for (final row in profileRows) {
      final profile = FriendProfile.fromMap(row);
      if (profile.id.isNotEmpty) {
        profileMap[profile.id] = profile;
      }
    }
    return profileMap;
  }

  /// Searches public profiles by nickname (case-insensitive) excluding
  /// the current user.
  ///
  /// Returns up to 20 results with their current friendship status relative
  /// to [currentUserId].
  Future<List<FriendSearchResult>> searchProfiles(
    String query,
    String currentUserId,
  ) async {
    final sanitized = query.trim();
    if (sanitized.length < 2) return const [];

    final client = _config.client;
    if (client == null) return const [];

    final normalized = sanitized.replaceAll(RegExp(r'\s+'), ' ');

    // Search public_profiles by nickname (ilike).
    final rows = await client
        .from('public_profiles')
        .select('id, nickname, avatar_key')
        .ilike('nickname', '%$normalized%')
        .neq('id', currentUserId)
        .limit(20);

    final profiles = (rows as List)
        .cast<Map<String, dynamic>>()
        .map(FriendProfile.fromMap)
        .where((p) => p.id.isNotEmpty)
        .toList();

    if (profiles.isEmpty) return const [];

    // Fetch existing relationships for the result profiles.
    final ids = profiles.map((p) => p.id).toList();
    final idsLiteral = ids.map((e) => '"$e"').join(',');

    final outgoing = await client
        .from('friends')
        .select('friend_id, status')
        .eq('user_id', currentUserId)
        .filter('friend_id', 'in', '($idsLiteral)');

    final incoming = await client
        .from('friends')
        .select('user_id, status')
        .eq('friend_id', currentUserId)
        .filter('user_id', 'in', '($idsLiteral)');

    final statusMap = <String, ({FriendStatus status, bool isRequester})>{};

    for (final row in (outgoing as List).cast<Map<String, dynamic>>()) {
      final friendId = row['friend_id'] as String?;
      if (friendId == null) continue;
      statusMap[friendId] = (
        status: FriendStatus.fromString(row['status'] as String?),
        isRequester: true,
      );
    }

    for (final row in (incoming as List).cast<Map<String, dynamic>>()) {
      final ownerId = row['user_id'] as String?;
      if (ownerId == null) continue;
      statusMap[ownerId] = (
        status: FriendStatus.fromString(row['status'] as String?),
        isRequester: false,
      );
    }

    final results = <FriendSearchResult>[];
    for (final profile in profiles) {
      final rel = statusMap[profile.id];
      // Skip already-accepted friends from search results.
      if (rel != null && rel.status == FriendStatus.accepted) continue;
      results.add(
        FriendSearchResult(
          profile: profile,
          status: rel?.status,
          isRequester: rel?.isRequester ?? false,
        ),
      );
    }
    return results;
  }

  /// Sends a friend request from [currentUserId] to [targetUserId].
  ///
  /// Throws [FriendOperationException] on validation failure or conflict.
  Future<void> sendFriendRequest({
    required String currentUserId,
    required String targetUserId,
  }) async {
    if (currentUserId.isEmpty || targetUserId.isEmpty) {
      throw const FriendOperationException('self_friendship');
    }
    if (currentUserId == targetUserId) {
      throw const FriendOperationException('self_friendship');
    }

    final client = _config.client;
    if (client == null) {
      throw const FriendOperationException('operation_failed');
    }

    // Check for existing relationships in either direction.
    final existing = await client.from('friends').select(
          'user_id, friend_id, status',
        ).or(
          'and(user_id.eq.$currentUserId,friend_id.eq.$targetUserId),and(user_id.eq.$targetUserId,friend_id.eq.$currentUserId)',
        );

    final existingRows = (existing as List).cast<Map<String, dynamic>>();

    for (final row in existingRows) {
      final owner = row['user_id'] as String? ?? '';
      final status = FriendStatus.fromString(row['status'] as String?);

      if (status == FriendStatus.accepted) {
        throw const FriendOperationException('already_friends');
      }
      if (owner == currentUserId && status == FriendStatus.pending) {
        throw const FriendOperationException('request_exists');
      }
      if (owner == targetUserId && status == FriendStatus.pending) {
        throw const FriendOperationException('incoming_exists');
      }

      // If there is a rejected record from the other direction, delete it first.
      if (owner == targetUserId && status == FriendStatus.rejected) {
        await client
            .from('friends')
            .delete()
            .eq('user_id', targetUserId)
            .eq('friend_id', currentUserId);
      }
    }

    try {
      await client.from('friends').insert({
        'user_id': currentUserId,
        'friend_id': targetUserId,
        'status': FriendStatus.pending.value,
      });
    } on sb.PostgrestException catch (error) {
      if (error.code == '23505') {
        throw const FriendOperationException('already_friends');
      }
      throw const FriendOperationException('operation_failed');
    } catch (_) {
      throw const FriendOperationException('operation_failed');
    }
  }

  /// Responds to a friend request.
  ///
  /// [currentUserId] is the addressee. [requesterId] is the original sender.
  /// Set [accept] to true to accept, false to reject.
  Future<void> respondToFriendRequest({
    required String currentUserId,
    required String requesterId,
    required bool accept,
  }) async {
    if (currentUserId.isEmpty || requesterId.isEmpty) {
      throw const FriendOperationException('request_missing');
    }

    final client = _config.client;
    if (client == null) {
      throw const FriendOperationException('operation_failed');
    }

    final existing = await client
        .from('friends')
        .select('status')
        .eq('user_id', requesterId)
        .eq('friend_id', currentUserId)
        .maybeSingle();

    if (existing == null) {
      throw const FriendOperationException('request_missing');
    }

    final status = FriendStatus.fromString(existing['status'] as String?);
    if (status != FriendStatus.pending) {
      throw const FriendOperationException('not_pending');
    }

    try {
      await client
          .from('friends')
          .update({
            'status': accept
                ? FriendStatus.accepted.value
                : FriendStatus.rejected.value,
          })
          .eq('user_id', requesterId)
          .eq('friend_id', currentUserId);
    } catch (_) {
      throw const FriendOperationException('operation_failed');
    }
  }

  /// Removes a friendship in either direction between [currentUserId] and
  /// [friendUserId].
  Future<void> removeFriendship({
    required String currentUserId,
    required String friendUserId,
  }) async {
    if (currentUserId.isEmpty || friendUserId.isEmpty) {
      throw const FriendOperationException('friendship_not_found');
    }

    final client = _config.client;
    if (client == null) {
      throw const FriendOperationException('operation_failed');
    }

    try {
      final result = await client
          .from('friends')
          .delete()
          .or(
            'and(user_id.eq.$currentUserId,friend_id.eq.$friendUserId),and(user_id.eq.$friendUserId,friend_id.eq.$currentUserId)',
          )
          .select('user_id')
          .maybeSingle();

      if (result == null) {
        throw const FriendOperationException('friendship_not_found');
      }
    } on sb.PostgrestException catch (error) {
      if (error.code == '23505') {
        throw const FriendOperationException('already_friends');
      }
      throw const FriendOperationException('operation_failed');
    } catch (_) {
      throw const FriendOperationException('operation_failed');
    }
  }
}
