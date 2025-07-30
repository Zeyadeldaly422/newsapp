import 'package:equatable/equatable.dart';
import 'package:news_app/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final User user;
  const AuthSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthRegistered extends AuthState {
  final User user;
  const AuthRegistered(this.user);
    
  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  final String error;
  const AuthFailure(this.error);
    
  @override
  List<Object?> get props => [error];
}

class AuthLoggedOut extends AuthState {}