import 'package:firebase_auth/firebase_auth.dart';

import 'exceptions.dart';

abstract final class FirebaseAuthErrorMapper {
  FirebaseAuthErrorMapper._();

  static AuthenticationException map(FirebaseAuthException exception) {
    return switch (exception.code) {
      'invalid-email' => const AuthenticationException(
        code: 'invalid-email',
        message: 'The email address is not valid.',
      ),

      'user-disabled' => const AuthenticationException(
        code: 'user-disabled',
        message: 'This account has been disabled.',
      ),

      'user-not-found' => const AuthenticationException(
        code: 'user-not-found',
        message: 'No account was found for this email address.',
      ),

      'wrong-password' => const AuthenticationException(
        code: 'wrong-password',
        message: 'The password you entered is incorrect.',
      ),

      'invalid-credential' => const AuthenticationException(
        code: 'invalid-credential',
        message: 'The email address or password is incorrect.',
      ),

      'email-already-in-use' => const AuthenticationException(
        code: 'email-already-in-use',
        message: 'An account already exists for this email address.',
      ),

      'weak-password' => const AuthenticationException(
        code: 'weak-password',
        message: 'Please choose a stronger password.',
      ),

      'operation-not-allowed' => const AuthenticationException(
        code: 'operation-not-allowed',
        message: 'Email and password authentication is not enabled.',
      ),

      'too-many-requests' => const AuthenticationException(
        code: 'too-many-requests',
        message: 'Too many attempts were made. Please wait and try again.',
      ),

      'network-request-failed' => const AuthenticationException(
        code: 'network-request-failed',
        message: 'The authentication request could not reach the server.',
      ),

      'requires-recent-login' => const AuthenticationException(
        code: 'requires-recent-login',
        message: 'Please log in again before completing this action.',
      ),

      _ => AuthenticationException(
        code: exception.code,
        message:
            exception.message ?? 'Authentication failed. Please try again.',
      ),
    };
  }
}
