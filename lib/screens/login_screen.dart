import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/user_role_service.dart';
import '../services/provider_profile_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final AuthService _authService = AuthService();
  String _error = '';
  UserRole _role = UserRole.user;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final savedRole = await UserRoleService.getRole();
    if (savedRole != null && mounted) {
      setState(() => _role = savedRole);
    }
  }

  Future<void> _handlePostSignIn() async {
    await UserRoleService.setRole(_role);
    if (!mounted) return;
    if (_role == UserRole.provider) {
      final hasProfile = await ProviderProfileService.hasProfile();
      if (!mounted) return;
      context.go(hasProfile ? '/provider-home' : '/provider-setup');
    } else {
      context.go('/home');
    }
  }

  Future<void> _signInEmail() async {
    try {
      await _authService.signInWithEmail(_email.text, _password.text);
      await _handlePostSignIn();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _registerEmail() async {
    try {
      await _authService.registerWithEmail(_email.text, _password.text);
      await _handlePostSignIn();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _signInAnon() async {
    try {
      await _authService.signInAnonymously();
      await _handlePostSignIn();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _signInGoogle() async {
    try {
      final user = await _authService.signInWithGoogle();
      if (user == null) return;
      await _handlePostSignIn();
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ToggleButtons(
              isSelected: [
                _role == UserRole.user,
                _role == UserRole.provider,
              ],
              onPressed: (index) {
                setState(() {
                  _role = index == 0 ? UserRole.user : UserRole.provider;
                });
              },
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text("Login as User"),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text("Login as Provider"),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(controller: _email, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: _password, decoration: const InputDecoration(labelText: "Password"), obscureText: true),
            if (_error.isNotEmpty) Text(_error, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(onPressed: _signInEmail, child: const Text("Login")),
                ElevatedButton(onPressed: _registerEmail, child: const Text("Register")),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _signInAnon,
              child: Text(
                _role == UserRole.provider
                    ? "Continue as Guest (Provider)"
                    : "Continue as Guest",
              ),
            ),
            ElevatedButton(onPressed: _signInGoogle, child: const Text("Sign in with Google")),
            if (_authService.currentUser != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _handlePostSignIn,
                child: const Text("Continue"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
