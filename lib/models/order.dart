// lib/models/order.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// 1. Adım: Siparişteki her bir satırı temsil eden OrderItem model’i
class OrderItem {
  final String itemId;    // Menüdeki ürünün document ID’si
  final String name;      // Ürün adı (SQL’i azaltmak için kopyalanabilir)
  final double price;     // Ürün fiyatı (adet başı fiyat)
  final int quantity;     // Kaç adet sipariş edilmiş

  OrderItem({
    required this.itemId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  /// Firestore’a yazarken JSON formatına çevirmek için
  Map<String, dynamic> toJson() => {
        'itemId': itemId,
        'name': name,
        'price': price,
        'quantity': quantity,
      };

  /// Firestore’dan okunan JSON’dan obje yaratmak için
  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        itemId: json['itemId'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        quantity: (json['quantity'] as num).toInt(),
      );
}

/// 2. Adım: Kullanıcının bir siparişini temsil eden Order model’i
class Order {
  final String id;              // Firestore’un oto-üreteceği document ID
  final String ownerUid;        // Siparişi veren kullanıcı UID’si
  final String tableId;         // Müşterinin oturduğu masa ID’si (örnek: "T12")
  final List<OrderItem> items;  // Bu siparişteki kalemler (ürünler)
  final Timestamp createdAt;    // Siparişin kayıt edildiği tarih/saat
  final String status;          // (isteğe bağlı) örn: "pending", "completed"

  Order({
    required this.id,
    required this.ownerUid,
    required this.tableId,
    required this.items,
    required this.createdAt,
    required this.status,
  });

  /// Firestore’a yazarken JSON formatına çevirmek için
  Map<String, dynamic> toJson() {
    return {
      'ownerUid': ownerUid,
      'tableId': tableId,
      'items': items.map((e) => e.toJson()).toList(),
      'createdAt': createdAt,
      'status': status,
    };
  }

  /// Firestore’dan okunan DocumentSnapshot’tan Order nesnesi oluşturur
  factory Order.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return Order(
      id: doc.id,
      ownerUid: d['ownerUid'] as String,
      tableId: d['tableId'] as String,
      items: (d['items'] as List<dynamic>)
          .map((e) =>
              OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: d['createdAt'] as Timestamp,
      status: (d['status'] as String?) ?? 'pending',
    );
  }
}
