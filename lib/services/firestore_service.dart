import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../models/creator.dart';
import '../models/outfit.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final _uuid = const Uuid();

  // ─── Creators ────────────────────────────────────────────────────────────

  Stream<List<Creator>> streamCreators() {
    return _db.collection('creators').orderBy('name').snapshots().map(
          (snap) => snap.docs.map(Creator.fromDoc).toList(),
        );
  }

  Future<List<Creator>> fetchCreators() async {
    final snap =
        await _db.collection('creators').orderBy('name').get();
    return snap.docs.map(Creator.fromDoc).toList();
  }

  Future<void> addCreator(Creator creator) async {
    final id = _uuid.v4();
    final newCreator = creator.copyWith(creatorId: id);
    await _db.collection('creators').doc(id).set(newCreator.toMap());
  }

  Future<void> updateCreator(Creator creator) async {
    await _db
        .collection('creators')
        .doc(creator.creatorId)
        .update(creator.toMap());
  }

  Future<void> deleteCreator(String creatorId) async {
    await _db.collection('creators').doc(creatorId).delete();
  }

  // ─── Outfits ──────────────────────────────────────────────────────────────

  Stream<List<Outfit>> streamOutfits() {
    return _db
        .collection('outfits')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Outfit.fromDoc).toList());
  }

  Future<void> addOutfit(Outfit outfit) async {
    await _db.collection('outfits').add(outfit.toMap());
  }

  Future<void> updateOutfit(Outfit outfit) async {
    final map = outfit.toMap();
    // Preserve the original createdAt on update
    map.remove('createdAt');
    await _db.collection('outfits').doc(outfit.outfitId).update(map);
  }

  Future<void> deleteOutfit(String outfitId) async {
    await _db.collection('outfits').doc(outfitId).delete();
  }
}
