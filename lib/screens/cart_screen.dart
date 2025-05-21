import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/table_provider.dart'; // 🆕 table kontrolü için
import '../services/order_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Sepet')),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? const Center(child: Text('Sepet boş'))
                : ListView.separated(
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (_, i) {
                      final entry = cart.items[i];
                      return ListTile(
                        title: Text(entry.item.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (entry.chosen.isNotEmpty)
                              Text(entry.chosen.entries
                                  .map((e) => '${e.key}: ${e.value}')
                                  .join(', ')),
                            if (entry.note.isNotEmpty)
                              Text('Not: ${entry.note}'),
                          ],
                        ),
                        trailing: Text('x${entry.qty}'),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Toplam: ${cart.total.toStringAsFixed(0)} ₺',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: cart.items.isEmpty
                        ? null
                        : () async {
                            final tableId = context.read<TableProvider>().tableId;
                            if (tableId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Sipariş vermeden önce masaya oturun')),
                              );
                              return;
                            }

                            await OrderService().createOrder(context, cart.items);
                            cart.clear();
                            if (context.mounted) Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Sipariş oluşturuldu 👍')),
                            );
                          },
                    child: const Text('Siparişi Gönder'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
