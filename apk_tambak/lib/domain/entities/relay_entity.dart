import 'package:equatable/equatable.dart';

class RelayEntity extends Equatable {
  final int id;
  final int kolamId;
  final String namaRelay;

  const RelayEntity({
    required this.id,
    required this.kolamId,
    required this.namaRelay,
  });

  @override
  List<Object?> get props => [id, kolamId, namaRelay];
}
