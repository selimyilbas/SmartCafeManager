import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShiftAdminProvider extends ChangeNotifier {
  Stream<QuerySnapshot<Map<String, dynamic>>> shiftsFor(DateTime day) {
    final start = Timestamp.fromDate(DateTime(day.year, day.month, day.day));
    final end   = Timestamp.fromDate(start.toDate().add(const Duration(days: 1)));
    return FirebaseFirestore.instance
        .collectionGroup('shifts')
        .where('in', isGreaterThan: start, isLessThan: end)
        .snapshots();
  }
}
