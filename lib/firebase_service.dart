import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final _db = FirebaseFirestore.instance;
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
    await _db.collection('users').add(data);
  }

  Future<DocumentSnapshot> getUser(String id) async {
    return _db.collection('users').doc(id).get(GetOptions(source: Source.server));
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
