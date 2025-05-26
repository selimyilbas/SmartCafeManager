import 'package:cloud_firestore/cloud_firestore.dart';

class DiscountService {
  final _menu = FirebaseFirestore.instance.collection('menu');

  Future<void> setDiscount(String itemId,
      {required num percent, required Timestamp start, required Timestamp end}) {
    return _menu.doc(itemId).update({
      'discount': {
        'percent': percent,
        'start': start,
        'end': end,
      }
    });
  }

  Future<void> clearDiscount(String itemId) =>
      _menu.doc(itemId).update({'discount': FieldValue.delete()});
}
