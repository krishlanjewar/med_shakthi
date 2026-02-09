import 'package:flutter/material.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  final IAuthRepository _repository;

  AuthController(this._repository);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  Future<bool> loginWithEmail(String email, String password) async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _repository.signInWithEmail(
        email: email,
        password: password,
      );
      _setLoading(false);
      return response.user != null;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    _setLoading(true);
    _setError(null);
    try {
      final response = await _repository.signInWithGoogle();
      _setLoading(false);
      return response.user != null;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  Future<Map<String, dynamic>?> checkSupplierStatus(String userId) async {
    try {
      return await _repository.getSupplierData(userId);
    } catch (e) {
      debugPrint('Error checking supplier status: $e');
      return null;
    }
  }

  Future<void> logout() async {
    await _repository.signOut();
    notifyListeners();
  }
}
