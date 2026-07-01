import 'package:equatable/equatable.dart';

class KolamEntity extends Equatable {
  final int id;
  final int pemilik;
  final String nama;
  final String lat;
  final String long;
  final int status;
  final String statusLabel;
  final double luas;
  final double targetPanen;

  const KolamEntity({
    required this.id,
    required this.pemilik,
    required this.nama,
    required this.lat,
    required this.long,
    required this.status,
    required this.statusLabel,
    required this.luas,
    required this.targetPanen,
  });

  @override
  List<Object?> get props => [id, pemilik, nama, lat, long, status, statusLabel, luas, targetPanen];
}
