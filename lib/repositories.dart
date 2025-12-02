import 'package:cloud_firestore/cloud_firestore.dart';

import 'services/firebase_service.dart';
import 'services/auth_service.dart';
import 'models/database_models.dart';

class UserRepository {
  final AuthService _auth;
  final FirebaseService _db;

  UserRepository(this._auth, this._db);

  Stream<String?> get onAuthStateChange => _auth.onAuthStateChange;

  Future<UserModel> createUser({
    required String email,
    required String password,
    required String login,
    required String phone,
  }) async {
    // 1. tworzymy konto w auth
    final uid = await _auth.emailRegister(email, password);

    // 2. zapisujemy dokument użytkownika
    final data = {
      'login': login,
      'email': email,
      'phone': phone,
      'settings': {'language': 'pl'},
    };

    await _db.setUser(uid, data);
    return UserModel.fromJson(uid, data);
  }

  Future<void> sendVerificationCode(String phoneNum) async {
    _auth.phoneSendCode(phoneNum);
  }

  Future<UserModel> createUserByPhone({
    required String email,
    required String login,
    required String phone,
    required String code,
  }) async {
    // 1. tworzymy konto w auth
    final uid = await _auth.phoneVerify(phone, code);

    // 2. zapisujemy dokument użytkownika
    final data = {
      'login': login,
      'email': email,
      'phone': phone,
      'settings': {'language': 'pl'},
    };

    await _db.setUser(uid, data);
    return UserModel.fromJson(uid, data);
  }

  Future<UserModel> verifyUserByGoogle() async {
    final data = await _auth.googleVerify();

    String uid = data['uid']!;
    await _db.setUser(uid, data);
    return UserModel.fromJson(uid, data);
  }

  Future<UserModel> signInUser({
    required String email,
    required String password,
  }) async {
    try {
      final uid = await _auth.emailLogin(email, password);
      final userData = await getUser(uid);
      if (userData == null) {
        throw Exception("Brak danych użytkownika.");
      }
      return userData;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOutUser() async {
    return await _auth.logout();
  }

  Future<UserModel?> getUser(String id) async {
    final snap = await _db.getUser(id);
    if (!snap.exists) return null;
    return UserModel.fromJson(id, snap.data() as Map<String, dynamic>);
  }

  Future<void> updateUser(UserModel user) async {
    await _db.setUser(user.id, user.toJson());
  }

  /// 🔥 USUWANIE – najpierw dane, potem auth
  Future<void> deleteUser(String uid) async {
    // 1. usuń subkolekcję pieces
    await _db.deleteUserPieces(uid);

    // 2. usuń dokument użytkownika
    await _db.deleteUser(uid);

    // 3. usuń użytkownika z Auth
    await _auth.deleteCurrentUser();
  }
}

class PieceRepository {
  final FirebaseService _db;

  PieceRepository(this._db);

  Future<PieceModel> createPiece({
    required String userId,
    required String name,
    required String xmlString,
  }) async {
    // 1. wrzucamy XML do storage
    final xmlUrl = await _db.uploadStringFile(
      path: "users/$userId/pieces/$name.xml",
      content: xmlString,
      contentType: 'text/xml',
    );

    // 2. dane do firestore
    final data = {
      'name': name,
      'xml_url': xmlUrl,
      'created_at': Timestamp.now(),
    };

    // 3. dodajemy dokument do subkolekcji
    final id = await _db.addUserPiece(userId, data);

    return PieceModel.fromJson(id, data);
  }

  Future<PieceFullModel?> getPiece({
    required String userId,
    required String pieceId,
  }) async {
    // 1. Pobierz metadane z Firestore
    final snap = await _db.getUserPiece(userId, pieceId);
    if (!snap.exists) return null;

    final data = snap.data() as Map<String, dynamic>;
    final meta = PieceModel.fromJson(pieceId, data);

    // 2. Pobierz XML ze Storage (jeśli jest)
    String? xmlContent;
    if (meta.xmlUrl.isNotEmpty) {
      xmlContent = await _db.downloadStringFile(meta.xmlUrl);
    }

    // 3. Zwróć metadane + zawartość pliku
    return PieceFullModel(meta: meta, xmlContent: xmlContent);
  }

  Future<void> deletePiece({
    required String userId,
    required PieceModel meta,
  }) async {
    // 1. Usuń plik XML ze Storage (jeśli istnieje)
    if (meta.xmlUrl.isNotEmpty) {
      await _db.deleteFile(meta.xmlUrl);
    }

    // 2. Usuń dokument z Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('pieces')
        .doc(meta.id)
        .delete();
  }
}
