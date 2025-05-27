import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/inventory_service.dart';

class StockProvider extends ChangeNotifier {
  final InventoryService _srv = InventoryService();

  /// Tüm envanteri dinler
  Stream<QuerySnapshot<Map<String, dynamic>>> get inventory$ => _srv.streamInventory();

  /// Stoğu +1 artırır
  Future<void> inc(String id) => _srv.adjust(id, 1);

  /// Stoğu -1 azaltır
  Future<void> dec(String id) => _srv.adjust(id, -1);

  /// Stoğu delta kadar (±) günceller
  Future<void> adjust(String id, int delta) => _srv.adjust(id, delta);
}
