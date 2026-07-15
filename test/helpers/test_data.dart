import 'package:task_manager_bloc/features/authentication/data/models/user_model.dart';
import 'package:task_manager_bloc/features/authentication/domain/entities/user_entity.dart';

abstract final class TestData {
  TestData._();
  static const String userId = 'firebase-user-123';
  static const String email = 'madhur@example.com';
  static const String password = 'Password1';
  static const String wrongPassword = 'WrongPassword1';
  static const UserEntity userEntity = UserEntity(
    id: userId,
    email: email,
    isEmailVerified: false,
  );
  static const UserModel userModel = UserModel(
    id: userId,
    email: email,
    isEmailVerified: false,
  );
  static const UserModel cachedUserModel = UserModel(
    id: userId,
    email: email,
    isEmailVerified: false,
    isFromCache: true,
  );
}
