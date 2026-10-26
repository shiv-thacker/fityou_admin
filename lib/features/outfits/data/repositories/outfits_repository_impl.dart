import '../../domain/entities/outfit_entity.dart';
import '../../domain/repositories/outfits_repository.dart';
import '../datasources/outfits_datasource.dart';
import '../models/outfit_model.dart';

class OutfitsRepositoryImpl implements OutfitsRepository {
  final OutfitsDatasource _ds;

  OutfitsRepositoryImpl(this._ds);

  @override
  Stream<List<OutfitEntity>> streamOutfits() =>
      _ds.streamOutfits().map((models) => List<OutfitEntity>.from(models));

  @override
  Future<void> addOutfit(OutfitEntity outfit) {
    final model = OutfitModel.fromEntity(outfit);
    return _ds.addOutfit(model.toMap());
  }

  @override
  Future<void> updateOutfit(OutfitEntity outfit) {
    final model = OutfitModel.fromEntity(outfit);
    return _ds.updateOutfit(outfit.outfitId, model.toUpdateMap());
  }

  @override
  Future<void> deleteOutfit(String outfitId) =>
      _ds.deleteOutfit(outfitId);
}
