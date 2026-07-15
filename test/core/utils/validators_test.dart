import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager_bloc/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('returns required message when value is null', () {
      final result = Validators.email(null);
      expect(result, 'Email address is required.');
    });
    test('returns required message when value is empty', () {
      final result = Validators.email('');
      expect(result, 'Email address is required.');
    });
    test('returns required message when value contains spaces only', () {
      final result = Validators.email(' ');
      expect(result, 'Email address is required.');
    });
    test('returns invalid message for malformed email', () {
      final result = Validators.email('madhur-example.com');
      expect(result, 'Enter a valid email address.');
    });
    test('returns invalid message when domain extension is missing', () {
      final result = Validators.email('madhur@example');
      expect(result, 'Enter a valid email address.');
    });
    test('returns null for a valid email', () {
      final result = Validators.email('madhur@example.com');
      expect(result, isNull);
    });
    test('trims surrounding spaces before validation', () {
      final result = Validators.email(' madhur@example.com ');
      expect(result, isNull);
    });
  });
  group('Validators.password', () {
    test('returns required message when password is null', () {
      final result = Validators.password(null);
      expect(result, 'Password is required.');
    });
    test('returns required message when password is empty', () {
      final result = Validators.password('');
      expect(result, 'Password is required.');
    });
    test('returns length message for password below 8 characters', () {
      final result = Validators.password('Pass1');
      expect(result, 'Password must contain at least 8 characters.');
    });
    test('returns uppercase message when uppercase is missing', () {
      final result = Validators.password('password1');
      expect(result, 'Add at least one uppercase letter.');
    });
    test('returns lowercase message when lowercase is missing', () {
      final result = Validators.password('PASSWORD1');
      expect(result, 'Add at least one lowercase letter.');
    });
    test('returns number message when number is missing', () {
      final result = Validators.password('Password');
      expect(result, 'Add at least one number.');
    });
    test('returns null for valid password', () {
      final result = Validators.password('Password1');
      expect(result, isNull);
    });
  });
  group('Validators.confirmPassword', () {
    test('returns required message when confirmation is empty', () {
      final result = Validators.confirmPassword(
        value: '',
        password: 'Password1',
      );
      expect(result, 'Confirm your password.');
    });
    test('returns mismatch message when passwords differ', () {
      final result = Validators.confirmPassword(
        value: 'Password2',
        password: 'Password1',
      );
      expect(result, 'Passwords do not match.');
    });
    test('returns null when passwords match', () {
      final result = Validators.confirmPassword(
        value: 'Password1',
        password: 'Password1',
      );
      expect(result, isNull);
    });
  });
}
