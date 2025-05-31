// lib/models/order_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Siparişteki bir öğeyi temsil eden model.
/// Firestore’daki 'items' alanından gelmesi beklenen map’e karşılık gelir.
class OrderItem {
  final String itemId;
  final String name;
  final int qty;
  final double price;
  final Map<String, dynamic> options;
  final String? note;

  OrderItem({
    required this.itemId,
    required this.name,
    required this.qty,
    required this.price,
    required this.options,
    this.note,
  });

  /// Firestore’dan gelen her bir öğe map’ini OrderItem modeline dönüştürür.
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      itemId: map['itemId'] as String,
      name: map['name'] as String,
      qty: (map['qty'] as num).toInt(),
      price: (map['price'] as num).toDouble(),
      options: Map<String, dynamic>.from(map['options'] as Map),
      note: map['note'] as String?,
    );
  }
}

/// "orders" koleksiyonundaki bir dökümanı temsil eden model.
/// Siparişin detaylarını (masa, kullanıcı, durum, oluşma tarihi, öğeler vb.) taşır.
class Order {
  final String id;
  final String tableId;
  final String sessionId;
  final String ownerUid;
  final String status;
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    required this.tableId,
    required this.sessionId,
    required this.ownerUid,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  /// Firestore DocumentSnapshot'tan Order nesnesi oluşturur.
  factory Order.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    // createdAt timestamp’ını DateTime’a çeviriyoruz
    final ts = d['createdAt'] as Timestamp?;
    final created = ts != null ? ts.toDate() : DateTime.now();

    // 'items' alanı bir List<dynamic> olarak geldiği için önce List<Map>’e dönüştürüp parse edeceğiz
    final rawItems = d['items'] as List<dynamic>? ?? [];
    final items = rawItems
        .map((e) => OrderItem.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList();

    return Order(
      id: doc.id,
      tableId: d['tableId'] as String,
      sessionId: d['sessionId'] as String,
      ownerUid: d['ownerUid'] as String,
      status: d['status'] as String,
      createdAt: created,
      items: items,
    );
  }
}
