import 'package:uuid/uuid.dart';

import '../../domain/entities/creator_entity.dart';
import '../../domain/repositories/creators_repository.dart';
import '../datasources/creators_datasource.dart';
import '../models/creator_model.dart';

class CreatorsRepositoryImpl implements CreatorsRepository {
  final CreatorsDatasource _ds;
  final _uuid = const Uuid();

  CreatorsRepositoryImpl(this._ds);

  @override
  Stream<List<CreatorEntity>> streamCreators() =>
      _ds.streamCreators().map((models) => List<CreatorEntity>.from(models));

  @override
  Future<List<CreatorEntity>> fetchCreators() async {
    final models = await _ds.fetchCreators();
    return List<CreatorEntity>.from(models);
  }

  @override
  Future<void> addCreator(CreatorEntity creator) {
    final id    = _uuid.v4();
    final model = CreatorModel.fromEntity(creator.copyWith(creatorId: id));
    return _ds.setCreator(id, model.toMap());
  }

  @override
  Future<void> updateCreator(CreatorEntity creator) {
    final model = CreatorModel.fromEntity(creator);
    return _ds.updateCreator(creator.creatorId, model.toMap());
  }

  @override
  Future<void> deleteCreator(String creatorId) =>
      _ds.deleteCreator(creatorId);
}
