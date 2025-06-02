// lib/screens/employee/kitchen_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../providers/kitchen_provider.dart';

class KitchenScreen extends StatelessWidget {
  const KitchenScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // TabBar’ı ve TabBarView’i aynı hizada tutmak için Column kullanıyoruz.
    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          // 1) TabBar: “EmployeeHome”’ın AppBar’ından hemen sonra gözükür.
          const Material(
            color: Colors.white, // veya tercihinize göre renk
            child: TabBar(
              labelColor: Colors.purple,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.purple,
              tabs: [
                Tab(text: 'Pending'),
                Tab(text: 'Preparing'),
                Tab(text: 'Ready'),
              ],
            ),
          ),

          // 2) TabBarView: Her tab için _OrderList gönderiyoruz
          const Expanded(
            child: TabBarView(
              children: [
                _OrderList(status: 'pending'),
                _OrderList(status: 'preparing'),
                _OrderList(status: 'ready'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*────────────────────────  Ortak liste bileşeni  ────────────────────────*/
class _OrderList extends StatelessWidget {
  const _OrderList({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<KitchenProvider>();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: prov.stream(status),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final docs = snap.data!.docs;
        if (docs.isEmpty) {
          return const Center(child: Text('Boş'));
        }

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 12),
          itemCount: docs.length,
          itemBuilder: (_, i) {
            final d = docs[i].data();
            final oid = docs[i].id;
            final items = (d['items'] ?? []) as List<dynamic>;
            final tableId = d['tableId'] ?? '—';

            final created =
                (d['createdAt'] as Timestamp).toDate(); // Sarı çizgi olmaz
            final fmtTime = DateFormat.Hm().format(created);

            // Mutfakta “Ready” olduktan sonra Timer’ın durması için:
            // Eğer status 'ready' ise, kullanılan süreyi “readyAt” üzerinden hesaplayacağız.
            final minutes = (() {
              if (status == 'ready') {
                final readyTs = d['readyAt'] as Timestamp?;
                if (readyTs != null) {
                  final readyDate = readyTs.toDate();
                  return readyDate
                      .difference((d['createdAt'] as Timestamp).toDate())
                      .inMinutes;
                }
              }
              // Aksi takdirde normal “await süresi” (pending veya preparing tab’ı için):
              return DateTime.now().difference(created).inMinutes;
            })();

            final ageColor = minutes > 15
                ? Colors.red
                : minutes > 5
                    ? Colors.orange
                    : Colors.grey;

            final totalQty =
                items.fold<int>(0, (p, e) => p + (e['qty'] as int));
            final title = '$totalQty ürün • Masa: $tableId';

            final subtitle = items.map((e) {
              final q = e['qty'];
              final nm = e['name'];
              final opt = (e['options'] ?? {}) as Map;
              final optsText =
                  opt.entries.map((e) => '${e.key}:${e.value}').join(', ');
              final note = (e['note'] ?? '').toString().trim();
              final noteTxt = note.isNotEmpty ? '\n    Not: $note' : '';
              return '• $q × $nm'
                  '${optsText.isNotEmpty ? '  ($optsText)' : ''}'
                  '$noteTxt';
            }).join('\n');

            return Card(
              margin:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /*  SOL: içerik  */
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text(subtitle,
                              style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                    ),

                    /*  SAĞ: saat + buton  */
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(fmtTime,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        Text('+$minutes dk',
                            style:
                                TextStyle(color: ageColor, fontSize: 12)),
                        const SizedBox(height: 6),
                        _actionButton(context, prov, status, oid),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /*────────────────────────  Duruma göre aksiyon  ────────────────────────*/
  Widget _actionButton(
      BuildContext ctx, KitchenProvider p, String st, String oid) {
    switch (st) {
      case 'pending':
        return IconButton(
          icon: const Icon(Icons.play_arrow),
          tooltip: 'Preparing',
          onPressed: () => p.setPreparing(oid),
        );
      case 'preparing':
        return IconButton(
          icon: const Icon(Icons.check),
          tooltip: 'Ready',
          onPressed: () => p.setReady(oid),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
