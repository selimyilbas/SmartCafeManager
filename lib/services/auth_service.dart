import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<User?> signUp({
  required String email,
  required String password,
  required String role,
}) async {
  try {
    UserCredential res = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    print('[+] FirebaseAuth tamam. UID: ${res.user!.uid}');

    // Firestore'a yazmayı logla
    final data = {
      'email': email.trim(),
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _db.collection('users').doc(res.user!.uid).set(data);

    print('[+] Firestore’a veri yazıldı: $data');

    return res.user;
  } catch (e) {
    print('[!] signUp() hatası: $e');
    return null;
  }
}


  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential res = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      print('[+] Giriş başarılı: ${res.user!.uid}');
      return res.user;
    } catch (e) {
      print('[!] signIn() hatası: $e');
      return null;
    }
  }

  Future<void> signOut() => _auth.signOut();
}
