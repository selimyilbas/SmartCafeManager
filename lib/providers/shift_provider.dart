import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/shift_service.dart';

/// Çalışanın kendi aktif shift’ini takip eder, clockIn/clockOut işlemlerini yapar.
class ShiftProvider extends ChangeNotifier {
  final _srv  = ShiftService();
  final _auth = FirebaseAuth.instance;

  String? activeShiftId;
  late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>> _sub;

  ShiftProvider() {
    final uid = _auth.currentUser?.uid;
    if (uid != null) {
      _sub = _srv.streamMyShifts(uid).listen((snap) {
        // İlk endedAt == null dökümanını bul
        QueryDocumentSnapshot<Map<String, dynamic>>? openDoc;
        for (var doc in snap.docs) {
          if (doc.data()['endedAt'] == null) {
            openDoc = doc;
            break;
          }
        }
        final newActive = openDoc?.id;
        if (newActive != activeShiftId) {
          activeShiftId = newActive;
          notifyListeners();
        }
      });
    }
  }

  Future<void> clockIn() async {
    final uid = _auth.currentUser!.uid;
    await _srv.startShift(uid);
  }

  Future<void> clockOut() async {
    final uid = _auth.currentUser!.uid;
    if (activeShiftId != null) {
      await _srv.endShift(uid, activeShiftId!);
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
