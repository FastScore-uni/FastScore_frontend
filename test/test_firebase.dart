// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fastscore_frontend/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:fastscore_frontend/auth_service.dart';
import 'package:fastscore_frontend/firebase_service.dart';
import 'package:fastscore_frontend/repository.dart';

import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
    sslEnabled: true,
  );
  // FirebaseFirestore.instance.enableLogging(true);

  runApp(TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    _runTests();
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text("Running Firebase tests... see console")),
      ),
    );
  }

  Future<void> _runTests() async {
    final auth = AuthService();
    final firebase = FirebaseService();
    final userRepo = UserRepository(firebase);

    print("===== FIREBASE TEST START =====");

    // TEST 1 — REJESTRACJA
    print("-> Registering new user...");
    final email = "test${DateTime.now().millisecondsSinceEpoch}@example.com";
    final password = "qwerty123";
    final userId = await auth.register(email, password);
    print("Registered user with UID: $userId");

    // TEST 2 — TWORZENIE PROFILU
    print("-> Creating Firestore user profile...");
    final profile = await userRepo.createUser(
      id: userId,
      login: "tester",
      email: email,
      phone: "123-456-789",
    );
    print("User profile created: ${profile.toJson()}");

    // TEST 3 — POBRANIE PROFILU
    print("-> Fetching user profile...");
    final fetched = await userRepo.getUser(userId);
    print("Fetched: ${fetched?.toJson()}");

    // TEST 4 — AKTUALIZACJA PROFILU
    print("-> Updating profile (changing language to 'en')...");
    final updated = fetched!.copyWith(
      settings: fetched.settings.copyWith(language: "en"),
    );
    await userRepo.updateUser(updated);

    // TEST 5 — SPRAWDZENIE AKTUALIZACJI
    print("-> Fetching updated profile...");
    final updatedFetched = await userRepo.getUser(userId);
    print("Updated profile: ${updatedFetched?.toJson()}");

    print("===== FIREBASE TEST FINISHED =====");
  }
}
