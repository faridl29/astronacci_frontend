import 'package:astronacci/models/pagination.dart';
import 'package:astronacci/models/user.dart';
import 'package:equatable/equatable.dart';

enum UserStatus { initial, loading, success, failure }

class UserState extends Equatable {
  final UserStatus status;
  final List<User> users;
  final User? selectedUser;
  final Pagination? pagination;
  final String? error;
  final bool hasReachedMax;
  final String? searchQuery;

  const UserState({
    this.status = UserStatus.initial,
    this.users = const [],
    this.selectedUser,
    this.pagination,
    this.error,
    this.hasReachedMax = false,
    this.searchQuery,
  });

  UserState copyWith({
    UserStatus? status,
    List<User>? users,
    User? selectedUser,
    Pagination? pagination,
    String? error,
    bool? hasReachedMax,
    String? searchQuery,
  }) {
    return UserState(
      status: status ?? this.status,
      users: users ?? this.users,
      selectedUser: selectedUser ?? this.selectedUser,
      pagination: pagination ?? this.pagination,
      error: error,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
        status,
        users,
        selectedUser,
        pagination,
        error,
        hasReachedMax,
        searchQuery
      ];
}
