// lib/providers/menu_admin_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';

import '../models/menu_item.dart';
import '../services/menu_admin_service.dart';
import '../services/inventory_service.dart';

class MenuAdminProvider extends ChangeNotifier {
  final _menuSvc = MenuAdminService();
  final _invSvc  = InventoryService();

  /// menu koleksiyonundaki snapshot ile inventory koleksiyonundaki snapshot'ı birleştir.
  Stream<List<MenuItem>> streamMenu() {
    // 1) menu snapshot akışı
    final menuStream = _menuSvc.streamMenuSnapshots();     // Stream<QuerySnapshot<menu>>
    // 2) inventory snapshot akışı
    final invStream  = _invSvc.streamInventorySnapshots(); // Stream<QuerySnapshot<inventory>>

    return Rx.combineLatest2<
      QuerySnapshot<Map<String, dynamic>>,
      QuerySnapshot<Map<String, dynamic>>,
      List<MenuItem>
    >(
      menuStream,
      invStream,
      (menuSnap, invSnap) {
        // 3) Önce inventory snapshot'ından bir Map<id, {stockQty, minQty}> oluştur
        final invMap = <String, Map<String, int>>{};
        for (final doc in invSnap.docs) {
          final data = doc.data();
          final stockVal = (data['stockQty'] as num?)?.toInt() ?? 0;
          final minVal   = (data['minQty']   as num?)?.toInt() ?? 0;
          invMap[doc.id] = {
            'stockQty': stockVal,
            'minQty':   minVal,
          };
        }

        // 4) Menü snapshot'ındaki her belgeyi MenuItem'a dönüştür, 
        //    ardından inventory'den gelen değerlerle override et
        return menuSnap.docs.map((docSnap) {
          final base = MenuItem.fromDoc(docSnap);

          // Eğer inventory'de bu menü öğesine ait bir kayıt varsa, o değerleri al
          final invData = invMap[base.id];
          final mergedStock = invData != null ? invData['stockQty'] : base.stockQty;
          final mergedMin   = invData != null ? invData['minQty']   : base.minQty;

          // Yeni MenuItem nesnesini, envanter verisi ile oluştur:
          return MenuItem(
            id:       base.id,
            name:     base.name,
            imageUrl: base.imageUrl,
            price:    base.price,
            category: base.category,
            stockQty: mergedStock,
            minQty:   mergedMin,
            options:  base.options,
          );
        }).toList();
      },
    );
  }

  /// Menüyü listeye ekle (sadece menü koleksiyonunu etkiler, envanter koleksiyonuna eklenmez)
  Future<void> addItem(MenuItem item) {
    return _menuSvc.addItem(item);
  }

  /// Menü öğesini güncelle
  Future<void> updateItem(MenuItem item) {
    return _menuSvc.updateItem(item);
  }

  /// Menü öğesini sil
  Future<void> deleteItem(String id) {
    return _menuSvc.deleteItem(id);
  }

  /// Sadece minQty değerini güncelle (menü koleksiyonuna yazar)
  Future<void> setMin(String itemId, int minQty) {
    return _menuSvc.setMinQty(itemId, minQty);
  }
}
