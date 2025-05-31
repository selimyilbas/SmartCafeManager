// lib/providers/stock_admin_provider.dart

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/inventory_service.dart';

class StockAdminProvider extends ChangeNotifier {
  final _srv = InventoryService();

  /// Kritik stokta (stockQty ≤ minQty) olan ürünleri 
  /// server-side değil, client-side filtreleyerek verir.
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> get critical$ {
    return _srv.streamCritical();
  }

  /// Tüm envanteri (tüm kalemleri) QueryDocumentSnapshot listesi olarak döner.
  Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>> get allItems$ {
    //  👇 Burada eski 'streamInventory()' yerine 'streamInventorySnapshots()' kullanıyoruz:
    return _srv.streamInventorySnapshots().map((snap) => snap.docs);
  }

  /// Stoğu birebir ayarlar (inventory koleksiyonundaki stockQty alanını set eder).
  Future<void> setStockQty(String id, int qty) => _srv.setStockQty(id, qty);

  /// Kritik eşiği (minQty) ayarlar.
  Future<void> setMinQty(String id, int minQty) => _srv.updateMinQty(id, minQty);
}
