import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/kolam_repository.dart';
import 'kolam_event.dart';
import 'kolam_state.dart';

class KolamBloc extends Bloc<KolamEvent, KolamState> {
  final KolamRepository repository;

  KolamBloc({required this.repository}) : super(KolamInitial()) {
    on<FetchKolams>(_onFetchKolams);
    on<AddKolam>(_onAddKolam);
    on<AddKolamWithRelays>(_onAddKolamWithRelays);
    on<UpdateKolam>(_onUpdateKolam);
    on<UpdateKolamWithRelays>(_onUpdateKolamWithRelays);
    on<DeleteKolam>(_onDeleteKolam);
  }

  Future<void> _onFetchKolams(FetchKolams event, Emitter<KolamState> emit) async {
    emit(KolamLoading());
    try {
      final kolams = await repository.getKolams();
      emit(KolamLoaded(kolams));
    } catch (e) {
      emit(KolamError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAddKolam(AddKolam event, Emitter<KolamState> emit) async {
    emit(KolamLoading());
    try {
      final Map<String, dynamic> mergedPayload = Map<String, dynamic>.from(event.payload);
      if (mergedPayload.containsKey('mqtt_id')) {
        mergedPayload['id_mqtt'] = mergedPayload['mqtt_id'];
      }
      if (mergedPayload.containsKey('luas_kolam')) {
        mergedPayload['luas'] = mergedPayload['luas_kolam'];
      }
      if (!mergedPayload.containsKey('relays')) {
        mergedPayload['relays'] = <String>[];
      }
      final kolam = await repository.addKolam(mergedPayload);
      emit(KolamAddSuccess(kolam: kolam));
      add(FetchKolams());
    } catch (e) {
      emit(KolamError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAddKolamWithRelays(AddKolamWithRelays event, Emitter<KolamState> emit) async {
    emit(KolamLoading());
    try {
      final Map<String, dynamic> mergedPayload = Map<String, dynamic>.from(event.kolamPayload);
      mergedPayload['relays'] = event.relayNames;
      if (mergedPayload.containsKey('mqtt_id')) {
        mergedPayload['id_mqtt'] = mergedPayload['mqtt_id'];
      }
      if (mergedPayload.containsKey('luas_kolam')) {
        mergedPayload['luas'] = mergedPayload['luas_kolam'];
      }
      final kolam = await repository.addKolam(mergedPayload);
      emit(KolamAddSuccess(kolam: kolam));
      add(FetchKolams());
    } catch (e) {
      emit(KolamError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateKolam(UpdateKolam event, Emitter<KolamState> emit) async {
    emit(KolamLoading());
    try {
      final Map<String, dynamic> mergedPayload = Map<String, dynamic>.from(event.payload);
      if (mergedPayload.containsKey('mqtt_id')) {
        mergedPayload['id_mqtt'] = mergedPayload['mqtt_id'];
      }
      if (mergedPayload.containsKey('luas_kolam')) {
        mergedPayload['luas'] = mergedPayload['luas_kolam'];
      }
      await repository.updateKolam(event.id, mergedPayload);
      emit(KolamUpdateSuccess());
      add(FetchKolams());
    } catch (e) {
      emit(KolamError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateKolamWithRelays(UpdateKolamWithRelays event, Emitter<KolamState> emit) async {
    emit(KolamLoading());
    try {
      final Map<String, dynamic> mergedPayload = Map<String, dynamic>.from(event.kolamPayload);
      if (mergedPayload.containsKey('mqtt_id')) {
        mergedPayload['id_mqtt'] = mergedPayload['mqtt_id'];
      }
      if (mergedPayload.containsKey('luas_kolam')) {
        mergedPayload['luas'] = mergedPayload['luas_kolam'];
      }
      await repository.updateKolam(event.id, mergedPayload);
      if (event.relayNames.isNotEmpty) {
        await repository.addRelaysBatch(event.id, event.relayNames);
      }
      emit(KolamUpdateSuccess());
      add(FetchKolams());
    } catch (e) {
      emit(KolamError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onDeleteKolam(DeleteKolam event, Emitter<KolamState> emit) async {
    emit(KolamLoading());
    try {
      await repository.deleteKolam(event.id);
      emit(KolamDeleteSuccess());
      add(FetchKolams());
    } catch (e) {
      emit(KolamError(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
