import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import 'package:tipsterino/src/features/auth/presentation/state/auth_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/screens/auth_callback_screen.dart';
import 'package:tipsterino/src/features/auth/presentation/screens/login_screen.dart';
import 'package:tipsterino/src/features/auth/presentation/screens/verify_email_pending_screen.dart';
import 'package:tipsterino/src/features/auth/presentation/screens/sign_up_wizard_screen.dart';
import '../../screens/bets_screen.dart';
import '../../screens/forum_screen.dart';
import '../../screens/guest_info_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/settings_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(authRefreshNotifierProvider);

  const guestAllowlist = [
    '/home',
    '/bets',
    '/forum',
    '/guest-info',
    '/tickets',
    '/leaderboard',
  ];

  bool isGuestRoute(String path) {
    if (guestAllowlist.contains(path)) return true;
    return path.startsWith('/auth');
  }

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: refreshNotifier,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final currentPath = state.uri.path;

      if (authState.status == AuthStatus.unknown) {
        return null;
      }

      final isGuest =
          authState.status == AuthStatus.unauthenticated ||
          authState.status == AuthStatus.offline;
      if (isGuest && !isGuestRoute(currentPath)) {
        return '/auth/login';
      }

      if (authState.status == AuthStatus.authenticated) {
        if (currentPath == '/guest-info') {
          return '/home';
        }
        if (currentPath == '/auth/login' || currentPath == '/auth/register') {
          return '/home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/auth/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/auth/verify-pending',
        name: 'verifyPending',
        builder: (context, state) => VerifyEmailPendingScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
      GoRoute(
        path: '/auth/callback',
        name: 'authCallback',
        builder: (context, state) => AuthCallbackScreen(uri: state.uri),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const SignUpWizardScreen(),
      ),
      GoRoute(
        path: '/tickets',
        name: 'ticketsRedirect',
        redirect: (context, state) => '/bets',
      ),
      GoRoute(
        path: '/leaderboard',
        name: 'leaderboardRedirect',
        redirect: (context, state) => '/home',
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/bets',
            name: 'bets',
            builder: (context, state) => const BetsScreen(),
          ),
          GoRoute(
            path: '/forum',
            name: 'forum',
            builder: (context, state) => const ForumScreen(),
          ),
          GoRoute(
            path: '/guest-info',
            name: 'guestInfo',
            builder: (context, state) => const GuestInfoScreen(),
          ),
          GoRoute(
            path: '/profile',
            name: 'profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});
