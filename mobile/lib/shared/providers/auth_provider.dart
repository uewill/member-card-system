import 'package:flutter/material.dart';
import '../services/api/auth_repository.dart';

/// 认证状态管理 Provider
class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepo = AuthRepository();
  Map<String, dynamic>? _staff;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get staff => _staff;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _staff != null;

  /// 登录
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _staff = await _authRepo.login(username, password);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// 登出
  void logout() {
    _authRepo.logout();
    _staff = null;
    notifyListeners();
  }
}
