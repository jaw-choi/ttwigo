import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

// ================== main ==================
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBIRt7OopRFR0BfjE3T4YgvcHv2nYOrwwo",
        authDomain: "ttwigo-86d8d.firebaseapp.com",
        projectId: "ttwigo-86d8d",
        storageBucket: "ttwigo-86d8d.appspot.com",
        messagingSenderId: "1076941031873",
        appId: "1:1076941031873:web:128c782cb0b95abe6d4740",
        measurementId: "G-JRCBJXV4GL",
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

// ================== Router ==================
final GoRouter _router = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
    GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
    GoRoute(path: '/home', builder: (c, s) => const HomeScreen()),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Ttwigo MVP",
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: _router,
    );
  }
}

// ================== Splash ==================
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), _checkAuth);
  }

  void _checkAuth() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/mainImage.png', width: 200, height: 200),
      ),
    );
  }
}

// ================== Login ==================
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _email = TextEditingController();
  final _password = TextEditingController();
  String _error = '';

  Future<void> _signInEmail() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      if (mounted) context.go('/home');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Login failed');
    }
  }

  Future<void> _registerEmail() async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      if (mounted) context.go('/home');
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message ?? 'Register failed');
    }
  }

  Future<void> _signInAnon() async {
    try {
      await _auth.signInAnonymously();
      if (mounted) context.go('/home');
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _signInGoogle() async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if (gUser == null) return;
      final gAuth = await gUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );
      await _auth.signInWithCredential(credential);
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

// ================== Home ==================
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final email = (user != null && !user.isAnonymous) ? user.email ?? "Unknown" : "Guest";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        actions: [IconButton(onPressed: () => _signOut(context), icon: const Icon(Icons.logout))],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Welcome $email"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ServiceCategoryScreen()));
              },
              child: const Text("서비스 견적 요청하기"),
            ),
          ],
        ),
      ),
    );
  }
}

// ================== 서비스 카테고리/견적 ==================
class ServiceCategoryScreen extends StatelessWidget {
  const ServiceCategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final services = ["에어컨", "TV 벽걸이", "보일러"];
    return Scaffold(
      appBar: AppBar(title: const Text("서비스 선택")),
      body: ListView.builder(
        itemCount: services.length,
        itemBuilder: (c, i) {
          return ListTile(
            title: Text(services[i]),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => QuoteProcessScreen(serviceName: services[i])),
              );
            },
          );
        },
      ),
    );
  }
}

// ================== 견적 질문 ==================
class QuoteProcessScreen extends StatelessWidget {
  final String serviceName;
  const QuoteProcessScreen({super.key, required this.serviceName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("$serviceName 견적 요청")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => SummaryScreen(serviceName: serviceName, formData: {"서비스": "설치"})),
            );
          },
          child: const Text("예시: 질문 완료 → 요약 이동"),
        ),
      ),
    );
  }
}

// ================== 요약 화면 ==================
class SummaryScreen extends StatelessWidget {
  final String serviceName;
  final Map<String, dynamic> formData;
  const SummaryScreen({super.key, required this.serviceName, required this.formData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("요청 내용 확인")),
      body: ListView(
        children: formData.entries
            .map((e) => ListTile(title: Text(e.key), subtitle: Text(e.value.toString())))
            .toList(),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => RecommendationsScreen(serviceName: serviceName)));
          },
          child: const Text("추천 전문가 보기"),
        ),
      ),
    );
  }
}

// ================== 추천 전문가 ==================
class RecommendationsScreen extends StatelessWidget {
  final String serviceName;
  const RecommendationsScreen({super.key, required this.serviceName});

  @override
  Widget build(BuildContext context) {
    final experts = [
      {"name": "김프로", "tags": ["에어컨", "설치"]},
      {"name": "이명장", "tags": ["보일러", "수리"]},
    ];
    return Scaffold(
      appBar: AppBar(title: const Text("추천 전문가")),
      body: ListView(
        children: experts.map((e) {
          return ListTile(
            title: Text(e["name"] as String),
            subtitle: Text("전문 분야: ${(e["tags"] as List).join(', ')}"),
            trailing: ElevatedButton(onPressed: () {}, child: const Text("상담")),
          );
        }).toList(),
      ),
    );
  }
}
