import '../entities/outfit_entity.dart';

/// Outfits repository contract — domain layer only.
abstract interface class OutfitsRepository {
  Stream<List<OutfitEntity>> streamOutfits();
  Future<void> addOutfit(OutfitEntity outfit);
  Future<void> updateOutfit(OutfitEntity outfit);
  Future<void> deleteOutfit(String outfitId);
}
