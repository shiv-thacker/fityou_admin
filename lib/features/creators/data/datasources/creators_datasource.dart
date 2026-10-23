import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/creator_model.dart';

/// Raw Firestore calls for the creators collection.
class CreatorsDatasource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<CreatorModel>> streamCreators() {
    return _db
        .collection('creators')
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs.map(CreatorModel.fromDoc).toList());
  }

  Future<List<CreatorModel>> fetchCreators() async {
    final snap =
        await _db.collection('creators').orderBy('name').get();
    return snap.docs.map(CreatorModel.fromDoc).toList();
  }

  Future<void> setCreator(String id, Map<String, dynamic> data) =>
      _db.collection('creators').doc(id).set(data);

  Future<void> updateCreator(String id, Map<String, dynamic> data) =>
      _db.collection('creators').doc(id).update(data);

  Future<void> deleteCreator(String id) =>
      _db.collection('creators').doc(id).delete();
}
