import 'package:cloud_firestore/cloud_firestore.dart';

class CrudService {
  final CollectionReference items =
      FirebaseFirestore.instance.collection('items');

  Future<void> addItem(String name, int quantity) {
    return items.add({
      'name': name,
      'quantity': quantity,
      'isFavorite': false, // new field for the Favorites filter
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> getItems() =>
      items.orderBy('createdAt').snapshots();

  Future<void> updateItem(String id, String name, int quantity) {
    return items.doc(id).update({'name': name, 'quantity': quantity});
  }

  Future<void> toggleFavorite(String id, bool value) {
    return items.doc(id).update({'isFavorite': value});
  }

  Future<void> deleteItem(String id) => items.doc(id).delete();
}