import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import 'package:flutter/foundation.dart';

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

  void add(MenuItem item, Map<String, String> chosen, String note) {
    // aynı item + aynı opsiyon + aynı not ise qty++
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

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
