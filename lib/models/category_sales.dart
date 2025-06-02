// lib/models/category_sales.dart

import 'package:flutter/foundation.dart';

/// Her kategori için toplam ciro (veya satış adedi) bilgisini tutar.
class CategorySales {
  final String category; 
  final double totalAmount;

  CategorySales({
    required this.category,
    required this.totalAmount,
  });
}
