import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  final AuthService _authService = AuthService();

  User? get user => _user;

  // Login
  Future<void> login(String email, String password) async {
    _user = await _authService.login(email, password);
    notifyListeners();
  }

  // Sign Up
  Future<void> signUp(String email, String password) async {
    _user = await _authService.signUp(email, password);
    notifyListeners();
  }

  Future<User?> signInWithGoogle() async {
    User? user = await _authService.signInWithGoogle();
    _user = user;
    notifyListeners();
    return user;
  }

    // Logout
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  // Check if user is authenticated
  bool get isAuthenticated => _user != null;
}
