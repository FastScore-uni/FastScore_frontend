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
  debugPrint("Firestore initialized for project: fastscore-b82f4");
  debugPrint("Using default Firestore settings (no custom configuration)");

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
      debugPrint("===== FIREBASE TEST START =====");
      debugPrint("-> Waiting 1 second for Firebase SDK to fully initialize...");
      await Future.delayed(Duration(seconds: 1));

      final auth = AuthService();
      final firebase = FirebaseService();
      final userRepo = UserRepository(auth, firebase);
      final pieceRepo = PieceRepository(firebase);

      String testUserId = "g2FpaB57YpeHaUnzlvVVYhlT9Xp1";

      await _connectionTests(testUserId);
      await _userTests(auth, userRepo);
      await _pieceTests(testUserId, pieceRepo);

      debugPrint("===== FIREBASE TEST FINISHED =====");
    } catch (e, stackTrace) {
      debugPrint("ERROR: $e");
      debugPrint("Stack trace: $stackTrace");
    }
  }

  Future<void> _connectionTests(String existingUserId) async {
    // TEST 0 - CHECK FIRESTORE CONNECTION
    debugPrint("-> Testing Firestore connection...");
    debugPrint("   Project ID: fastscore-b82f4");

    // Wait a bit longer for Firestore to initialize
    debugPrint("-> Waiting 5 seconds for Firestore to fully initialize...");
    await Future.delayed(Duration(seconds: 5));

    try {
      debugPrint("   Attempting to read from Firestore...");

      // Try to read the specific document we can see in the screenshot
      debugPrint("   Trying to get document $existingUserId by ID...");
      final specificDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(existingUserId)
          .get();

      if (specificDoc.exists) {
        debugPrint("   ✅ Found the manual document!");
        debugPrint("   Data: ${specificDoc.data()}");
      } else {
        debugPrint("   ❌ Document $existingUserId NOT found!");
      }

      // Also try listing all documents
      debugPrint("   Listing all documents in users collection...");
      final testDoc = await FirebaseFirestore.instance
          .collection('users')
          .get();

      debugPrint(
        "SUCCESS: Firestore query completed! Found ${testDoc.docs.length} documents",
      );
      if (testDoc.docs.isNotEmpty) {
        for (var doc in testDoc.docs) {
          debugPrint("   - Document ID: ${doc.id}, data: ${doc.data()}");
        }
      } else {
        debugPrint(
          "   No documents found in query (but we see one in Firebase Console!)",
        );
      }
    } catch (e) {
      debugPrint("ERROR: Cannot connect to Firestore: $e");
      debugPrint("Check browser console (F12) for CORS/network errors");
      return;
    }
  }

  Future<void> _userTests(AuthService auth, UserRepository userRepo) async {
    // TEST 1 — REJESTRACJA
    debugPrint("-> Registering new user...");
    final email = "test${DateTime.now().millisecondsSinceEpoch}@example.com";
    final password = "qwerty123";
    final directUserId = await auth.emailRegister(email, password);
    debugPrint("Registered user with UID: $directUserId");

    // Verify the user is actually signed in
    debugPrint("-> Checking if user is signed in...");
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      debugPrint("ERROR: User is NOT signed in after registration!");
      return;
    }
    debugPrint("SUCCESS: User is signed in. UID: ${currentUser.uid}");
    debugPrint("   Email: ${currentUser.email}");

    // TEST 2 — TWORZENIE PROFILU
    debugPrint("-> Creating Firestore user profile...");
    debugPrint("   Using document ID: $directUserId");

    // DIRECT TEST - try writing directly to Firestore without service layer
    debugPrint("-> DIRECT TEST: Writing to Firestore directly...");
    try {
      debugPrint("   Writing document $directUserId...");
      await FirebaseFirestore.instance
          .collection('users')
          .doc(directUserId)
          .set({
            'login': 'tester',
            'email': email,
            'phone': '123-456-789',
            'piece_list': [],
            'settings': {'language': 'pl'},
          });
      debugPrint("✅ SUCCESS: Direct write completed!");
    } catch (e) {
      debugPrint("❌ ERROR: Direct write failed: $e");
    }

    // Now try through repo layer
    debugPrint("-> Creating profile through service layer...");
    final email2 = "test${DateTime.now().millisecondsSinceEpoch}@example.com";
    final profile = await userRepo.createUser(
      login: "tester",
      password: "admin1234",
      email: email2,
      phone: "123-456-789",
    );
    debugPrint("User profile created locally: ${profile.toJson()}");

    final String repoUserId = profile.id;
    // TEST 2.5 — IMMEDIATE FETCH TO CONFIRM CREATION
    debugPrint("-> Immediately fetching user to confirm it was saved...");
    final immediateCheck = await userRepo.getUser(repoUserId);
    if (immediateCheck == null) {
      debugPrint("ERROR: User NOT found immediately after creation!");
      debugPrint(
        "   This means the write to Firestore failed or hasn't synced yet",
      );
    } else {
      debugPrint("SUCCESS: User found immediately after creation!");
      debugPrint("   Data: ${immediateCheck.toJson()}");
    }

    // Wait a moment for Firestore to sync
    debugPrint("-> Waiting 2 seconds for Firestore to sync...");
    await Future.delayed(Duration(seconds: 2));

    // TEST 3 — POBRANIE PROFILU
    debugPrint("-> Fetching user profile again...");
    debugPrint("   Looking for document ID: $repoUserId");
    final fetched = await userRepo.getUser(repoUserId);
    if (fetched == null) {
      debugPrint("ERROR: User not found in Firestore!");
    } else {
      debugPrint("Fetched: ${fetched.toJson()}");
      // TEST 4 — AKTUALIZACJA PROFILU
      debugPrint("-> Updating profile (changing language to 'en')...");
      final updated = fetched.copyWith(
        settings: fetched.settings.copyWith(language: "en"),
      );
      await userRepo.updateUser(updated);

      // TEST 5 — SPRAWDZENIE AKTUALIZACJI
      debugPrint("-> Fetching updated profile...");
      final updatedFetched = await userRepo.getUser(repoUserId);
      debugPrint("Updated profile: ${updatedFetched?.toJson()}");
    }



    // TEST 6 — USUWANIE UŻYTKOWNIKÓW
    try {
      debugPrint("-> Deleting users...");
      auth.logout();
      await userRepo.deleteUser(directUserId);
      await userRepo.deleteUser(repoUserId);
      debugPrint("✅ SUCCESS: Created users removed from database");
    } catch (e) {
      debugPrint("❌ ERROR: deletion failed: $e");
    }
  }

  Future<void> _pieceTests(String userId, PieceRepository pieceRepo) async {
    debugPrint("===== PIECE TESTS START =====");

    final xmlContent = """
  <score-partwise>
     <part>
        <measure>
           <note><pitch><step>C</step><octave>4</octave></pitch></note>
        </measure>
     </part>
  </score-partwise>
  """;

    debugPrint("-> Adding new piece...");
    final piece = await pieceRepo.createPiece(
      userId: userId,
      name: "Test Piece",
      xmlString: xmlContent,
    );

    debugPrint("   Created piece:");
    debugPrint("   ID: ${piece.id}");
    debugPrint("   name: ${piece.name}");
    debugPrint("   xml_url: ${piece.xmlUrl}");

    // TEST 2 — Odczyt metadanych + content
    debugPrint("-> Fetching piece with XML content...");
    final full = await pieceRepo.getPiece(userId: userId, pieceId: piece.id);

    if (full == null) {
      debugPrint("❌ ERROR: Piece not found!");
      return;
    }

    debugPrint("   Piece metadata: ${full.meta.toJson()}");
    debugPrint("   XML content loaded:");
    debugPrint(full.xmlContent);

    // TEST 3 — Usuwanie
    debugPrint("-> Deleting piece...");
    await pieceRepo.deletePiece(userId: userId, meta: full.meta);

    // TEST 4 — Sprawdzenie czy usunięty
    debugPrint("-> Verifying deletion...");
    final checkAgain = await pieceRepo.getPiece(
      userId: userId,
      pieceId: piece.id,
    );

    if (checkAgain == null) {
      debugPrint("   SUCCESS: Piece removed from Firestore!");
    } else {
      debugPrint("   ❌ ERROR: Piece still exists in Firestore!");
    }

    debugPrint("===== PIECE TESTS END =====");
  }
}
