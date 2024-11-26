import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false; // Aggiungi variabile per lo stato di caricamento
  final AuthService _authService = AuthService();

  User? get user => _user;
  bool get isLoading => _isLoading; // Getter per lo stato di caricamento

  // Login
  Future<void> login(String email, String password) async {
    _setLoading(true);
    _user = await _authService.login(email, password);
    _setLoading(false);
    notifyListeners();
  }

  // Sign Up
  // Sign Up
  Future<bool> signUp(String email, String password, String name,
      String phoneNumber, String address) async {
    _setLoading(true);
    try {
      // Passa tutti gli argomenti richiesti a signUp
      _user = await _authService.signUp(
          email, password, name, phoneNumber, address); // Call the service
      return _user != null; // Return true if user is registered successfully
    } catch (e) {
      Logger().e('Sign up error: ${e.toString()}');  // logger instead of print
      return false; // Return false if registration failed
    } finally {
      _setLoading(false);
      notifyListeners();
    }
  }

  /*Future<User?> signInWithGoogle() async {
    _setLoading(true);
    User? user = await _authService.signInWithGoogle();
    _user = user;
    _setLoading(false);
    notifyListeners();
    return user;
  }*/

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    notifyListeners();
  }

  // Check if user is authenticated
  bool get isAuthenticated => _user != null;

  // Metodo per gestire lo stato di caricamento
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
