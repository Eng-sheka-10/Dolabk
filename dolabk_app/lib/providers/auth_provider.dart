// lib/providers/auth_provider.dart
import 'package:dolabk_app/models/login_dto.dart';
import 'package:dolabk_app/models/register_dto.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;
  String? _token;

  AuthProvider(this._authService);

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        LoginDto(email: email, password: password),
      );

      if (response.success && response.data != null) {
        _isAuthenticated = true;
        _token = response.data!.token;
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Login failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
    String fullName,
    String email,
    String password,
    String phone,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        RegisterDto(
          fullName: fullName,
          email: email,
          password: password,
          phoneNumber: phone,
        ),
      );

      if (response.success) {
        _error = null;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response.message ?? 'Registration failed';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (e) {
      // Handle error
    }
    _isAuthenticated = false;
    _token = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
