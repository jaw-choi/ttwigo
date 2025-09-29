import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';

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

  Future<void> _signInEmail() async {
    try {
      await _authService.signInWithEmail(_email.text, _password.text);
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _registerEmail() async {
    try {
      await _authService.registerWithEmail(_email.text, _password.text);
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _signInAnon() async {
    try {
      await _authService.signInAnonymously();
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _signInGoogle() async {
    try {
      await _authService.signInWithGoogle();
      if (mounted) context.go('/home');
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
            ElevatedButton(onPressed: _signInAnon, child: const Text("Continue as Guest")),
            ElevatedButton(onPressed: _signInGoogle, child: const Text("Sign in with Google")),
          ],
        ),
      ),
    );
  }
}
