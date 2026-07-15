import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/firebase_auth_error_mapper.dart';
import '../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({required String email, required String password});
  UserModel? getCurrentUser();
  Future<void> logout();
}

final class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._firebaseAuth);
  final FirebaseAuth _firebaseAuth;
  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthenticationException(
          code: 'missing-user',
          message: 'Firebase did not return an authenticated user.',
        );
      }
      return UserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (exception) {
      throw FirebaseAuthErrorMapper.map(exception);
    } on AuthenticationException {
      rethrow;
    } catch (error) {
      throw ServerException(message: 'Login failed: $error');
    }
  }

  @override
  Future<UserModel> register({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthenticationException(
          code: 'missing-user',
          message: 'Firebase did not create the user account.',
        );
      }
      return UserModel.fromFirebaseUser(user);
    } on FirebaseAuthException catch (exception) {
      throw FirebaseAuthErrorMapper.map(exception);
    } on AuthenticationException {
      rethrow;
    } catch (error) {
      throw ServerException(message: 'Registration failed: $error');
    }
  }

  @override
  UserModel? getCurrentUser() {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return null;
    }
    return UserModel.fromFirebaseUser(user);
  }

  @override
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } on FirebaseAuthException catch (exception) {
      throw FirebaseAuthErrorMapper.map(exception);
    } catch (error) {
      throw ServerException(message: 'Logout failed: $error');
    }
  }
}
