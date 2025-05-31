import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item.dart';
import '../../providers/menu_admin_provider.dart';
import 'add_edit_menu_item_screen.dart';

class MenuAdminScreen extends StatelessWidget {
  const MenuAdminScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<MenuAdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('[Manager] 📋 Menu – Yönetici Paneli'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            // Firestore stream zaten otomatik günceller; ufak bir gecikme kafi
            await Future.delayed(const Duration(milliseconds: 100));
          },
          child: StreamBuilder<List<MenuItem>>(
            stream: prov.streamMenu(),
            builder: (ctx, snap) {
              if (snap.hasError) {
                return Center(child: Text('Hata: ${snap.error}'));
              }
              if (!snap.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snap.data!;
              if (items.isEmpty) {
                return const Center(child: Text('Henüz ürün eklenmemiş.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                // altta FAB olduğu için alt padding ekledik
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
                    leading: it.inStock
                        ? const Icon(Icons.local_fire_department, color: Colors.orange)
                        : const Icon(Icons.local_fire_department, color: Colors.grey),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            // Düzenleme moduna geç → ilgili MenuItem objesini parametre olarak geçir
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => AddEditMenuItemScreen(
                                  menuItem: it,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Silme Onayı'),
                                content: Text('${it.name} silinsin mi?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text('Vazgeç'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text('Sil'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await prov.deleteItem(it.id);
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Yeni ürün ekleme moduna geç (null parametre → ekleme modu)
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditMenuItemScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
