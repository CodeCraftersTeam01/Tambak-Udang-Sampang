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
    super.statusSiklus = 'persiapan',
    required super.luas,
    required super.targetPanen,
    required super.detailUdang,
    required super.relays,
    super.imageUrl,
    super.tanggalTebar,
    super.doc,
  });

  factory KolamModel.fromJson(Map<String, dynamic> json) {
    return KolamModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      pemilik: json['farm_id'] is int 
          ? json['farm_id'] 
          : (json['pemilik'] is int 
              ? json['pemilik'] 
              : int.tryParse((json['farm_id'] ?? json['pemilik'])?.toString() ?? '0') ?? 0),
      nama: json['name']?.toString() ?? json['nama_kolam']?.toString() ?? json['nama']?.toString() ?? '',
      mqttId: json['mqtt_id']?.toString(),
      lat: json['latitude']?.toString() ?? json['lat']?.toString() ?? '',
      long: json['longitude']?.toString() ?? json['long']?.toString() ?? '',
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      statusLabel: json['status_label']?.toString() ?? (json['status_english'] == 'active' ? 'Aktif' : 'Tidak Aktif'),
      statusSiklus: json['status_siklus']?.toString() ?? 'persiapan',
      luas: json['area'] != null 
          ? double.tryParse(json['area'].toString()) ?? 0.0 
          : (json['luas_kolam'] != null 
              ? double.tryParse(json['luas_kolam'].toString()) ?? 0.0 
              : (json['luas'] != null ? double.tryParse(json['luas'].toString()) ?? 0.0 : 0.0)),
      targetPanen: json['target_panen_kg'] != null ? double.tryParse(json['target_panen_kg'].toString()) ?? 0.0 : (json['target_panen'] != null ? double.tryParse(json['target_panen'].toString()) ?? 0.0 : 0.0),
      detailUdang: json['shrimp_detail']?.toString() ?? json['detail_udang']?.toString() ?? '',
      relays: json['relays'] != null 
          ? (json['relays'] as List).map((i) => RelayModel.fromJson(i)).toList() 
          : const [],
      imageUrl: json['image_url']?.toString() ?? json['image']?.toString(),
      tanggalTebar: json['tanggal_tebar']?.toString(),
      doc: json['doc'] is int ? json['doc'] : (json['doc'] != null ? int.tryParse(json['doc'].toString()) : null),
    );
  }
}
