enum Category { all, coffee, tea, dessert, sandwich, drink }

Category categoryFromString(String s) =>
    Category.values.firstWhere((e) => e.name == s, orElse: () => Category.all);

class MenuItem {
  final String id, name, imageUrl;
  final double price;
  final Category category;
  final int? stockQty; // null = sınırsız / barista
  final Map<String, List<String>> options;

  MenuItem({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.category,
    required this.options,
    this.stockQty,
  });

  bool get inStock => stockQty == null || stockQty! > 0;

  factory MenuItem.fromDoc(Map<String, dynamic> d, String id) => MenuItem(
        id: id,
        name: d['name'],
        imageUrl: d['imageUrl'] ?? '',
        price: (d['price'] as num).toDouble(),
        category: categoryFromString(d['category']),
        stockQty: d.containsKey('stockQty') ? d['stockQty'] : null,
        options: (d['options'] as Map<String, dynamic>?)
                ?.map((k, v) => MapEntry(k, List<String>.from(v))) ??
            {},
      );
}
