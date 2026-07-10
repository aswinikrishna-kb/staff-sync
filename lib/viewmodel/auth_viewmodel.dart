import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/user_model.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool isLoading = false;
  String? selectedRole; // Changed to nullable to avoid default selection
  UserModel? userModel;

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
    String? companyName,
    String? employeeId,
    String? adminReferral,
  }) async {
    if (selectedRole == null) {
      throw Exception("Please select a role (Admin or Staff)");
    }
    
    try {
      isLoading = true;
      notifyListeners();

      await _authService.signup(
        username: username,
        phone: phone,
        email: email,
        password: password,
        role: selectedRole!,
        companyName: companyName,
        employeeId: employeeId,
        adminReferral: adminReferral,
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

      String? role = await _authService.login(
        email: email,
        password: password,
      );
      
      if (role != null) {
        await fetchUserProfile();
      }
      
      return role;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        userModel = UserModel.fromMap(doc.data()!);
        notifyListeners();
      }
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    userModel = null;
    selectedRole = null; // Clear role on logout
    notifyListeners();
  }
}
