// lib/providers/stock_provider.dart

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/inventory_service.dart';

class StockProvider extends ChangeNotifier {
  final InventoryService _srv = InventoryService();

  /// Tüm envanteri QuerySnapshot olarak dinler.
  Stream<QuerySnapshot<Map<String, dynamic>>> get inventory$ {
    //  👇 Burada da eski 'streamInventory()' yerine 'streamInventorySnapshots()' kullanıyoruz:
    return _srv.streamInventorySnapshots();
  }

  /// Stoğu +1 artırır.
  Future<void> inc(String id) => _srv.adjust(id, 1);

  /// Stoğu -1 azaltır.
  Future<void> dec(String id) => _srv.adjust(id, -1);

  /// Stoğu delta kadar (±) değiştirir.
  Future<void> adjust(String id, int delta) => _srv.adjust(id, delta);
}
