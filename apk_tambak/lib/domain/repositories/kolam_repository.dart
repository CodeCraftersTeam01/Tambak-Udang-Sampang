import '../entities/kolam_entity.dart';

abstract class KolamRepository {
  Future<List<KolamEntity>> getKolams();
  Future<KolamEntity> addKolam(Map<String, dynamic> payload);
  Future<void> updateKolam(int id, Map<String, dynamic> payload);
  Future<void> deleteKolam(int id);
  Future<void> addRelaysBatch(int kolamId, List<String> relays);
}
