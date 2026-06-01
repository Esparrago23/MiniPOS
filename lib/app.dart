import 'package:app_prueba/features/auth/domain/entities/auth_session.dart';
import 'package:app_prueba/features/auth/domain/entities/user.dart';
import 'package:app_prueba/features/auth/domain/repositories/auth_repository.dart';
import 'package:app_prueba/features/auth/domain/usecases/login_usecase.dart';
import 'package:app_prueba/features/auth/domain/usecases/logout_usecase.dart';
import 'package:app_prueba/features/auth/domain/usecases/register_usecase.dart';
import 'package:app_prueba/features/auth/presentation/pages/login_page.dart';
import 'package:app_prueba/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:app_prueba/shared/theme/theme.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final theme = MaterialTheme(textTheme);
    final authRepository = _TemporaryAuthRepository();

    return MaterialApp(
      title: 'Punto de Venta',
      darkTheme: theme.dark(),
      theme: theme.light(),
      themeMode: ThemeMode.system,
      home: LoginPage(
        viewModel: AuthViewModel(
          loginUseCase: LoginUseCase(authRepository),
          registerUseCase: RegisterUseCase(authRepository),
          logoutUseCase: LogoutUseCase(authRepository),
        ),
      ),
    );
  }
}

class _TemporaryAuthRepository implements AuthRepository {
  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    return AuthSession(
      user: User(id: 'demo-user', name: 'Usuario demo', email: email),
      token: 'demo-token',
    );
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));

    return AuthSession(
      user: User(id: 'demo-user', name: name, email: email),
      token: 'demo-token',
    );
  }

  @override
  Future<void> logout() async {}
}
