import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/table_provider.dart';
import '../../services/order_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PayScreen extends StatelessWidget {
  const PayScreen({super.key});

  /// Sipariş satırlarından toplam hesapla
  num _sum(Iterable<QueryDocumentSnapshot<Map<String, dynamic>>> docs) =>
      docs.fold<num>(0, (p, d) {
        final items = (d.data()['items'] as List);
        return p +
            items.fold<num>(0, (pp, it) {
              final q  = (it['qty']   as num?) ?? 0;
              final pr = (it['price'] as num?) ?? 0;
              return pp + q * pr;
            });
      });

  @override
  Widget build(BuildContext context) {
    final tableProv = context.watch<TableProvider>();
    final tableId   = tableProv.tableId;
    final sessionId = tableProv.sessionId;
    final orderSrv  = OrderService();

    return Scaffold(
      appBar: AppBar(title: const Text('Ödeme')),
      body: StreamBuilder(
        stream: orderSrv.streamActiveOrders(tableId!, sessionId!), // null olamaz
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snap.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text('Ödenmemiş sipariş yok'));
          }

          /*------------------------------------------------------  Gruplar */
          final myUid   = orderSrv.uid;
          final myDocs  = docs.where((d) => d.data()['ownerUid'] == myUid);
          final allCost = _sum(docs);
          final myCost  = _sum(myDocs);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /* Kişisel hesap ------------------------------------------------*/
                ListTile(
                  title   : const Text('Kişisel hesabım'),
                  subtitle: Text('Tutar: ₺${myCost.toStringAsFixed(2)}'),
                  trailing: FilledButton(
                    child: const Text('Öde'),
                    onPressed: myDocs.isEmpty
                        ? null
                        : () async {
                            for (final d in myDocs) {
                              await orderSrv.markPaid(d.id);
                            }
                            Navigator.pop(context);
                          },
                  ),
                ),
                const Divider(height: 32),

                /* Tüm masa -----------------------------------------------------*/
                ListTile(
                  title   : const Text('Masadaki herkes'),
                  subtitle: Text('Toplam: ₺${allCost.toStringAsFixed(2)}'),
                  trailing: FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: Colors.green.shade700),
                    child: const Text('Hepsini Öde'),
                    onPressed: () async {
                      for (final d in docs) {
                        await orderSrv.markPaid(d.id);
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
                const SizedBox(height: 12),

                /* Açıklama -----------------------------------------------------*/
                Text(
                  'Ödeme butonuna bastığınızda garson bilgilendirilecek.',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade600),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
