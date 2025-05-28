import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/table_provider.dart';
import '../services/order_service.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProv = context.watch<CartProvider>();
    final tableProv = context.watch<TableProvider>();
    final orderSrv = OrderService();

    Future<void> _sendOrder() async {
      if (tableProv.tableId == null || tableProv.sessionId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Önce masaya oturun')),
        );
        return;
      }
      if (cartProv.items.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sepet boş')),
        );
        return;
      }
      try {
        await orderSrv.createOrder(context, cartProv.items);
        cartProv.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sipariş gönderildi ✅')),
        );
        Navigator.of(context).pop();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sipariş gönderilemedi: $e')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sepet'),
        leading: BackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: Column(
        children: [
          // 1) Sepet öğeleri
          Expanded(
            child: cartProv.items.isEmpty
                ? const Center(child: Text('Sepetiniz boş'))
                : ListView.separated(
                    padding: const EdgeInsets.only(top: 8),
                    itemCount: cartProv.items.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final entry = cartProv.items[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.shade100,
                          child: Text(
                            entry.qty.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(entry.item.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (entry.chosen.isNotEmpty)
                              Text(entry.chosen.entries
                                  .map((e) => '${e.key}: ${e.value}')
                                  .join(', ')),
                            if (entry.note.isNotEmpty)
                              Text('Not: ${entry.note}',
                                  style: const TextStyle(fontStyle: FontStyle.italic)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => cartProv.remove(entry),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => cartProv.dec(entry),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () => cartProv.inc(entry),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // 2) Toplam ve sipariş gönder butonu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Toplam: ₺${cartProv.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _sendOrder,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24)),
                  ),
                  child: const Text('Siparişi Gönder'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
