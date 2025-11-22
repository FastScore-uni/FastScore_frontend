import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  // Upload i download plików
  Future<String> uploadFile(File file, String folder) async {
    final fileName =
        "${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}";
    final ref = _storage.ref().child("$folder/$fileName");

    final snap = await ref.putFile(file);
    return await snap.ref.getDownloadURL();
  }

  Future<String> uploadStringFile({
    required String path,
    required String content,
    String contentType = 'text/xml',
  }) async {
    final ref = _storage.ref().child(path);

    final data = utf8.encode(content); // String -> bytes

    final metadata = SettableMetadata(contentType: contentType);

    await ref.putData(data, metadata);

    return await ref.getDownloadURL();
  }

  Future<String> downloadStringFile(String url) async {
    final ref = _storage.refFromURL(url);
    final data = await ref.getData();
    if (data == null) return "";

    return utf8.decode(data);
  }

  // Users
  Future<void> setUser(String id, Map<String, dynamic> data) async {
    await _db.collection('users').add(data);
  }

  Future<DocumentSnapshot> getUser(String id) async {
    return _db
        .collection('users')
        .doc(id)
        .get(GetOptions(source: Source.server));
  }

  Future<void> updateUser(String id, Map<String, dynamic> data) async {
    await _db.collection('users').doc(id).update(data);
  }

  Future<void> deleteUser(String id) {
    return _db.collection('users').doc(id).delete();
  }

  /// Subkolekcja pieces
  Future<String> addUserPiece(String userId, Map<String, dynamic> data) async {
    final doc = await _db
        .collection('users')
        .doc(userId)
        .collection('pieces')
        .add(data);
    return doc.id;
  }

  Future<DocumentSnapshot> getUserPiece(String userId, String pieceId) {
    return _db
        .collection('users')
        .doc(userId)
        .collection('pieces')
        .doc(pieceId)
        .get();
  }

  Future<void> deleteUserPieces(String userId) async {
    final ref = _db.collection('users').doc(userId).collection('pieces');
    final snap = await ref.get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
  }
}
