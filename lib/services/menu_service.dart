import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item.dart';

class MenuService {
  final _db = FirebaseFirestore.instance;

  Stream<List<MenuItem>> menuStream() => _db
      .collection('menu')
      .snapshots()
      .map((snap) => snap.docs.map((doc) => MenuItem.fromDoc(doc)).toList());
}
