import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import 'package:tipsterino/src/features/auth/presentation/state/auth_provider.dart';
import 'package:tipsterino/src/features/auth/presentation/screens/auth_callback_screen.dart';
import 'package:tipsterino/src/features/auth/presentation/screens/login_screen.dart';
import 'package:tipsterino/src/features/auth/presentation/screens/verify_email_pending_screen.dart';
import 'package:tipsterino/src/features/auth/presentation/screens/sign_up_wizard_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/leaderboard_screen.dart';
import '../../screens/settings_screen.dart';
import '../../screens/tickets_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = ref.watch(authRefreshNotifierProvider);

  return GoRouter(
    initialLocation: '/auth/login',
    refreshListenable: refreshNotifier,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final currentPath = state.uri.path;
      final isAuthRoute = currentPath.startsWith('/auth');

      if (authState.status == AuthStatus.unknown) {
        return null;
      }

      if (authState.status == AuthStatus.offline && !isAuthRoute) {
        return '/auth/login';
      }

      final isLoggedIn = authState.status == AuthStatus.authenticated;
      if (!isLoggedIn && !isAuthRoute) {
        return '/auth/login';
      }

      if (isLoggedIn && isAuthRoute) {
        return '/home';
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
        builder: (context, state) =>
            AuthCallbackScreen(error: state.uri.queryParameters['error']),
      ),
      GoRoute(
        path: '/auth/register',
        name: 'register',
        builder: (context, state) => const SignUpWizardScreen(),
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
            path: '/tickets',
            name: 'tickets',
            builder: (context, state) => const TicketsScreen(),
          ),
          GoRoute(
            path: '/leaderboard',
            name: 'leaderboard',
            builder: (context, state) => const LeaderboardScreen(),
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
