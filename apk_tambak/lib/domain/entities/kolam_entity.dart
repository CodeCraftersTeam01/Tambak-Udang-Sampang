import 'package:equatable/equatable.dart';
import 'relay_entity.dart';

class KolamEntity extends Equatable {
  final int id;
  final int pemilik;
  final String nama;
  final String? mqttId;
  final String lat;
  final String long;
  final int status;
  final String statusLabel;
  final String statusSiklus;
  final double luas;
  final double targetPanen;
  final String detailUdang;
  final List<RelayEntity> relays;
  final String? imageUrl;
  final String? tanggalTebar;
  final int? doc;

  const KolamEntity({
    required this.id,
    required this.pemilik,
    required this.nama,
    this.mqttId,
    required this.lat,
    required this.long,
    required this.status,
    required this.statusLabel,
    this.statusSiklus = 'persiapan',
    required this.luas,
    required this.targetPanen,
    required this.detailUdang,
    required this.relays,
    this.imageUrl,
    this.tanggalTebar,
    this.doc,
  });

  @override
  List<Object?> get props => [
        id,
        pemilik,
        nama,
        mqttId,
        lat,
        long,
        status,
        statusLabel,
        statusSiklus,
        luas,
        targetPanen,
        detailUdang,
        relays,
        imageUrl,
        tanggalTebar,
        doc,
      ];
}
