import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  // Use the specific database you created (replace 'database-1' with your actual database name)
  // If it's the default database, use FirebaseFirestore.instance
  final _db = FirebaseFirestore.instance;  // Change this if using a named database
  final _storage = FirebaseStorage.instance;

  // Upload plików
  Future<String> uploadFile(File file, String folder) async {
    final fileName =
        "${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";
    final ref = _storage.ref().child("$folder/$fileName");

    final snap = await ref.putFile(file);
    return await snap.ref.getDownloadURL();
  }

  // Users
  // Future<String> addUser(Map<String, dynamic> data) async {
  //   final doc = await _db.collection('users').add(data);
  //   return doc.id;
  // }
  Future<void> setUser(String id, Map<String, dynamic> data) async {
    print("FirebaseService.setUser called with id: $id");
    print("Data: $data");
    print("Starting Firestore write operation...");
    
    try {
      // Don't use timeout - let it take as long as it needs
      await _db.collection('users').doc(id).set(data);
      print("✅ User document created successfully!");
    } catch (e) {
      print("❌ ERROR in setUser: $e");
      rethrow;
    }
  }

  Future<DocumentSnapshot> getUser(String id) async {
    print("FirebaseService.getUser called with id: $id");
    final doc = await _db.collection('users').doc(id).get();
    print("Document exists: ${doc.exists}");
    if (doc.exists) {
      print("Document data: ${doc.data()}");
    }
    return doc;
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _db.collection('users').doc(id).update(data);
  }

  // Pieces
  Future<String> addPiece(Map<String, dynamic> data) async {
    final doc = await _db.collection('pieces').add(data);
    return doc.id;
  }

  Future<DocumentSnapshot> getPiece(String id) async {
    return _db.collection('pieces').doc(id).get();
  }
}
