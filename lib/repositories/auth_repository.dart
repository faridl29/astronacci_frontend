import '../models/auth_response.dart';
import '../models/user.dart';
import '../services/api_client.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
  }) async {
    try {
      final response = await _apiClient.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'phone': phone,
      });

      final authResponse = AuthResponse.fromJson(response.data['data']);
      await _apiClient.setToken(authResponse.token);
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
      final response = await _apiClient.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final authResponse = AuthResponse.fromJson(response.data['data']);
      await _apiClient.setToken(authResponse.token);
      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/auth/logout');
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      await _apiClient.clearToken();
    }
  }

  Future<void> forgotPassword({required String email}) async {
    try {
      await _apiClient.post('/auth/forgot-password', data: {
        'email': email,
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/auth/me');
      return User.fromJson(response.data['data']['user']);
    } catch (e) {
      rethrow;
    }
  }
}
