import '../../domain/entities/kolam_entity.dart';
import '../../domain/repositories/kolam_repository.dart';
import '../datasources/kolam_remote_datasource.dart';

class KolamRepositoryImpl implements KolamRepository {
  final KolamRemoteDataSource remoteDataSource;

  KolamRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<KolamEntity>> getKolams() async {
    return await remoteDataSource.getKolams();
  }

  @override
  Future<KolamEntity> addKolam(Map<String, dynamic> payload) async {
    return await remoteDataSource.addKolam(payload);
  }

  @override
  Future<void> addRelaysBatch(int kolamId, List<String> relays) async {
    return await remoteDataSource.addRelaysBatch(kolamId, relays);
  }

  @override
  Future<void> updateKolam(int id, Map<String, dynamic> payload) async {
    return await remoteDataSource.updateKolam(id, payload);
  }

  @override
  Future<void> deleteKolam(int id) async {
    return await remoteDataSource.deleteKolam(id);
  }
}
