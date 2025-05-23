import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/shift_provider.dart';

class ShiftScreen extends StatelessWidget {
  const ShiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final shift = context.watch<ShiftProvider>();

    /*──────────  Mesai bitirirken onay diyaloğu  ──────────*/
    Future<void> _endShift() async {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Mesaiyi bitir'),
          content: const Text(
              'Mesainizi sonlandırmak istediğinize emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('İptal'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Evet'),
            ),
          ],
        ),
      );

      if (ok == true) shift.clockOut();
    }

    /*──────────  Ekran  ──────────*/
    return Center(
      child: shift.activeShiftId == null
          ? FilledButton.icon(
              icon: const Icon(Icons.login),
              label: const Text('Mesaiye Başla'),
              onPressed: shift.clockIn,
            )
          : FilledButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Mesaiyi Bitir'),
              onPressed: _endShift,
            ),
    );
  }
}
