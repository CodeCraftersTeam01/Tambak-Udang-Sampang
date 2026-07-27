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
  final double luas;
  final double targetPanen;
  final String detailUdang;
  final List<RelayEntity> relays;

  const KolamEntity({
    required this.id,
    required this.pemilik,
    required this.nama,
    this.mqttId,
    required this.lat,
    required this.long,
    required this.status,
    required this.statusLabel,
    required this.luas,
    required this.targetPanen,
    required this.detailUdang,
    required this.relays,
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
        luas,
        targetPanen,
        detailUdang,
        relays,
      ];
}
