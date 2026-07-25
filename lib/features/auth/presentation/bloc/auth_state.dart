import 'package:flutter/foundation.dart';

@immutable
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String email;
  final int? userId;
  final String? userRole;

  Authenticated({required this.email, this.userId, this.userRole});
}

class Unauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String error;

  AuthFailure({required this.error});
}
