// lib/providers/order_provider.dart

import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import 'cart_provider.dart'; // CartEntry için gerek

/// OrderProvider:
///  • Oturum açmış kullanıcının geçmiş siparişlerini getirir (userOrders).
///  • Sepet bilgilerini kullanarak yeni sipariş oluşturabilir (placeOrder).
class OrderProvider extends ChangeNotifier {
  final OrderService _svc = OrderService();

  /// OwnerUid == şu anki kullanıcı UID’sine ait tüm siparişleri List<Order> olarak dönen stream
  Stream<List<Order>> get userOrders {
    return _svc.streamUserOrders().map(
      (snapshot) => snapshot.docs
          .map((doc) => Order.fromDoc(doc))
          .toList(),
    );
  }

  /// Sepetten gelen listeyi alıp Firestore’a yeni sipariş yazar.
  Future<void> placeOrder(
      BuildContext ctx,
      List<CartEntry> entries,
  ) async {
    await _svc.createOrder(ctx, entries);
  }
}
