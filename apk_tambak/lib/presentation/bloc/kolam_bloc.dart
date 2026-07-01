import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/kolam_repository.dart';
import 'kolam_event.dart';
import 'kolam_state.dart';

class KolamBloc extends Bloc<KolamEvent, KolamState> {
  final KolamRepository repository;

  KolamBloc({required this.repository}) : super(KolamInitial()) {
    on<FetchKolams>(_onFetchKolams);
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
}
