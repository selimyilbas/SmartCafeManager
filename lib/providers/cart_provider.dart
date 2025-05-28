import 'package:flutter/foundation.dart';
import '../models/menu_item.dart';

/// Sepetteki tek bir girdi
class CartEntry {
  final MenuItem item;
  final Map<String, String> chosen; // optionName -> value
  final String note;
  int qty;

  CartEntry(this.item, this.chosen, this.note, this.qty);
}

class CartProvider extends ChangeNotifier {
  final List<CartEntry> _items = [];
  List<CartEntry> get items => _items;

  double get total =>
      _items.fold(0, (sum, e) => sum + e.item.price * e.qty);

  /// Sepete ekle (aynı item + opsiyon + not varsa qty++)
  void add(MenuItem item, Map<String, String> chosen, String note) {
    final idx = _items.indexWhere((e) =>
        e.item.id == item.id &&
        mapEquals(e.chosen, chosen) &&
        e.note == note);
    if (idx >= 0) {
      _items[idx].qty += 1;
    } else {
      _items.add(CartEntry(item, chosen, note, 1));
    }
    notifyListeners();
  }

  /// Sepeti tamamen temizle
  void clear() {
    _items.clear();
    notifyListeners();
  }

  /// Bir entry'nin miktarını ±delta kadar değiştirir.
  /// Eğer qty ≤ 0 olursa liste dışına atar (silme).
  void changeQty(CartEntry entry, int delta) {
    entry.qty += delta;
    if (entry.qty <= 0) {
      _items.remove(entry);
    }
    notifyListeners();
  }

  /// Bir entry'yi tamamen sepetten kaldırır
  void remove(CartEntry entry) {
    _items.remove(entry);
    notifyListeners();
  }
}
