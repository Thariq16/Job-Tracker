import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../auth/auth_repository.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 2)); // Minimum Splash Duration
    // Auth state is listened to by the Router usually, but for Splash logic:
    final user = ref.read(authRepositoryProvider).currentUser;
    if (mounted) {
       if (user != null) {
         context.go('/dashboard');
       } else {
         context.go('/login');
       }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(Icons.rocket_launch, size: 100, color: Theme.of(context).primaryColor),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
