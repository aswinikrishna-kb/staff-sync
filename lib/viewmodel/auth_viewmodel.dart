import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool isLoading = false;
  String selectedRole = 'staff';

  void changeRole(String role) {
    selectedRole = role;
    notifyListeners();
  }

  String? validatePasswordsMatch(String password, String confirmPassword) {
    if (password.trim() != confirmPassword.trim()) {
      return 'Passwords do not match';
    }
    return null;
  }

  Future<void> signup({
    required String username,
    required String phone,
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      await _authService.signup(
        username: username,
        phone: phone,
        email: email,
        password: password,
        role: selectedRole,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading = true;
      notifyListeners();

      return await _authService.login(
        email: email,
        password: password,
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    notifyListeners();
  }
}
