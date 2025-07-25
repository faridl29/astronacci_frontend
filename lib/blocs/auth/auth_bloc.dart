import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository = AuthRepository();

  AuthBloc() : super(const AuthState()) {
    on<AuthStarted>(_onAuthStarted);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthForgotPasswordRequested>(_onAuthForgotPasswordRequested);
    on<AuthResetPasswordRequested>(_onAuthResetPasswordRequested); // Add this
  }

  Future<void> _onAuthStarted(
    AuthStarted event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final user = await _authRepository.getCurrentUser();
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } catch (e) {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final authResponse = await _authRepository.login(
        email: event.email,
        password: event.password,
      );

      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: authResponse.user,
        isLoading: false,
      ));
    } catch (e) {
      String errorMessage = 'Login failed';

      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }
      }

      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        error: errorMessage,
        isLoading: false,
      ));
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final authResponse = await _authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
        phone: event.phone,
      );

      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: authResponse.user,
        isLoading: false,
      ));
    } catch (e) {
      String errorMessage = 'Registration failed';

      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }
      }

      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        error: errorMessage,
        isLoading: false,
      ));
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      await _authRepository.logout();
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        isLoading: false,
      ));
    }
  }

  Future<void> _onAuthForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await _authRepository.forgotPassword(email: event.email);
      emit(state.copyWith(isLoading: false));
    } catch (e) {
      String errorMessage = 'Failed to send reset link';

      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }
      }

      emit(state.copyWith(
        error: errorMessage,
        isLoading: false,
      ));
    }
  }

  Future<void> _onAuthResetPasswordRequested(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      await _authRepository.resetPassword(
        email: event.email,
        resetCode: event.resetCode,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      );

      emit(state.copyWith(
        status: AuthStatus.passwordResetSuccess,
        isLoading: false,
      ));
    } catch (e) {
      String errorMessage = 'Password reset failed';

      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }
      }

      emit(state.copyWith(
        error: errorMessage,
        isLoading: false,
      ));
    }
  }
}
