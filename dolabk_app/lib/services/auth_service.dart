// lib/services/auth_service.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../core/network/dio_client.dart';
import '../core/network/api_response.dart';
import '../core/utils/error_handler.dart';
import '../models/user_model.dart';
import '../models/auth_response_model.dart';
import '../models/register_dto.dart';
import '../models/login_dto.dart';

class AuthService {
  final DioClient _dioClient;

  AuthService(this._dioClient);

  // Register new user
  Future<ApiResponse<AuthResponse>> register(RegisterDto registerDto) async {
    try {
      final response = await _dioClient.post(
        '/api/Auth/register',
        data: registerDto.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // Save token
      if (authResponse.token != null) {
        await _saveToken(authResponse.token!);
      }

      return ApiResponse.success(authResponse);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Login
  Future<ApiResponse<AuthResponse>> login(LoginDto loginDto) async {
    try {
      final response = await _dioClient.post(
        '/api/Auth/login',
        data: loginDto.toJson(),
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // Save token
      if (authResponse.token != null) {
        await _saveToken(authResponse.token!);
      }

      return ApiResponse.success(authResponse);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Get current user info
  Future<ApiResponse<User>> getCurrentUser() async {
    try {
      final response = await _dioClient.get('/api/Auth/me');
      final user = User.fromJson(response.data);
      return ApiResponse.success(user);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Refresh token
  Future<ApiResponse<void>> refreshToken() async {
    try {
      final response = await _dioClient.post('/api/Auth/refresh-token');

      if (response.data != null && response.data['token'] != null) {
        await _saveToken(response.data['token']);
      }

      return ApiResponse.success(null);
    } catch (e) {
      return ApiResponse.error(ErrorHandler.handleError(e));
    }
  }

  // Logout
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Save token to shared preferences
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Get saved token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }
}
