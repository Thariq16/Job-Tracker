import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/tracker/job_tracker_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/splash/splash_screen.dart';
import 'features/auth/auth_repository.dart';
import 'features/jobs/job_detail_screen.dart';
import 'features/profile/profile_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/notifications/notifications_screen.dart';
import 'features/upcoming/upcoming_features_screen.dart';
import 'features/subscription/subscription_screen.dart';
import 'features/linkedin_setup/linkedin_setup_screen.dart';
import 'features/target_companies/target_companies_screen.dart';
import 'features/daily_engagement/daily_engagement_screen.dart';
import 'features/admin/admin_screen.dart';
import 'features/referral/referral_screen.dart';
import 'core/analytics_service.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ValueNotifier<AsyncValue<User?>>(const AsyncValue.loading());
  final analytics = ref.read(analyticsProvider);

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
    observers: [analytics.observer],
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
        path: '/tracker',
        builder: (context, state) => const JobTrackerScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/upcoming',
        builder: (context, state) => const UpcomingFeaturesScreen(),
      ),
      GoRoute(
        path: '/job/:id',
        builder: (context, state) => JobDetailScreen(jobId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/linkedin-setup',
        builder: (context, state) => const LinkedInSetupScreen(),
      ),
      GoRoute(
        path: '/linkedin-checklist',
        builder: (context, state) => const LinkedInSetupScreen(),
      ),
      GoRoute(
        path: '/target-companies',
        builder: (context, state) => const TargetCompaniesScreen(),
      ),
      GoRoute(
        path: '/daily-engagement',
        builder: (context, state) => const DailyEngagementScreen(),
      ),
      GoRoute(
        path: '/admin',
        builder: (context, state) => const AdminScreen(),
      ),
      GoRoute(
        path: '/referral',
        builder: (context, state) => const ReferralScreen(),
      ),
    ],
    redirect: (context, state) {
      final value = authState.value;
      
      final isLoading = value.isLoading;
      final hasError = value.hasError;
      final isLoggedIn = value.value != null;
      
      final isSplash = state.uri.toString() == '/';
      final isLogin = state.uri.toString() == '/login';

      if (isLoading || hasError) return null;

      if (isSplash) {
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
