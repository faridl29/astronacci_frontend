import 'package:astronacci/blocs/auth/auth_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'blocs/auth/auth_bloc.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/user/user_list_screen.dart';
import 'screens/user/user_detail_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'screens/splash_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final authState = context.read<AuthBloc>().state;
      final isAuthenticated = authState.status == AuthStatus.authenticated;
      final isLoading = authState.status == AuthStatus.unknown;

      // Show splash while loading
      if (isLoading && state.uri.toString() == '/splash') {
        return null;
      }

      // Redirect to login if not authenticated
      if (!isAuthenticated && !_isAuthRoute(state.uri.toString())) {
        return '/login';
      }

      // Redirect to home if authenticated and on auth route
      if (isAuthenticated && _isAuthRoute(state.uri.toString())) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const UserListScreen(),
      ),
      GoRoute(
        path: '/user/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return UserDetailScreen(userId: id);
        },
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
    ],
  );

  static bool _isAuthRoute(String location) {
    return ['/login', '/register', '/forgot-password', '/splash']
        .contains(location);
  }
}
