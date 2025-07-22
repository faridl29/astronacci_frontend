import 'package:astronacci/app.dart';
import 'package:astronacci/models/auth_response.dart';
import 'package:astronacci/models/pagination.dart';
import 'package:astronacci/models/user.dart';
import 'package:dio/dio.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/api/v1';
  late Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) {
        return status != null;
      },
    ));

    _dio.interceptors.add(PrettyDioLogger(
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
      compact: true,
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _getToken();

        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
      onError: (DioException error, ErrorInterceptorHandler handler) async {
        if (error.response?.statusCode == 401) {
          await _clearToken();
        }
        handler.next(error);
      },
    ));
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    final context = navigatorKey.currentContext;
    if (context != null) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
    }
  }

  // Auth APIs
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    try {
      final response = await _dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'phone': phone,
      });

      final authResponse = AuthResponse.fromJson(response.data['data']);
      await _setToken(authResponse.token);
      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final authResponse = AuthResponse.fromJson(response.data['data']);
      await _setToken(authResponse.token);
      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (e) {
    } finally {
      await _clearToken();
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      await _dio.post('/auth/forgot-password', data: {
        'email': email,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get('/auth/me');
      return User.fromJson(response.data['data']['user']);
    } catch (e) {
      rethrow;
    }
  }

  // User APIs
  Future<Map<String, dynamic>> getUsers({
    int page = 1,
    int perPage = 10,
    String? search,
  }) async {
    try {
      final response = await _dio.get('/users', queryParameters: {
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
      final response = await _dio.get('/users/$id');
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

      final response = await _dio.put('/users/profile', data: data);
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
      final response = await _dio.get('/users/search', queryParameters: {
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
