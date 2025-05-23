import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/stock_service.dart';

class StockProvider extends ChangeNotifier {
  final _srv = StockService();

  Stream<QuerySnapshot<Map<String, dynamic>>> stream() => _srv.stream();

  Future<void> inc(String id)   => _srv.adjust(id,  1);
  Future<void> dec(String id)   => _srv.adjust(id, -1);

  /// ± 10 / ± 50 / özel sayı için
  Future<void> adjust(String id, int delta) => _srv.adjust(id, delta);
}
