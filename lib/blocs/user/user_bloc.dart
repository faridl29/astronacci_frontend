import 'package:astronacci/models/pagination.dart';
import 'package:astronacci/models/user.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../repositories/user_repository.dart';
import 'user_event.dart';
import 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository _userRepository = UserRepository();

  UserBloc() : super(const UserState()) {
    on<UsersLoadRequested>(_onUsersLoadRequested);
    on<UsersSearchRequested>(_onUsersSearchRequested);
    on<UserDetailRequested>(_onUserDetailRequested);
    on<UserProfileUpdateRequested>(_onUserProfileUpdateRequested);
  }

  Future<void> _onUsersLoadRequested(
    UsersLoadRequested event,
    Emitter<UserState> emit,
  ) async {
    if (event.isRefresh) {
      emit(state.copyWith(
        status: UserStatus.loading,
        users: [],
        hasReachedMax: false,
        searchQuery: null,
      ));
    } else if (state.hasReachedMax) {
      return;
    } else if (event.page == 1) {
      emit(state.copyWith(
        status: UserStatus.loading,
        searchQuery: null,
      ));
    }

    try {
      final result = await _userRepository.getUsers(
        page: event.page,
        perPage: 10,
      );

      final users = result['users'] as List<User>;
      final pagination = result['pagination'] as Pagination;

      final allUsers = event.page == 1 || event.isRefresh
          ? users
          : [...state.users, ...users];

      print('total user: ${allUsers.length}');

      emit(state.copyWith(
        status: UserStatus.success,
        users: allUsers,
        pagination: pagination,
        hasReachedMax: !pagination.hasNextPage,
        error: null,
      ));
    } catch (e) {
      String errorMessage = 'Failed to load users';

      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }
      }

      emit(state.copyWith(
        status: UserStatus.failure,
        error: errorMessage,
      ));
    }
  }

  Future<void> _onUsersSearchRequested(
    UsersSearchRequested event,
    Emitter<UserState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(const UsersLoadRequested(isRefresh: true));
      return;
    }

    if (event.isRefresh || event.query != state.searchQuery) {
      emit(state.copyWith(
        status: UserStatus.loading,
        users: [],
        hasReachedMax: false,
        searchQuery: event.query,
      ));
    } else if (state.hasReachedMax) {
      return;
    }

    try {
      final result = await _userRepository.searchUsers(
        query: event.query,
        page: event.page,
        perPage: 10,
      );

      final users = result['users'] as List<User>;
      final pagination = result['pagination'] as Pagination?;

      final allUsers = event.page == 1 || event.isRefresh
          ? users
          : [...state.users, ...users];

      emit(state.copyWith(
        status: UserStatus.success,
        users: allUsers,
        pagination: pagination,
        hasReachedMax: pagination == null || !pagination.hasNextPage,
        error: null,
      ));
    } catch (e) {
      String errorMessage = 'Search failed';

      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }
      }

      emit(state.copyWith(
        status: UserStatus.failure,
        error: errorMessage,
      ));
    }
  }

  Future<void> _onUserDetailRequested(
    UserDetailRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserStatus.loading));

    try {
      final user = await _userRepository.getUserById(event.userId);
      emit(state.copyWith(
        status: UserStatus.success,
        selectedUser: user,
        error: null,
      ));
    } catch (e) {
      String errorMessage = 'Failed to load user details';

      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }
      }

      emit(state.copyWith(
        status: UserStatus.failure,
        error: errorMessage,
      ));
    }
  }

  Future<void> _onUserProfileUpdateRequested(
    UserProfileUpdateRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(state.copyWith(status: UserStatus.loading));

    try {
      final updatedUser = await _userRepository.updateProfile(
        name: event.name,
        email: event.email,
        phone: event.phone,
        bio: event.bio,
        dateOfBirth: event.dateOfBirth,
        gender: event.gender,
        avatarBase64: event.avatarBase64,
        currentPassword: event.currentPassword,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      );

      emit(state.copyWith(
        status: UserStatus.success,
        selectedUser: updatedUser,
        error: null,
      ));
    } catch (e) {
      String errorMessage = 'Profile update failed';

      if (e is DioException && e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('message')) {
          errorMessage = responseData['message'];
        }
      }

      emit(state.copyWith(
        status: UserStatus.failure,
        error: errorMessage,
      ));
    }
  }
}
