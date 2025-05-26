// lib/widgets/section_card.dart

import 'package:flutter/material.dart';

/// A card with a header (title + refresh button) and a scrollable body.
/// Capped at 60% of screen height so that very long lists inside it
/// scroll internally rather than overflow the column.
class SectionCard extends StatelessWidget {
  final String title;
  final Future<void> Function() onRefresh;
  final Widget child;

  const SectionCard({
    Key? key,
    required this.title,
    required this.onRefresh,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // maximum height = 60% of viewport
    final maxHeight = MediaQuery.of(context).size.height * 0.6;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row: title + refresh icon
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () => onRefresh(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // The scrollable body, capped in height
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  child: child,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
