import 'package:flutter/foundation.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthViewModel extends ChangeNotifier {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;

  AuthViewModel({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
  });

  AuthStatus _status = AuthStatus.initial;
  AuthSession? _session;
  String? _errorMessage;

  AuthStatus get status => _status;
  AuthSession? get session => _session;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _status == AuthStatus.loading;
  bool get isAuthenticated => _session?.isAuthenticated ?? false;

  Future<bool> login({required String email, required String password}) async {
    _setLoading();

    try {
      _session = await loginUseCase(email: email, password: password);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (error) {
      _setError(error);
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading();

    try {
      _session = await registerUseCase(
        name: name,
        email: email,
        password: password,
      );
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (error) {
      _setError(error);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading();

    try {
      await logoutUseCase();
      _session = null;
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (error) {
      _setError(error);
    }
  }

  void clearError() {
    _errorMessage = null;
    if (_status == AuthStatus.error) {
      _status = AuthStatus.initial;
    }
    notifyListeners();
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(Object error) {
    _status = AuthStatus.error;
    _errorMessage = error.toString();
    notifyListeners();
  }
}
