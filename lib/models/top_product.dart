// lib/models/top_product.dart

import 'package:flutter/foundation.dart';

/// Bir ürün için “ürün adı” ve “satılan adet” bilgisini tutar.
class TopProduct {
  final String productName;
  final int quantitySold;

  TopProduct({
    required this.productName,
    required this.quantitySold,
  });
}
