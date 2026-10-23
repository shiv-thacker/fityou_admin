import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/outfit_model.dart';

/// Raw Firestore calls for the outfits collection.
class OutfitsDatasource {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<OutfitModel>> streamOutfits() {
    return _db
        .collection('outfits')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(OutfitModel.fromDoc).toList());
  }

  Future<DocumentReference> addOutfit(Map<String, dynamic> data) =>
      _db.collection('outfits').add(data);

  Future<void> updateOutfit(String id, Map<String, dynamic> data) =>
      _db.collection('outfits').doc(id).update(data);

  Future<void> deleteOutfit(String id) =>
      _db.collection('outfits').doc(id).delete();
}
