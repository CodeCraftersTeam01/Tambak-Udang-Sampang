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
}
