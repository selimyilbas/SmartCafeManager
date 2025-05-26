import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_cafe_manager/widgets/section_card.dart';
import '../../providers/stock_admin_provider.dart';

class StockAlertScreen extends StatelessWidget {
  const StockAlertScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<StockAdminProvider>();

    return SectionCard(
      title: '⚠️ Critical stock',
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 100));
      },
      child: StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
        stream: prov.critical(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final docs = snap.data!;
          if (docs.isEmpty) {
            return const Center(child: Text('All items are above minimum.'));
          }
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final d = docs[i].data();
              return ListTile(
                title: Text(d['name'] as String),
                subtitle: Text('Stock: ${d['stockQty']} · Min: ${d['minQty']}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // you can add “edit min” here if you like
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
