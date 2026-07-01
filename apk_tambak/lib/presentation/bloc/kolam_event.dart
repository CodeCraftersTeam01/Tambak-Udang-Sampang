import 'package:equatable/equatable.dart';

abstract class KolamEvent extends Equatable {
  const KolamEvent();

  @override
  List<Object> get props => [];
}

class FetchKolams extends KolamEvent {}
