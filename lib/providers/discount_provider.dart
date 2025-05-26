import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DiscountProvider extends ChangeNotifier {
  DiscountProvider() {
    _listen();
  }

  final _prices = <String, double>{};  // itemId → effective price

  void _listen() {
    FirebaseFirestore.instance.collection('menu').snapshots().listen((qs) {
      final now = Timestamp.now();
      for (final d in qs.docs) {
        var price = (d['price'] as num).toDouble();
        final disc = d['discount'];
        if (disc != null &&
            disc['start'] < now &&
            disc['end'] > now) {
          price = price * (1 - (disc['percent'] as num) / 100);
        }
        _prices[d.id] = price;
      }
      notifyListeners();
    });
  }

  double effective(String id, double fallback) => _prices[id] ?? fallback;
}
