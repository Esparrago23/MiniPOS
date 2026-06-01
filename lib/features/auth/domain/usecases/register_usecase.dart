import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  const RegisterUseCase(this.repository);

  Future<AuthSession> call({
    required String name,
    required String email,
    required String password,
  }) {
    final cleanName = name.trim();
    final cleanEmail = email.trim();

    if (cleanName.isEmpty || cleanEmail.isEmpty || password.isEmpty) {
      throw ArgumentError('Name, email and password are required.');
    }

    return repository.register(
      name: cleanName,
      email: cleanEmail,
      password: password,
    );
  }
}
