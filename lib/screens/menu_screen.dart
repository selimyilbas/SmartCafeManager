// lib/screens/menu_screen.dart
import 'package:flutter/material.dart' hide Badge;
import 'package:provider/provider.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:badges/badges.dart' as badges;

import '../models/menu_item.dart';
import '../services/menu_service.dart';
import '../providers/cart_provider.dart';
import '../widgets/item_options_sheet.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  Category selected = Category.all;
  String query = '';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MenuItem>>(
      stream: MenuService().menuStream(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        var items = snap.data!;
        if (selected != Category.all) {
          items = items.where((e) => e.category == selected).toList();
        }
        if (query.isNotEmpty) {
          items = items
              .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
              .toList();
        }
        items.sort((a, b) => a.name.compareTo(b.name));

        return Scaffold(
          appBar: AppBar(
            title: const Text('Menu'),
            leading: const BackButton(),
            actions: [
              Consumer<CartProvider>(
                builder: (_, cart, __) => IconButton(
                  icon: badges.Badge(
                    badgeContent: Text(
                      '${cart.items.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    position: badges.BadgePosition.topEnd(top: -4, end: -4),
                    child: const Icon(Icons.shopping_bag),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/cart'),
                ),
              ),
            ],
          ),
          body: Column(
            children: [
              // 🟢 Kategori Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Wrap(
                  spacing: 8,
                  children: Category.values
                      .map((c) => ChoiceChip(
                            label: Text(c.name),
                            selected: selected == c,
                            onSelected: (_) => setState(() => selected = c),
                          ))
                      .toList(),
                ),
              ),
              // 🔍 Arama
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Search…',
                  ),
                  onChanged: (v) => setState(() => query = v),
                ),
              ),
              const Divider(),
              // 📋 Ürün Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: .78,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: items.length,
                  itemBuilder: (_, i) {
                    final item = items[i];
                    return InkWell(
                      onTap: () async {
                        final res =
                            await showItemOptionsSheet(context, item);
                        if (res != null && context.mounted) {
                          // 1) Sepete ekle
                          context
                              .read<CartProvider>()
                              .add(item, res.chosen, res.note);

                          // 2) Önceki Flushbar varsa kapat
                          // (Flushbar otomatik kendini kapatır, SnackBar değil)
                          
                          // 3) Yeni Flushbar’ı üstte göster
                          final topPadding =
                              MediaQuery.of(context).padding.top +
                                  kToolbarHeight +
                                  8;
                          Flushbar(
                            message: '${item.name} eklendi',
                            margin: EdgeInsets.fromLTRB(
                                16, topPadding, 16, 0),
                            borderRadius: BorderRadius.circular(8),
                            flushbarPosition: FlushbarPosition.TOP,
                            duration: const Duration(seconds: 2),
                          ).show(context);
                        }
                      },
                      child: Card(
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 48,
                              backgroundImage:
                                  item.imageUrl.isEmpty
                                      ? null
                                      : NetworkImage(item.imageUrl),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              child: item.imageUrl.isEmpty
                                  ? const Icon(Icons.local_cafe,
                                      size: 40)
                                  : null,
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8),
                              child: Text(
                                item.name,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.price.toStringAsFixed(0)} ₺',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                            if (!item.inStock)
                              const Text(
                                'Stok Yok',
                                style: TextStyle(color: Colors.red),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
