import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartProv = context.watch<CartProvider>();
    final items   = cartProv.items;

    return Scaffold(
      appBar: AppBar(title: const Text('Sepet')),
      body: Column(
        children: [
          // 1) Sepet Listesi
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('Sepet boş'))
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount: items.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1),
                    itemBuilder: (_, i) {
                      final e    = items[i];
                      final cost = e.item.price * e.qty;
                      final opts = e.chosen.entries
                          .map((o) => '${o.key}: ${o.value}')
                          .join(', ');
                      final subtitle = [
                        if (opts.isNotEmpty) opts,
                        if (e.note.trim().isNotEmpty) 'Not: ${e.note}',
                      ].join(' • ');

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text('${e.qty}'),
                        ),
                        title: Text(e.item.name),
                        subtitle: subtitle.isNotEmpty
                            ? Text(subtitle)
                            : null,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Sil butonu
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () =>
                                  cartProv.remove(e),
                            ),
                            // Adet azalt
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () =>
                                  cartProv.changeQty(e, -1),
                            ),
                            Text('${e.qty}',
                                style: const TextStyle(fontSize: 16)),
                            // Adet artır
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () =>
                                  cartProv.changeQty(e, 1),
                            ),
                          ],
                        ),
                        // İstersen alt satırda toplam maliyeti de gösterebilirsin:
                        // subtitle: Text('Toplam: ₺$cost'),
                      );
                    },
                  ),
          ),

          // 2) Alt Toplam ve Gönder Butonu
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Toplam: ₺${cartProv.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: items.isNotEmpty
                      ? () {
                          // TODO: Sipariş gönderme işlemini burada başlat
                        }
                      : null,
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
