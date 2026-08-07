import '../../domain/entities/relay_entity.dart';

class RelayModel extends RelayEntity {
  const RelayModel({
    required super.id,
    required super.kolamId,
    required super.namaRelay,
  });

  factory RelayModel.fromJson(Map<String, dynamic> json) {
    return RelayModel(
      id: json['id'] ?? 0,
      kolamId: json['kolam_id'] ?? 0,
      namaRelay: json['nama_relay'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'kolam_id': kolamId,
      'nama_relay': namaRelay,
    };
  }
}
