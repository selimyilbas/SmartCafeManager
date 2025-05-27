import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';        // ← EKLENDİ
import '../../providers/stock_provider.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<StockProvider>();

    Future<void> _showAdjustDialog(String id) async {
      final ctrl = TextEditingController();
      final delta = await showDialog<int>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Stok güncelle'),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Artış (+) ya da azalış (–)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () {
                final v = int.tryParse(ctrl.text.trim());
                Navigator.pop(ctx, v);
              },
              child: const Text('Uygula'),
            ),
          ],
        ),
      );
      if (delta != null && delta != 0) await prov.adjust(id, delta);
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: prov.inventory$,   // güncel stream adı
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data!.docs;
        if (docs.isEmpty) return const Center(child: Text('Envanter boş'));

        return ListView.separated(
          padding: const EdgeInsets.only(bottom: 12),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (_, i) {
            final d    = docs[i].data();
            final id   = docs[i].id;
            final name = (d['name'] as String?) ?? id;
            final qty  = (d['stockQty'] ?? 0) as int;

            return ListTile(
              title: Text(name),
              leading: GestureDetector(
                onLongPress: () => _showAdjustDialog(id),
                child: CircleAvatar(
                  backgroundColor: qty == 0
                      ? Colors.red.shade200
                      : Colors.green.shade100,
                  child: Text(
                    qty.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => prov.dec(id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => prov.inc(id),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
