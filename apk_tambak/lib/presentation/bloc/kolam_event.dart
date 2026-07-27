import 'package:equatable/equatable.dart';

abstract class KolamEvent extends Equatable {
  const KolamEvent();

  @override
  List<Object> get props => [];
}

class FetchKolams extends KolamEvent {}

class AddKolam extends KolamEvent {
  final Map<String, dynamic> payload;

  const AddKolam(this.payload);

  @override
  List<Object> get props => [payload];
}

class AddKolamWithRelays extends KolamEvent {
  final Map<String, dynamic> kolamPayload;
  final List<String> relayNames;

  const AddKolamWithRelays(this.kolamPayload, this.relayNames);

  @override
  List<Object> get props => [kolamPayload, relayNames];
}

class UpdateKolam extends KolamEvent {
  final int id;
  final Map<String, dynamic> payload;

  const UpdateKolam(this.id, this.payload);

  @override
  List<Object> get props => [id, payload];
}

class UpdateKolamWithRelays extends KolamEvent {
  final int id;
  final Map<String, dynamic> kolamPayload;
  final List<String> relayNames;

  const UpdateKolamWithRelays(this.id, this.kolamPayload, this.relayNames);

  @override
  List<Object> get props => [id, kolamPayload, relayNames];
}

class DeleteKolam extends KolamEvent {
  final int id;

  const DeleteKolam(this.id);

  @override
  List<Object> get props => [id];
}
