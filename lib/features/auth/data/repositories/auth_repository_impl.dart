import 'package:minipos/core/storage/token_storage.dart';
import 'package:minipos/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:minipos/features/auth/domain/entities/auth_session.dart';
import 'package:minipos/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final TokenStorage tokenStorage;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.tokenStorage,
  });

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await remoteDataSource.login(
      email: email,
      password: password,
    );
    final session = response.toEntity();
    await tokenStorage.saveToken(session.token);
    return session;
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await remoteDataSource.register(
      name: name,
      email: email,
      password: password,
    );
    final session = response.toEntity();
    await tokenStorage.saveToken(session.token);
    return session;
  }

  @override
  Future<void> logout() {
    return tokenStorage.deleteToken();
  }
}
