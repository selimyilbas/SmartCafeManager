// lib/models/menu_item.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Menüdeki kategorileri enum olarak tanımlıyoruz.
enum Category { all, coffee, tea, dessert, sandwich, drink }

Category categoryFromString(String s) =>
    Category.values.firstWhere((e) => e.name == s, orElse: () => Category.all);

class MenuItem {
  final String id;
  final String name;
  final String imageUrl;
  final double price;
  final Category category;
  final int? stockQty;
  final int? minQty;
  final Map<String, List<String>> options;

  MenuItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.category,
    this.stockQty,
    this.minQty,
    required this.options,
  });

  /// Stokta olup olmadığını kontrol eder (stok adedi 0’dan büyükse true döner).
  bool get inStock => (stockQty ?? 0) > 0;

  /// Firestore’dan okunan DocumentSnapshot’tan MenuItem nesnesi oluşturur.
  factory MenuItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return MenuItem(
      id: doc.id,
      name: d['name'] as String,
      imageUrl: (d['imageUrl'] as String?) ?? '',
      price: (d['price'] as num).toDouble(),
      category: categoryFromString(d['category'] as String? ?? ''),
      stockQty: (d['stockQty'] as num?)?.toInt(),
      minQty: (d['minQty'] as num?)?.toInt(),
      options: (d['options'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, List<String>.from(v as List))) ??
          {},
    );
  }

  /// Firestore’a yazarken kullanacağımız Map<String, dynamic> formatı.
  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'category': category.name,
      'options': options,
      // Aşağıdaki satırlar, stockQty veya minQty null değilse eklenmesini sağlar:
      if (stockQty != null) 'stockQty': stockQty,
      if (minQty != null) 'minQty': minQty,
    };
    return m;
  }
}
