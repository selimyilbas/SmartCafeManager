import 'package:cloud_firestore/cloud_firestore.dart';

enum Category { all, coffee, tea, dessert, sandwich, drink }
Category categoryFromString(String s) =>
    Category.values.firstWhere((e) => e.name == s, orElse: () => Category.all);

class MenuItem {
  final String id, name, imageUrl;
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

  /// Yeni: stokta olup olmadığını döner
  bool get inStock => (stockQty ?? 0) > 0;

  factory MenuItem.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return MenuItem(
      id: doc.id,
      name: d['name'] as String,
      imageUrl: (d['imageUrl'] as String?) ?? '',
      price: (d['price'] as num).toDouble(),
      category: categoryFromString(d['category'] as String? ?? ''),
      stockQty: (d['stockQty'] as num?)?.toInt(),
      minQty:   (d['minQty']   as num?)?.toInt(),
      options: (d['options'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, List<String>.from(v as List)),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    final m = <String, dynamic>{
      'name':     name,
      'imageUrl': imageUrl,
      'price':    price,
      'category': category.name,
      'options':  options,
    };
    if (stockQty != null) m['stockQty'] = stockQty;
    if (minQty   != null) m['minQty']   = minQty;
    return m;
  }
}
