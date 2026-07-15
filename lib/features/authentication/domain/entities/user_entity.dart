import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    required this.isEmailVerified,
    this.isFromCache = false,
  });

  final String id;
  final String email;
  final bool isEmailVerified;
  final bool isFromCache;

  UserEntity copyWith({
    String? id,
    String? email,
    bool? isEmailVerified,
    bool? isFromCache,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [id, email, isEmailVerified, isFromCache];
}
