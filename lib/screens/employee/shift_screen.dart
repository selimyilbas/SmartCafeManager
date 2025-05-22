import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/shift_provider.dart';

class ShiftScreen extends StatelessWidget {
  const ShiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shift = context.watch<ShiftProvider>();
    return Center(
      child: shift.activeShiftId == null
          ? ElevatedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Mesaie Başla'),
              onPressed: () => shift.clockIn(),
            )
          : ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Mesaie Bitir'),
              onPressed: () => shift.clockOut(),
            ),
    );
  }
}
