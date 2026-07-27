import '../../domain/entities/kolam_entity.dart';
import 'relay_model.dart';

class KolamModel extends KolamEntity {
  const KolamModel({
    required super.id,
    required super.pemilik,
    required super.nama,
    super.mqttId,
    required super.lat,
    required super.long,
    required super.status,
    required super.statusLabel,
    required super.luas,
    required super.targetPanen,
    required super.detailUdang,
    required super.relays,
  });

  factory KolamModel.fromJson(Map<String, dynamic> json) {
    return KolamModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      pemilik: json['pemilik'] is int ? json['pemilik'] : int.tryParse(json['pemilik']?.toString() ?? '0') ?? 0,
      nama: json['nama_kolam']?.toString() ?? json['nama']?.toString() ?? '',
      mqttId: json['mqtt_id']?.toString(),
      lat: json['lat']?.toString() ?? '',
      long: json['long']?.toString() ?? '',
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      statusLabel: json['status_label']?.toString() ?? 'Tidak Diketahui',
      luas: json['luas_kolam'] != null ? double.tryParse(json['luas_kolam'].toString()) ?? 0.0 : (json['luas'] != null ? double.tryParse(json['luas'].toString()) ?? 0.0 : 0.0),
      targetPanen: json['target_panen_kg'] != null ? double.tryParse(json['target_panen_kg'].toString()) ?? 0.0 : (json['target_panen'] != null ? double.tryParse(json['target_panen'].toString()) ?? 0.0 : 0.0),
      detailUdang: json['detail_udang']?.toString() ?? '',
      relays: json['relays'] != null 
          ? (json['relays'] as List).map((i) => RelayModel.fromJson(i)).toList() 
          : const [],
    );
  }
}
