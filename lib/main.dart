import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'router.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: "Ttwigo MVP",
      theme: ThemeData(primarySwatch: Colors.blue),
      routerConfig: router,
    );
  }
}
