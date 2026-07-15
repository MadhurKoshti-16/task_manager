import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';

final class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.isEmailVerified,
    super.isFromCache,
  });
  factory UserModel.fromFirebaseUser(User user) {
    return UserModel(
      id: user.uid,
      email: user.email ?? '',
      isEmailVerified: user.emailVerified,
      isFromCache: false,
    );
  }
  factory UserModel.fromMap(Map<dynamic, dynamic> map) {
    return UserModel(
      id: map['id'] as String? ?? '',
      email: map['email'] as String? ?? '',
      isEmailVerified: map['isEmailVerified'] as bool? ?? false,
      isFromCache: true,
    );
  }
  Map<String, dynamic> toMap() {
    return {'id': id, 'email': email, 'isEmailVerified': isEmailVerified};
  }
}
