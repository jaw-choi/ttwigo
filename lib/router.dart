import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/provider_home_screen.dart';
import 'screens/provider_profile_setup_screen.dart';

final GoRouter router = GoRouter(
  initialLocation: '/splash',
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
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/provider-home',
      builder: (context, state) => const ProviderHomeScreen(),
    ),
    GoRoute(
      path: '/provider-setup',
      builder: (context, state) => const ProviderProfileSetupScreen(),
    ),
  ],
);
