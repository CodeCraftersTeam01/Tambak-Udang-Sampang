import '../entities/kolam_entity.dart';

abstract class KolamRepository {
  Future<List<KolamEntity>> getKolams();
}
