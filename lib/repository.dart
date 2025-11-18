import 'dart:io';
import 'firebase_service.dart';
import 'data_models.dart';

class UserRepository {
  final FirebaseService service;
  UserRepository(this.service);

  Future<UserModel> createUser({
    required String id,
    required String login,
    required String email,
    required String phone,
  }) async {
    final data = {
      'login': login,
      'email': email,
      'phone': phone,
      'piece_list': [],
      'settings': {'language': 'pl'},
    };
    await service.setUser(id, data);
    return UserModel.fromJson(id, data);
  }

  Future<UserModel?> getUser(String id) async {
    final snap = await service.getUser(id);
    if (!snap.exists) return null;
    return UserModel.fromJson(snap.id, snap.data() as Map<String, dynamic>);
  }

  Future<void> updateUser(UserModel user) async {
    await service.updateUser(user.id, user.toJson());
  }
}

class PieceRepository {
  final FirebaseService service;
  PieceRepository(this.service);

  Future<PieceModel> createPiece({
    required String name,
    required File xml,
    required File midi,
    required File audio,
  }) async {
    final xmlUrl = await service.uploadFile(xml, 'xml');
    final midiUrl = await service.uploadFile(midi, 'midi');
    final audioUrl = await service.uploadFile(audio, 'audio');

    final data = {
      'name': name,
      'xml_url': xmlUrl,
      'midi_url': midiUrl,
      'audio_url': audioUrl,
    };

    final id = await service.addPiece(data);
    return PieceModel.fromJson(id, data);
  }

  Future<PieceModel?> getPiece(String id) async {
    final snap = await service.getPiece(id);
    if (!snap.exists) return null;
    return PieceModel.fromJson(snap.id, snap.data() as Map<String, dynamic>);
  }
}
