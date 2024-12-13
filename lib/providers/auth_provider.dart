import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  User? get user => _user;
  bool get isLoading => _isLoading;

  // Login
  Future<void> login(String email, String password) async {
    _setLoading(true);
    _user = await _authService.login(email, password);
    _setLoading(false);
    if (_user != null) {
      await _saveAuthState();  // Save authentication state
    }
    notifyListeners();
  }

  // Sign Up
  Future<bool> signUp(String email, String password, String name,
      String phoneNumber, String address) async {
    _setLoading(true);
    try {
      _user = await _authService.signUp(
          email, password, name, phoneNumber, address);
      if (_user != null) {
        await _saveAuthState();  // Save authentication state
      }
      notifyListeners();
      return _user != null;
    } catch (e) {
      Logger().e('Sign up error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Sign In with Google
  Future<User?> signInWithGoogle() async {
    _setLoading(true);
    User? user = await _authService.signInWithGoogle();
    _user = user;
    _setLoading(false);
    if (_user != null) {
      await _saveAuthState();  // Save authentication state
    }
    notifyListeners();
    return user;
  }

  // Logout
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    await _clearAuthState();  // Clear authentication state
    notifyListeners();
  }

  // Check if user is authenticated
  bool get isAuthenticated => _user != null;

  // Metodo per gestire lo stato di caricamento
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Carica lo stato di autenticazione quando l'app parte
  Future<void> loadAuthenticationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    if (isAuthenticated) {
      // You can retrieve the user's data (e.g. token) or assume they are logged in
      _user = await _authService.currentUser; // or other method to load the user
    }
    notifyListeners();
  }

  // Salva lo stato di autenticazione
  Future<void> _saveAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', true);
  }

  // Cancella lo stato di autenticazione
  Future<void> _clearAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isAuthenticated', false);
  }
}
