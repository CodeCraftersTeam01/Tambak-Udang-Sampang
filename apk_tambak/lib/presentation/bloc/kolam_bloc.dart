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
      final kolam = await repository.addKolam(event.payload);
      emit(KolamAddSuccess(kolam: kolam));
      add(FetchKolams());
    } catch (e) {
      emit(KolamError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onAddKolamWithRelays(AddKolamWithRelays event, Emitter<KolamState> emit) async {
    emit(KolamLoading());
    try {
      final kolam = await repository.addKolam(event.kolamPayload);
      if (event.relayNames.isNotEmpty) {
        await repository.addRelaysBatch(kolam.id, event.relayNames);
      }
      emit(KolamAddSuccess(kolam: kolam));
      add(FetchKolams());
    } catch (e) {
      emit(KolamError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateKolam(UpdateKolam event, Emitter<KolamState> emit) async {
    emit(KolamLoading());
    try {
      await repository.updateKolam(event.id, event.payload);
      emit(KolamUpdateSuccess());
      add(FetchKolams());
    } catch (e) {
      emit(KolamError(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onUpdateKolamWithRelays(UpdateKolamWithRelays event, Emitter<KolamState> emit) async {
    emit(KolamLoading());
    try {
      await repository.updateKolam(event.id, event.kolamPayload);
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
