import 'package:flutter/foundation.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  bool _isLoggedIn = false;
  String? _userEmail;
  String? _userName;
  String? _userCity;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get userCity => _userCity;

  // Simulate login
  Future<bool> login(String email, String password) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Simple validation - accept any email/password for demo
    if (email.isNotEmpty && password.isNotEmpty) {
      _isLoggedIn = true;
      _userEmail = email;
      _userName = email.split('@')[0]; // Extract name from email
      notifyListeners();
      return true;
    }
    return false;
  }

  // Simulate registration
  Future<bool> register(String name, String email, String password, String city) async {
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Simple validation - accept any valid input for demo
    if (name.isNotEmpty && email.isNotEmpty && password.length >= 6 && city.isNotEmpty) {
      _isLoggedIn = true;
      _userEmail = email;
      _userName = name;
      _userCity = city;
      notifyListeners();
      return true;
    }
    return false;
  }

  // Logout
  void logout() {
    _isLoggedIn = false;
    _userEmail = null;
    _userName = null;
    _userCity = null;
    notifyListeners();
  }
}


