import 'package:hive_ce/hive.dart';
import '../../../../core/constants/hive_constants.dart';
import '../../../../core/error/exceptions.dart';
import '../models/user_model.dart';

abstract interface class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  UserModel? getCachedUser();
  Future<void> clearCachedUser();
}

final class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl(this._authBox);
  final Box<dynamic> _authBox;
  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await _authBox.put(HiveConstants.cachedUserKey, user.toMap());
    } catch (error) {
      throw CacheException('Unable to cache authenticated user: $error');
    }
  }

  @override
  UserModel? getCachedUser() {
    try {
      final value = _authBox.get(HiveConstants.cachedUserKey);
      if (value == null) {
        return null;
      }
      if (value is! Map) {
        throw const CacheException('The cached user has an invalid format.');
      }
      return UserModel.fromMap(value);
    } on CacheException {
      rethrow;
    } catch (error) {
      throw CacheException('Unable to read cached user: $error');
    }
  }

  @override
  Future<void> clearCachedUser() async {
    try {
      await _authBox.delete(HiveConstants.cachedUserKey);
    } catch (error) {
      throw CacheException('Unable to clear cached user: $error');
    }
  }
}
