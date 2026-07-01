import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final int roleId;

  const AuthRegisterRequested(this.name, this.email, this.password, this.roleId);

  @override
  List<Object> get props => [name, email, password, roleId];
}

class AuthLogoutRequested extends AuthEvent {}
