import 'package:equatable/equatable.dart';
import '../../domain/entities/kolam_entity.dart';

abstract class KolamState extends Equatable {
  const KolamState();

  @override
  List<Object> get props => [];
}

class KolamInitial extends KolamState {}

class KolamLoading extends KolamState {}

class KolamLoaded extends KolamState {
  final List<KolamEntity> kolams;

  const KolamLoaded(this.kolams);

  @override
  List<Object> get props => [kolams];
}

class KolamError extends KolamState {
  final String message;

  const KolamError(this.message);

  @override
  List<Object> get props => [message];
}

class KolamAddSuccess extends KolamState {
  final KolamEntity? kolam;
  const KolamAddSuccess({this.kolam});
}

class KolamUpdateSuccess extends KolamState {
  final KolamEntity? kolam;
  const KolamUpdateSuccess({this.kolam});
}

class KolamDeleteSuccess extends KolamState {}
