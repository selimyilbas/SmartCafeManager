import 'package:flutter/material.dart';

class ShiftHistoryScreen extends StatelessWidget {
  final String uid;
  final String name;
  const ShiftHistoryScreen({
    super.key,
    required this.uid,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$name\'s Shifts')),
      body: const Center(child: Text('Implement shift history here')),
    );
  }
}
