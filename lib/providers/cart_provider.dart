// lib/providers/cart_provider.dart

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/menu_item.dart';

/// Sepet içindeki her bir satırı temsil eder.
/// • item: MenuItem (ürün bilgisi)
/// • chosen: { "optionName": "value", … } şeklinde user’ın seçtiği opsiyonlar
/// • note: Kullanıcının eklediği not (örn. “Az şekerli” vb.)
/// • qty: Kaç adet seçildiği
class CartEntry {
  final MenuItem item;
  final Map<String, String> chosen;
  final String note;
  int qty;

  CartEntry(this.item, this.chosen, this.note, this.qty);
}

/// Sepet yönetimini yapan ChangeNotifier sınıfı.
/// Sepete ekleme, silme, adet arttırma/azaltma, toplam fiyat hesaplama vb. işlemler burada.
class CartProvider extends ChangeNotifier {
  final List<CartEntry> _items = [];

  /// Sepet içeriğini readonly olarak döner
  List<CartEntry> get items => List.unmodifiable(_items);

  /// Sepetin toplam fiyatını hesaplar (fiyat * qty)
  double get total => _items.fold(0.0, (sum, e) => sum + e.item.price * e.qty);

  /// Sepete ekleme; aynısından varsa adet++ yap, yoksa yeni ekle.
  void add(MenuItem item, Map<String, String> chosen, String note) {
    final idx = _items.indexWhere((e) =>
        e.item.id == item.id &&
        mapEquals(e.chosen, chosen) &&
        e.note == note);
    if (idx >= 0) {
      _items[idx].qty++;
    } else {
      _items.add(CartEntry(item, chosen, note, 1));
    }
    notifyListeners();
  }

  /// Sepeti temizler (tüm satırları siler)
  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Tek satırı tamamen siler
  void remove(CartEntry entry) {
    _items.remove(entry);
    notifyListeners();
  }

  /// Bir satırın qty’sini 1 arttırır
  void inc(CartEntry entry) {
    entry.qty++;
    notifyListeners();
  }

  /// Bir satırın qty’sini 1 azaltır; eğer 1’den 0’a inerse tamamen siler
  void dec(CartEntry entry) {
    if (entry.qty > 1) {
      entry.qty--;
    } else {
      _items.remove(entry);
    }
    notifyListeners();
  }
}
