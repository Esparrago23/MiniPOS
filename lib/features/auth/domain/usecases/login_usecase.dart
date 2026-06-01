import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<AuthSession> call({required String email, required String password}) {
    final cleanEmail = email.trim();

    if (cleanEmail.isEmpty || password.isEmpty) {
      throw ArgumentError('Email and password are required.');
    }

    return repository.login(email: cleanEmail, password: password);
  }
}
