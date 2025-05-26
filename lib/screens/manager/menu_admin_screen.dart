import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_cafe_manager/widgets/section_card.dart';
import '../../models/menu_item.dart';
import '../../providers/menu_admin_provider.dart';

class MenuAdminScreen extends StatelessWidget {
  const MenuAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MenuAdminProvider>();

    return SectionCard(
      title: '📋 Menu – edit min stock',
      onRefresh: () async {
        // Firestore streams auto-update; we just await briefly
        await Future.delayed(const Duration(milliseconds: 100));
      },
      child: StreamBuilder<List<MenuItem>>(
        stream: prov.streamMenu(),
        builder: (ctx, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator());
          final items = snap.data!;
          return ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final it = items[i];
              final ctrl = TextEditingController(
                text: (it.minQty ?? 0).toString(),
              );
              return ListTile(
                title: Text('${it.name} (${it.price.toStringAsFixed(0)}₺)'),
                subtitle: Text('Stock: ${it.stockQty ?? 0} · Min: ${it.minQty ?? 0}'),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final newMin = await showDialog<int>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Set minimum stock'),
                        content: TextField(
                          controller: ctrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Min stock qty'),
                        ),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, int.tryParse(ctrl.text)),
                              child: const Text('Save')),
                        ],
                      ),
                    );
                    if (newMin != null) await prov.setMin(it.id, newMin);
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
