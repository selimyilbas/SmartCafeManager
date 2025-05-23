import 'package:flutter/material.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/call_service.dart';

class CallProvider extends ChangeNotifier {
  final _srv = CallService();
  StreamSubscription? _sub;

  /// shift_provider çağırır
  void startListening(BuildContext ctx) {
    _sub ??= _srv.streamActiveCalls().listen((snap) {
      for (final doc in snap.docChanges) {
        if (doc.type == DocumentChangeType.added) {
          final d = doc.doc.data()!;
          final table = d['tableId'];
          ScaffoldMessenger.of(ctx).showSnackBar(
            SnackBar(
              content: Text('Masa $table sizi çağırıyor!'),
              action: SnackBarAction(
                label: 'Tamam',
                onPressed: () => _srv.markHandled(doc.doc.id),
              ),
            ),
          );
        }
      }
    });
  }

  void stopListening() {
    _sub?.cancel();
    _sub = null;
  }
}
