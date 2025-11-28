import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  String? _phoneNumber;
  ConfirmationResult? _confirmationResult;

  Future<String> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!.uid;
  }

  Future<String> register(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user!.uid;
  }

  Future<void> phoneSendCode(String phoneNum) async {
    _confirmationResult = null;
    _phoneNumber = null;


    _confirmationResult = await _auth.signInWithPhoneNumber(
      phoneNum
    );
    if (_confirmationResult != null) {
      _phoneNumber = phoneNum;
    }
  }

  Future<String> phoneRegister(String phoneNum, String code) async {
    if (phoneNum != _phoneNumber) {
      return "";
    }
    UserCredential userCredential = await _confirmationResult!.confirm(code);
    return userCredential.user!.uid;
  }

  Future<void> deleteCurrentUser() async {
    await _auth.currentUser?.delete();
  }

  String? get currentUserId => _auth.currentUser?.uid;

  Stream<String?> get onAuthStateChange {
    return _auth.authStateChanges().map((user) => user?.uid);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
