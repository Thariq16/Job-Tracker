import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import User type
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/auth_repository.dart';
import 'features/jobs/job_detail_screen.dart';
import 'features/profile/profile_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ValueNotifier<AsyncValue<User?>>(const AsyncValue.loading());

  ref.listen<AsyncValue<User?>>(
    authStateChangesProvider,
    (_, next) {
      authState.value = next;
    },
    fireImmediately: true,
  );
  
  return GoRouter(
    initialLocation: '/',
    refreshListenable: authState,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/job/:id',
        builder: (context, state) => JobDetailScreen(jobId: state.pathParameters['id']!),
      ),
    ],
    redirect: (context, state) {
      final value = authState.value;
      
      final isLoading = value.isLoading;
      final hasError = value.hasError;
      final isLoggedIn = value.valueOrNull != null;
      
      final isSplash = state.uri.toString() == '/';
      final isLogin = state.uri.toString() == '/login';

      if (isLoading || hasError) return null; // Wait for stream to emit data

      if (isSplash) {
        // Splash screen handles its own timing & checks. 
        // We do NOT want to interrupt it unless we want to enforce redirect immediately.
        // But for this MVP, let's allow Splash to finish.
        return null; 
      }

      if (isLoggedIn) {
        if (isLogin) return '/dashboard';
      } else {
        if (!isLogin) return '/login';
      }

      return null;
    },
  );
});
