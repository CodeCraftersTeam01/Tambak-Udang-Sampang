import '../../domain/entities/kolam_entity.dart';

class KolamModel extends KolamEntity {
  const KolamModel({
    required super.id,
    required super.pemilik,
    required super.nama,
    required super.lat,
    required super.long,
    required super.status,
    required super.statusLabel,
    required super.luas,
    required super.targetPanen,
  });

  factory KolamModel.fromJson(Map<String, dynamic> json) {
    return KolamModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      pemilik: json['pemilik'] is int ? json['pemilik'] : int.tryParse(json['pemilik']?.toString() ?? '0') ?? 0,
      nama: json['nama_kolam']?.toString() ?? json['nama']?.toString() ?? '',
      lat: json['lat']?.toString() ?? '',
      long: json['long']?.toString() ?? '',
      status: json['status'] is int ? json['status'] : int.tryParse(json['status']?.toString() ?? '0') ?? 0,
      statusLabel: json['status_label']?.toString() ?? 'Tidak Diketahui',
      luas: double.tryParse(json['luas']?.toString() ?? '0') ?? 0.0,
      targetPanen: double.tryParse(json['target_panen']?.toString() ?? '0') ?? 0.0,
    );
  }
}
