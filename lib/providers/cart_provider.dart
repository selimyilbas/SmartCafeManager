import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../models/menu_item.dart';

class CartEntry {
  final MenuItem item;
  final Map<String, String> chosen; // optionName → value
  final String note;
  int qty;
  CartEntry(this.item, this.chosen, this.note, this.qty);
}

class CartProvider extends ChangeNotifier {
  final List<CartEntry> _items = [];
  List<CartEntry> get items => List.unmodifiable(_items);

  double get total =>
      _items.fold(0.0, (sum, e) => sum + e.item.price * e.qty);

  /// Sepete ekle; aynı entry varsa qty++ yap
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

  /// Tüm sepeti temizle
  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Tek bir entry’i sepetten tamamen çıkar
  void remove(CartEntry entry) {
    _items.remove(entry);
    notifyListeners();
  }

  /// Bir entry’nin miktarını 1 arttır
  void inc(CartEntry entry) {
    entry.qty++;
    notifyListeners();
  }

  /// Bir entry’nin miktarını 1 azalt; 0 olursa tamamen sil
  void dec(CartEntry entry) {
    if (entry.qty > 1) {
      entry.qty--;
    } else {
      _items.remove(entry);
    }
    notifyListeners();
  }
}
