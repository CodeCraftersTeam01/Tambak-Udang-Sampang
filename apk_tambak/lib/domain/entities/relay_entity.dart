import 'package:equatable/equatable.dart';

class RelayEntity extends Equatable {
  final int id;
  final int kolamId;
  final String namaRelay;
  final bool isOn;

  const RelayEntity({
    required this.id,
    required this.kolamId,
    required this.namaRelay,
    this.isOn = false,
  });

  @override
  List<Object?> get props => [id, kolamId, namaRelay, isOn];
}
