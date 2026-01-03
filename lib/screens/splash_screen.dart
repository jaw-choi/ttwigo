import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../services/user_role_service.dart';
import '../services/provider_profile_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), () => _checkAuth());
  }

  Future<void> _checkAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final role = await UserRoleService.getRole();
      if (!mounted) return;
      if (role == UserRole.provider) {
        final hasProfile = await ProviderProfileService.hasProfile();
        if (!mounted) return;
        context.go(hasProfile ? '/provider-home' : '/provider-setup');
      } else if (role == UserRole.user) {
        context.go('/home');
      } else {
        context.go('/login');
      }
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Image(
          image: AssetImage('assets/mainImage.png'),
          width: 200,
          height: 200,
        ),
      ),
    );
  }
}
