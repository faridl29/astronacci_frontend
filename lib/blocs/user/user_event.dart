import 'package:equatable/equatable.dart';

abstract class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class UsersLoadRequested extends UserEvent {
  final int page;
  final bool isRefresh;

  const UsersLoadRequested({
    this.page = 1,
    this.isRefresh = false,
  });

  @override
  List<Object> get props => [page, isRefresh];
}

class UsersSearchRequested extends UserEvent {
  final String query;
  final int page;
  final bool isRefresh;

  const UsersSearchRequested({
    required this.query,
    this.page = 1,
    this.isRefresh = false,
  });

  @override
  List<Object> get props => [query, page, isRefresh];
}

class UserDetailRequested extends UserEvent {
  final int userId;

  const UserDetailRequested({required this.userId});

  @override
  List<Object> get props => [userId];
}

class UserProfileUpdateRequested extends UserEvent {
  final String? name;
  final String? email;
  final String? phone;
  final String? bio;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? avatarBase64;
  final String? currentPassword;
  final String? password;
  final String? passwordConfirmation;

  const UserProfileUpdateRequested({
    this.name,
    this.email,
    this.phone,
    this.bio,
    this.dateOfBirth,
    this.gender,
    this.avatarBase64,
    this.currentPassword,
    this.password,
    this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        bio,
        dateOfBirth,
        gender,
        avatarBase64,
        currentPassword,
        password,
        passwordConfirmation
      ];
}
