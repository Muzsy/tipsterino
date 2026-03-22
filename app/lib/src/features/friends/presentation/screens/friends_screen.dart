import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tipsterino/l10n/app_localizations.dart';
import 'package:tipsterino/src/features/auth/presentation/state/auth_provider.dart';
import 'package:tipsterino/src/features/friends/domain/friend_operation_exception.dart';
import 'package:tipsterino/src/features/friends/domain/friend_search_result.dart';
import 'package:tipsterino/src/features/friends/domain/friend_status.dart';
import 'package:tipsterino/src/features/friends/domain/friendship.dart';
import 'package:tipsterino/src/features/friends/providers/friends_providers.dart';
import 'package:tipsterino/src/features/friends/presentation/widgets/friend_list_item.dart';
import 'package:tipsterino/src/features/friends/presentation/widgets/friend_request_item.dart';
import 'package:tipsterino/src/features/friends/presentation/widgets/friend_search_result_item.dart';

/// Friends management screen.
///
/// Auth-gated. Accessible at `/friends`.
/// Provides: accepted friends list, incoming pending requests,
/// nickname search, send/accept/decline/remove friendship flows,
/// deep-link to `/chat/:friendId`.
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  // In-flight operation tracking.
  final Set<String> _pendingRequests = {};
  final Set<String> _acceptingRequests = {};
  final Set<String> _decliningRequests = {};
  final Set<String> _removingFriends = {};

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  // ─── Search ───────────────────────────────────────────────────────────────

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      ref.read(friendSearchQueryProvider.notifier).state = value;
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    ref.read(friendSearchQueryProvider.notifier).state = '';
  }

  // ─── Request actions ──────────────────────────────────────────────────────

  Future<void> _handleSendRequest(FriendSearchResult result) async {
    final authState = ref.read(authNotifierProvider);
    final currentUid = authState.session?.user.id;
    final loc = AppLocalizations.of(context)!;

    if (currentUid == null) {
      _showSnackBar(loc.unknown_error_try_again);
      return;
    }

    setState(() => _pendingRequests.add(result.profile.id));

    try {
      await ref.read(friendsRepositoryProvider).sendFriendRequest(
            currentUserId: currentUid,
            targetUserId: result.profile.id,
          );
      if (!mounted) return;
      _showSnackBar(loc.friends_request_sent);
      ref.invalidate(friendSearchResultsProvider);
    } on FriendOperationException catch (e) {
      if (!mounted) return;
      _showSnackBar(_localizeError(e, loc));
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(loc.friends_request_error);
    } finally {
      if (mounted) {
        setState(() => _pendingRequests.remove(result.profile.id));
      }
    }
  }

  Future<void> _handleRespondToRequest(
    Friendship friendship, {
    required bool accept,
  }) async {
    final authState = ref.read(authNotifierProvider);
    final currentUid = authState.session?.user.id;
    final loc = AppLocalizations.of(context)!;

    if (currentUid == null) {
      _showSnackBar(loc.unknown_error_try_again);
      return;
    }

    final profileId = friendship.profile.id;
    setState(() {
      if (accept) {
        _acceptingRequests.add(profileId);
      } else {
        _decliningRequests.add(profileId);
      }
    });

    try {
      final requesterId = friendship.isRequester
          ? friendship.friendId
          : friendship.userId;
      await ref.read(friendsRepositoryProvider).respondToFriendRequest(
            currentUserId: currentUid,
            requesterId: requesterId,
            accept: accept,
          );
      if (!mounted) return;
      _showSnackBar(
        accept ? loc.friends_accept_success : loc.friends_decline_success,
      );
      ref.invalidate(acceptedFriendsProvider);
      ref.invalidate(incomingFriendRequestsProvider);
      ref.invalidate(friendSearchResultsProvider);
    } on FriendOperationException catch (e) {
      if (!mounted) return;
      _showSnackBar(_localizeError(e, loc));
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(loc.friends_request_error);
    } finally {
      if (mounted) {
        setState(() {
          _acceptingRequests.remove(profileId);
          _decliningRequests.remove(profileId);
        });
      }
    }
  }

  // ─── Remove friendship ─────────────────────────────────────────────────────

  Future<void> _confirmAndRemoveFriend({
    required String friendId,
    required String nickname,
  }) async {
    final authState = ref.read(authNotifierProvider);
    final currentUid = authState.session?.user.id;
    final loc = AppLocalizations.of(context)!;

    if (currentUid == null) {
      _showSnackBar(loc.unknown_error_try_again);
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.friends_remove_confirm_title),
        content: Text(loc.friends_remove_confirm_message(nickname)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(loc.friends_remove_confirm_no),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(loc.friends_remove_confirm_yes),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _removingFriends.add(friendId));

    try {
      await ref.read(friendsRepositoryProvider).removeFriendship(
            currentUserId: currentUid,
            friendUserId: friendId,
          );
      if (!mounted) return;
      _showSnackBar(loc.friends_remove_success);
      ref.invalidate(acceptedFriendsProvider);
      ref.invalidate(friendSearchResultsProvider);
    } on FriendOperationException catch (e) {
      if (!mounted) return;
      _showSnackBar(_localizeError(e, loc));
    } catch (_) {
      if (!mounted) return;
      _showSnackBar(loc.friends_remove_error);
    } finally {
      if (mounted) {
        setState(() => _removingFriends.remove(friendId));
      }
    }
  }

  // ─── Navigation ───────────────────────────────────────────────────────────

  void _openChat(String friendId) {
    context.pushNamed(
      'chat',
      pathParameters: {'friendId': friendId},
    );
  }

  // ─── UI helpers ────────────────────────────────────────────────────────────

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _localizeError(FriendOperationException e, AppLocalizations loc) {
    switch (e.code) {
      case 'self_friendship':
        return loc.friends_error_self;
      case 'already_friends':
        return loc.friends_error_already_friends;
      case 'request_exists':
        return loc.friends_error_request_exists;
      case 'incoming_exists':
        return loc.friends_error_incoming_exists;
      case 'request_missing':
        return loc.friends_error_request_missing;
      case 'not_pending':
        return loc.friends_error_not_pending;
      case 'friendship_not_found':
        return loc.friends_error_not_found;
      default:
        return loc.friends_error_generic;
    }
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final friendsAsync = ref.watch(acceptedFriendsProvider);
    final requestsAsync = ref.watch(incomingFriendRequestsProvider);
    final searchResultsAsync = ref.watch(friendSearchResultsProvider);
    final query = ref.watch(friendSearchQueryProvider).trim();
    final hasQuery = query.length >= 2;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.friends_title),
        centerTitle: true,
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Search field
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    labelText: loc.friends_search_placeholder,
                    suffixIcon: query.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            tooltip: loc.friends_search_clear,
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
            ),

            // Search results (when query is active)
            if (hasQuery)
              ...searchResultsAsync.when(
                data: (results) =>
                    _buildSearchResultsSliver(context, loc, results),
                loading: () => [
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  ),
                ],
                error: (error, _) => _errorSliver(
                  loc,
                  () => ref.invalidate(friendSearchResultsProvider),
                ),
              ),

            // Incoming requests section
            ...requestsAsync.when(
              data: (requests) =>
                  _buildIncomingRequestsSliver(context, loc, requests),
              loading: () => [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              ],
              error: (error, _) => _errorSliver(
                loc,
                () => ref.invalidate(incomingFriendRequestsProvider),
              ),
            ),

            // Accepted friends section header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  loc.friends_section_friends,
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ),

            // Accepted friends list
            ...friendsAsync.when(
              data: (friends) {
                if (friends.isEmpty) {
                  return [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: _EmptyState(
                          icon: Icons.group_outlined,
                          iconColor: colorScheme.primary,
                          message: loc.friends_empty_state,
                        ),
                      ),
                    ),
                  ];
                }
                return [
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList.builder(
                      itemCount: friends.length,
                      itemBuilder: (context, index) {
                        final friend = friends[index];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == friends.length - 1 ? 0 : 8,
                          ),
                          child: FriendListItem(
                            friendship: friend,
                            isRemovalInProgress: _removingFriends
                                .contains(friend.otherUserId),
                            onMessage: () => _openChat(friend.otherUserId),
                            onRemove: () => _confirmAndRemoveFriend(
                              friendId: friend.otherUserId,
                              nickname: friend.profile.nickname,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ];
              },
              loading: () => [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                ),
              ],
              error: (error, _) =>
                  _errorSliver(loc, () => ref.invalidate(acceptedFriendsProvider)),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildIncomingRequestsSliver(
    BuildContext context,
    AppLocalizations loc,
    List<Friendship> requests,
  ) {
    // Only show incoming (not outgoing) pending requests.
    final incoming =
        requests.where((friendship) => !friendship.isRequester).toList();

    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            incoming.isNotEmpty
                ? '${loc.friends_requests_title} (${incoming.length})'
                : loc.friends_requests_title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
      if (incoming.isEmpty)
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _EmptyState(
              icon: Icons.inbox_outlined,
              iconColor: Theme.of(context).colorScheme.secondary,
              message: loc.friends_requests_empty,
            ),
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          sliver: SliverList.builder(
            itemCount: incoming.length,
            itemBuilder: (context, index) {
              final request = incoming[index];
              final profileId = request.profile.id;
              return Padding(
                padding: EdgeInsets.only(
                  bottom: index == incoming.length - 1 ? 0 : 8,
                ),
                child: FriendRequestItem(
                  friendship: request,
                  isAccepting: _acceptingRequests.contains(profileId),
                  isDeclining: _decliningRequests.contains(profileId),
                  onAccept: () =>
                      _handleRespondToRequest(request, accept: true),
                  onDecline: () =>
                      _handleRespondToRequest(request, accept: false),
                ),
              );
            },
          ),
        ),
    ];
  }

  List<Widget> _buildSearchResultsSliver(
    BuildContext context,
    AppLocalizations loc,
    List<FriendSearchResult> results,
  ) {
    if (results.isEmpty) {
      return [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _EmptyState(
              icon: Icons.search_off,
              iconColor: Theme.of(context).colorScheme.tertiary,
              message: loc.friends_search_no_results,
            ),
          ),
        ),
      ];
    }

    return [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        sliver: SliverList.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final result = results[index];
            return Padding(
              padding: EdgeInsets.only(
                bottom: index == results.length - 1 ? 0 : 8,
              ),
              child: FriendSearchResultItem(
                result: result,
                isProcessing: _pendingRequests.contains(result.profile.id),
                isRemoveInProgress:
                    _removingFriends.contains(result.profile.id),
                onSendRequest: () => _handleSendRequest(result),
                onOpenChat: result.isFriend
                    ? () => _openChat(result.profile.id)
                    : null,
                onRemoveFriend: result.isFriend
                    ? () => _confirmAndRemoveFriend(
                          friendId: result.profile.id,
                          nickname: result.profile.nickname,
                        )
                    : null,
              ),
            );
          },
        ),
      ),
    ];
  }

  List<Widget> _errorSliver(
    AppLocalizations loc,
    VoidCallback onRetry,
  ) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Center(
            child: Column(
              children: [
                Text(
                  loc.friends_error_generic,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: onRetry,
                  child: Text(loc.events_screen_refresh),
                ),
              ],
            ),
          ),
        ),
      ),
    ];
  }
}

/// Simple empty state widget used across sections.
class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.iconColor,
    required this.message,
  });

  final IconData icon;
  final Color iconColor;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: iconColor),
          const SizedBox(height: 12),
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
