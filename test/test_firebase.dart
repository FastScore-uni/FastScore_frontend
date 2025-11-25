// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fastscore_frontend/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:fastscore_frontend/services/auth_service.dart';
import 'package:fastscore_frontend/services/firebase_service.dart';
import 'package:fastscore_frontend/repositories.dart';

import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // DON'T configure any Firestore settings - use defaults
  print("Firestore initialized for project: fastscore-b82f4");
  print("Using default Firestore settings (no custom configuration)");

  runApp(TestApp());
}

class TestApp extends StatefulWidget {
  const TestApp({super.key});

  @override
  State<TestApp> createState() => _TestAppState();
}

class _TestAppState extends State<TestApp> {
  @override
  void initState() {
    super.initState();
    // Run tests after widget is mounted and Firebase is ready
    Future.delayed(Duration(seconds: 2), () {
      _runTests();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(child: Text("Running Firebase tests... see console")),
      ),
    );
  }

  Future<void> _runTests() async {
    try {
      // Wait for Firebase to fully initialize
      print("===== FIREBASE TEST START =====");
      print("-> Waiting 1 second for Firebase SDK to fully initialize...");
      await Future.delayed(Duration(seconds: 1));

      final auth = AuthService();
      final firebase = FirebaseService();
      final userRepo = UserRepository(auth, firebase);

      String testUserId = "pYOhLJq137b2Em4Q2AaB8KKbOeh1";

      await _connectionTests(testUserId);
      await _userTests(auth, userRepo);

      print("===== FIREBASE TEST FINISHED =====");
    } catch (e, stackTrace) {
      print("ERROR: $e");
      print("Stack trace: $stackTrace");
    }
  }

  Future<void> _connectionTests(String existingUserId) async {
    // TEST 0 - CHECK FIRESTORE CONNECTION
    print("-> Testing Firestore connection...");
    print("   Project ID: fastscore-b82f4");

    // Wait a bit longer for Firestore to initialize
    print("-> Waiting 5 seconds for Firestore to fully initialize...");
    await Future.delayed(Duration(seconds: 5));

    try {
      print("   Attempting to read from Firestore...");

      // Try to read the specific document we can see in the screenshot
      print("   Trying to get document $existingUserId by ID...");
      final specificDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(existingUserId)
          .get();

      if (specificDoc.exists) {
        print("   ✅ Found the manual document!");
        print("   Data: ${specificDoc.data()}");
      } else {
        print("   ❌ Document $existingUserId NOT found!");
      }

      // Also try listing all documents
      print("   Listing all documents in users collection...");
      final testDoc = await FirebaseFirestore.instance
          .collection('users')
          .get();

      print(
        "SUCCESS: Firestore query completed! Found ${testDoc.docs.length} documents",
      );
      if (testDoc.docs.isNotEmpty) {
        for (var doc in testDoc.docs) {
          print("   - Document ID: ${doc.id}, data: ${doc.data()}");
        }
      } else {
        print(
          "   No documents found in query (but we see one in Firebase Console!)",
        );
      }
    } catch (e) {
      print("ERROR: Cannot connect to Firestore: $e");
      print("Check browser console (F12) for CORS/network errors");
      return;
    }
  }

  Future<void> _userTests(
    AuthService auth,
    UserRepository userRepo,
  ) async {
    // TEST 1 — REJESTRACJA
    print("-> Registering new user...");
    final email = "test${DateTime.now().millisecondsSinceEpoch}@example.com";
    final password = "qwerty123";
    final userId = await auth.register(email, password);
    print("Registered user with UID: $userId");

    // Verify the user is actually signed in
    print("-> Checking if user is signed in...");
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print("ERROR: User is NOT signed in after registration!");
      return;
    }
    print("SUCCESS: User is signed in. UID: ${currentUser.uid}");
    print("   Email: ${currentUser.email}");

    // TEST 2 — TWORZENIE PROFILU
    print("-> Creating Firestore user profile...");
    print("   Using document ID: $userId");

    // DIRECT TEST - try writing directly to Firestore without service layer
    print("-> DIRECT TEST: Writing to Firestore directly...");
    try {
      print("   Writing document $userId...");
      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'login': 'tester',
        'email': email,
        'phone': '123-456-789',
        'piece_list': [],
        'settings': {'language': 'pl'},
      });
      print("✅ SUCCESS: Direct write completed!");
    } catch (e) {
      print("❌ ERROR: Direct write failed: $e");
    }

    // Now try through service layer
    print("-> Creating profile through service layer...");
    final profile = await userRepo.createUser(
      login: "tester",
      password: "admin1234",
      email: email,
      phone: "123-456-789",
    );
    print("User profile created locally: ${profile.toJson()}");

    // TEST 2.5 — IMMEDIATE FETCH TO CONFIRM CREATION
    print("-> Immediately fetching user to confirm it was saved...");
    final immediateCheck = await userRepo.getUser(userId);
    if (immediateCheck == null) {
      print("ERROR: User NOT found immediately after creation!");
      print("   This means the write to Firestore failed or hasn't synced yet");
    } else {
      print("SUCCESS: User found immediately after creation!");
      print("   Data: ${immediateCheck.toJson()}");
    }

    // Wait a moment for Firestore to sync
    print("-> Waiting 2 seconds for Firestore to sync...");
    await Future.delayed(Duration(seconds: 2));

    // TEST 3 — POBRANIE PROFILU
    print("-> Fetching user profile again...");
    print("   Looking for document ID: $userId");
    final fetched = await userRepo.getUser(userId);
    if (fetched == null) {
      print("ERROR: User not found in Firestore!");
      return;
    }
    print("Fetched: ${fetched.toJson()}");

    // TEST 4 — AKTUALIZACJA PROFILU
    print("-> Updating profile (changing language to 'en')...");
    final updated = fetched.copyWith(
      settings: fetched.settings.copyWith(language: "en"),
    );
    await userRepo.updateUser(updated);

    // TEST 5 — SPRAWDZENIE AKTUALIZACJI
    print("-> Fetching updated profile...");
    final updatedFetched = await userRepo.getUser(userId);
    print("Updated profile: ${updatedFetched?.toJson()}");
  }
}
