// lib/screens/customer/past_orders_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import 'package:intl/intl.dart';

/// Müşterinin (customer) geçmiş siparişlerini listeleyen ekran.
class PastOrdersScreen extends StatelessWidget {
  const PastOrdersScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final orderProv = context.watch<OrderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Geçmiş Siparişler'),
      ),
      body: StreamBuilder<List<Order>>(
        stream: orderProv.userOrders,
        builder: (ctx, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!;
          if (orders.isEmpty) {
            return const Center(child: Text('Henüz geçmiş sipariş yok.'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (ctx, index) {
              final o = orders[index];
              final dateStr = DateFormat('dd.MM.yyyy – HH:mm').format(o.createdAt);

              // Siparişin toplam tutarını hesapla
              final total = o.items.fold<double>(
                0.0,
                (sum, it) => sum + it.qty * it.price,
              );

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ExpansionTile(
                  title: Text('$dateStr  •  Toplam: ${total.toStringAsFixed(2)}₺'),
                  subtitle: Text('Durum: ${o.status}'),
                  children: o.items.map((it) {
                    final optionsText = it.options.entries
                        .map((e) => '${e.key}: ${e.value}')
                        .join(', ');

                    return ListTile(
                      title: Text('${it.name}  x${it.qty}'),
                      subtitle: Text(optionsText.isEmpty ? '' : optionsText),
                      trailing: Text(
                        '${(it.price * it.qty).toStringAsFixed(2)}₺',
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
