import 'package:cloud_firestore/cloud_firestore.dart';

class ManagerService {
  final _codes = FirebaseFirestore.instance.collection('invite_codes');

  /// create an invite code for employee or manager
  Future<void> createInvite(String code, String role) =>
      _codes.doc(code).set({'role': role, 'createdAt': FieldValue.serverTimestamp()});

  Future<void> revokeInvite(String code) => _codes.doc(code).delete();
}
