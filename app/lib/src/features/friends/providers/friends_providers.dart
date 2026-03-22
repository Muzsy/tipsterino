import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tipsterino/src/core/clients/supabase_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/state/auth_provider.dart';

import '../data/friends_repository.dart';
import '../domain/friend_search_result.dart';
import '../domain/friendship.dart';

/// Provides the [FriendsRepository] using Tipsterino's [supabaseConfigProvider].
///
/// Do NOT use the global `Supabase.instance.client` singleton.
final friendsRepositoryProvider = Provider<FriendsRepository>((ref) {
  final config = ref.watch(supabaseConfigProvider);
  return FriendsRepository(config);
});

/// Stream of accepted [Friendship] list for the current authenticated user.
///
/// The stream is empty if the current user is not authenticated.
/// Uses `autoDispose` so the subscription is cleaned up when the screen
/// is disposed.
final acceptedFriendsProvider =
    StreamProvider.autoDispose<List<Friendship>>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final currentUserId = authState.session?.user.id;

  if (currentUserId == null || currentUserId.isEmpty) {
    return Stream.value(const <Friendship>[]);
  }

  final repository = ref.watch(friendsRepositoryProvider);
  return repository.watchAcceptedFriends(currentUserId);
});

/// Stream of incoming pending friend [Friendship] requests.
///
/// Only records where the current user is the ADDRESSEE (isRequester == false).
/// Uses `autoDispose`.
final incomingFriendRequestsProvider =
    StreamProvider.autoDispose<List<Friendship>>((ref) {
  final authState = ref.watch(authNotifierProvider);
  final currentUserId = authState.session?.user.id;

  if (currentUserId == null || currentUserId.isEmpty) {
    return Stream.value(const <Friendship>[]);
  }

  final repository = ref.watch(friendsRepositoryProvider);
  return repository.watchPendingRequests(currentUserId);
});

/// Current search query for the friends search field.
final friendSearchQueryProvider = StateProvider.autoDispose<String>(
  (ref) => '',
);

/// Search results for the current [friendSearchQueryProvider] value.
///
/// Returns [FriendSearchResult] list. Excludes already-accepted friends.
/// Uses `autoDispose` so results are cleared when leaving the screen.
final friendSearchResultsProvider =
    FutureProvider.autoDispose<List<FriendSearchResult>>((ref) async {
  final query = ref.watch(friendSearchQueryProvider);
  final authState = ref.watch(authNotifierProvider);
  final currentUserId = authState.session?.user.id;

  if (currentUserId == null || currentUserId.isEmpty) {
    return const [];
  }

  final repository = ref.watch(friendsRepositoryProvider);
  return repository.searchProfiles(query, currentUserId);
});
