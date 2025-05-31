// lib/screens/manager/add_edit_menu_item_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/menu_item.dart';
import '../../providers/menu_admin_provider.dart';

class AddEditMenuItemScreen extends StatefulWidget {
  final MenuItem? menuItem;
  const AddEditMenuItemScreen({Key? key, this.menuItem}) : super(key: key);

  @override
  _AddEditMenuItemScreenState createState() => _AddEditMenuItemScreenState();
}

class _AddEditMenuItemScreenState extends State<AddEditMenuItemScreen> {
  // ─────────────────────────────────────────────────────────────────
  // Diğer alanlar için controller’lar
  late final TextEditingController _idController;
  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageUrlController;
  late final TextEditingController _stockQtyController;
  late final TextEditingController _minQtyController;

  // ─────────────────────────────────────────────────────────────────
  // Yeni form: “Options” alanı için state değişkenleri
  Map<String, List<String>> _optionsMap = {};
  final TextEditingController _newOptionCategoryController =
      TextEditingController();
  final Map<String, TextEditingController> _newOptionValueControllerMap =
      {};

  // ─────────────────────────────────────────────────────────────────
  // Kategori Dropdown
  late Category _selectedCategory;

  @override
  void initState() {
    super.initState();

    // ID / name / price / imageURL / stockQty / minQty controller’larını init et
    if (widget.menuItem != null) {
      // Düzenleme modu
      final m = widget.menuItem!;
      _idController = TextEditingController(text: m.id);
      _nameController = TextEditingController(text: m.name);
      _priceController = TextEditingController(text: m.price.toString());
      _imageUrlController = TextEditingController(text: m.imageUrl);
      _stockQtyController =
          TextEditingController(text: (m.stockQty ?? 0).toString());
      _minQtyController =
          TextEditingController(text: (m.minQty ?? 0).toString());
      _selectedCategory = m.category;

      // Mevcut options’ı set et
      try {
        _optionsMap = Map<String, List<String>>.from(m.options);
      } catch (_) {
        _optionsMap = {};
      }
      // Her kategori için bir “yeni değer ekleme” controller’ı oluştur
      for (var cat in _optionsMap.keys) {
        _newOptionValueControllerMap[cat] = TextEditingController();
      }
    } else {
      // Ekleme modu: boş controller / default değerler
      _idController = TextEditingController();
      _nameController = TextEditingController();
      _priceController = TextEditingController();
      _imageUrlController = TextEditingController();
      _stockQtyController = TextEditingController(text: '0');
      _minQtyController = TextEditingController(text: '0');
      _selectedCategory = Category.coffee;
      _optionsMap = {};
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _stockQtyController.dispose();
    _minQtyController.dispose();
    _newOptionCategoryController.dispose();
    for (var c in _newOptionValueControllerMap.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.menuItem != null;
    final prov = context.read<MenuAdminProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Ürünü Düzenle' : 'Yeni Ürün Ekle'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ────────────────────────────────────────────────────────────
              // ID alanı (doküman ID)
              TextField(
                controller: _idController,
                enabled: !isEditing,
                decoration: InputDecoration(
                  labelText: 'ID (document ID)',
                  hintText: isEditing ? 'Düzenlenemez' : 'örn: su',
                ),
              ),
              const SizedBox(height: 16),

              // ────────────────────────────────────────────────────────────
              // Ürün Adı
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Ürün Adı'),
              ),
              const SizedBox(height: 16),

              // ────────────────────────────────────────────────────────────
              // Kategori Dropdown
              DropdownButtonFormField<Category>(
                value: _selectedCategory,
                decoration: const InputDecoration(labelText: 'Kategori'),
                items: Category.values
                    .where((c) => c != Category.all)
                    .map((c) {
                  return DropdownMenuItem<Category>(
                    value: c,
                    child: Text(c.name),
                  );
                }).toList(),
                onChanged: (newCat) {
                  if (newCat != null) {
                    setState(() {
                      _selectedCategory = newCat;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // ────────────────────────────────────────────────────────────
              // Fiyat
              TextField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Fiyat (TL)'),
              ),
              const SizedBox(height: 16),

              // ────────────────────────────────────────────────────────────
              // Image URL
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'Image URL'),
              ),
              const SizedBox(height: 16),

              // ────────────────────────────────────────────────────────────
              // Stok Miktarı
              TextField(
                controller: _stockQtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Stok Miktarı'),
              ),
              const SizedBox(height: 16),

              // ────────────────────────────────────────────────────────────
              // Min Miktar (Kritik Eşik)
              TextField(
                controller: _minQtyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Min Miktar (Kritik Eşik)',
                ),
              ),
              const SizedBox(height: 16),

              // ────────────────────────────────────────────────────────────
              // “Options” Dinamik Form Başlangıcı
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Seçenekler (Options)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),

              // ────────────────────────────────────────────────────────────
              // Mevcut kategoriler varsa listeler
              for (var category in _optionsMap.keys) _buildCategorySection(category),

              const SizedBox(height: 16),

              // ────────────────────────────────────────────────────────────
              // Yeni kategori ekleme
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newOptionCategoryController,
                      decoration: const InputDecoration(
                        labelText: 'Yeni Kategori Adı',
                        hintText: 'örn: ice, size, flavor',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Kategori Ekle'),
                    onPressed: () {
                      final newCat = _newOptionCategoryController.text.trim();
                      if (newCat.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lütfen kategori adını yazın.')),
                        );
                        return;
                      }
                      if (_optionsMap.containsKey(newCat)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Bu kategori zaten var.')),
                        );
                        return;
                      }
                      setState(() {
                        _optionsMap[newCat] = <String>[];
                        _newOptionValueControllerMap[newCat] =
                            TextEditingController();
                        _newOptionCategoryController.clear();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // ────────────────────────────────────────────────────────────
              // Kaydet ve İptal Butonları
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade300,
                      foregroundColor: Colors.black,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('İptal'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      // ID boşsa hata ver
                      final idText = _idController.text.trim();
                      if (idText.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Lütfen geçerli bir ID girin.')),
                        );
                        return;
                      }

                      // Diğer alanları oku / parse et
                      final nameText = _nameController.text.trim();
                      final priceVal =
                          double.tryParse(_priceController.text.trim()) ?? 0.0;
                      final imageUrlText = _imageUrlController.text.trim();
                      final stockQtyVal =
                          int.tryParse(_stockQtyController.text.trim()) ?? 0;
                      final minQtyVal =
                          int.tryParse(_minQtyController.text.trim()) ?? 0;

                      // 3) optionsMap zaten state’te – ekstra JSON parse yok
                      final finalOptions = _optionsMap;

                      // 4) MenuItem nesnesini oluştur
                      final newItem = MenuItem(
                        id: idText,
                        name: nameText,
                        imageUrl: imageUrlText,
                        price: priceVal,
                        category: _selectedCategory,
                        stockQty: stockQtyVal,
                        minQty: minQtyVal,
                        options: finalOptions,
                      );

                      // 5) Ekle/Güncelle
                      if (isEditing) {
                        await prov.updateItem(newItem);
                      } else {
                        await prov.addItem(newItem);
                      }

                      // 6) Geri dön
                      Navigator.of(context).pop();
                    },
                    child: const Text('Kaydet'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────
  // Tek bir “kategori” için UI parçası:
  Widget _buildCategorySection(String category) {
    final values = _optionsMap[category]!;
    final valueController = _newOptionValueControllerMap[category]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kategori Başlığı + “Sil” ikonu
        Row(
          children: [
            Expanded(
              child: Text(
                category,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: () {
                setState(() {
                  _optionsMap.remove(category);
                  _newOptionValueControllerMap.remove(category);
                });
              },
              tooltip: 'Bu kategoriyi sil',
            ),
          ],
        ),
        const SizedBox(height: 4),

        // Mevcut değerler listesi
        for (var val in values)
          Row(
            children: [
              Expanded(child: Text('- $val')),
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.orange),
                onPressed: () {
                  setState(() {
                    _optionsMap[category]!.remove(val);
                  });
                },
                tooltip: '$category → $val sil',
              ),
            ],
          ),
        const SizedBox(height: 8),

        // Yeni değer ekleme
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: valueController,
                decoration: InputDecoration(
                  labelText: 'Yeni değer ekle ($category)',
                  hintText: 'örn: Buzlu, Buzsuz, …',
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.green),
              onPressed: () {
                final newVal = valueController.text.trim();
                if (newVal.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lütfen bir değer girin ($category).')),
                  );
                  return;
                }
                if (_optionsMap[category]!.contains(newVal)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Bu değer zaten var: "$newVal".')),
                  );
                  return;
                }
                setState(() {
                  _optionsMap[category]!.add(newVal);
                  valueController.clear();
                });
              },
              tooltip: '$category için ekle',
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 8),
      ],
    );
  }
}
