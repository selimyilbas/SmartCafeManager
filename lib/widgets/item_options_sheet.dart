import 'package:flutter/material.dart';
import '../models/menu_item.dart';

class ItemOptionResult {
  final Map<String, String> chosen;
  final String note;
  ItemOptionResult(this.chosen, this.note);
}

Future<ItemOptionResult?> showItemOptionsSheet(
    BuildContext context, MenuItem item) {
  final chosen = <String, String>{};
  final noteCtrl = TextEditingController();

  return showModalBottomSheet<ItemOptionResult>(
    context: context,
    isScrollControlled: true,
    builder: (_) => Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: StatefulBuilder(
        builder: (context, setState) => SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(item.name,
                    style:
                        const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                ...item.options.entries.map((opt) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(opt.key,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600)),
                        Wrap(
                          spacing: 8,
                          children: opt.value
                              .map(
                                (v) => ChoiceChip(
                                  label: Text(v),
                                  selected: chosen[opt.key] == v,
                                  onSelected: (_) =>
                                      setState(() => chosen[opt.key] = v),
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 10)
                      ],
                    )),
                TextField(
                  controller: noteCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Not (isteğe bağlı)'),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () =>
                      Navigator.pop(context, ItemOptionResult(chosen, noteCtrl.text)),
                  child: const Text('Sepete Ekle'),
                )
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
