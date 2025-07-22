import '../models/user.dart';
import '../models/pagination.dart';
import '../services/api_client.dart';

class UserRepository {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int perPage = 10,
    String? search,
  }) async {
    try {
      final response = await _apiClient.get('/users', queryParameters: {
        'page': page,
        'per_page': perPage,
        if (search != null && search.isNotEmpty) 'search': search,
      });

      final users = (response.data['data']['users'] as List)
          .map((user) => User.fromJson(user))
          .toList();

      final pagination =
          Pagination.fromJson(response.data['data']['pagination']);

      return {
        'users': users,
        'pagination': pagination,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getUserById(int id) async {
    try {
      final response = await _apiClient.get('/users/$id');
      return User.fromJson(response.data['data']['user']);
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? bio,
    DateTime? dateOfBirth,
    String? gender,
    String? avatarBase64,
    String? currentPassword,
    String? password,
    String? passwordConfirmation,
  }) async {
    try {
      final data = <String, dynamic>{};

      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (bio != null) data['bio'] = bio;
      if (dateOfBirth != null) {
        data['date_of_birth'] = dateOfBirth.toIso8601String().split('T')[0];
      }
      if (gender != null) data['gender'] = gender;
      if (currentPassword != null) data['current_password'] = currentPassword;
      if (password != null) {
        data['password'] = password;
        data['password_confirmation'] = passwordConfirmation!;
      }
      if (avatarBase64 != null) data['avatar_base64'] = avatarBase64;

      final response = await _apiClient.put('/users/profile', data: data);
      return User.fromJson(response.data['data']['user']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> searchUsers({
    required String query,
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _apiClient.get('/users/search', queryParameters: {
        'q': query,
        'page': page,
        'per_page': perPage,
      });

      final users = (response.data['data']['users'] as List)
          .map((user) => User.fromJson(user))
          .toList();

      final pagination = response.data['data']['pagination'] != null
          ? Pagination.fromJson(response.data['data']['pagination'])
          : null;

      return {
        'users': users,
        'pagination': pagination,
      };
    } catch (e) {
      rethrow;
    }
  }
}
