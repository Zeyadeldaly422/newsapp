import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app/services/local_auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LocalAuthService _authService;

  AuthCubit(this._authService) : super(AuthInitial());

  Future<void> register(Map<String, dynamic> userData) async {
    emit(AuthLoading());
    try {
      final user = await _authService.register(userData);
      if (user != null) {
        emit(AuthRegistered(user));
      } else {
        emit(const AuthFailure('Registration failed. Please try again.'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        emit(AuthSuccess(user));
      } else {
        emit(const AuthFailure('Invalid email or password.'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    await _authService.logout();
    emit(AuthLoggedOut());
  }

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    final user = await _authService.getCurrentUser();
    if (user != null) {
      emit(AuthSuccess(user));
    } else {
      emit(AuthLoggedOut());
    }
  }

  void resetPassword(String trim) {}
}