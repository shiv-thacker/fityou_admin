import '../entities/creator_entity.dart';

/// Creators repository contract — domain layer only.
abstract interface class CreatorsRepository {
  Stream<List<CreatorEntity>> streamCreators();
  Future<List<CreatorEntity>> fetchCreators();
  Future<void> addCreator(CreatorEntity creator);
  Future<void> updateCreator(CreatorEntity creator);
  Future<void> deleteCreator(String creatorId);
}
