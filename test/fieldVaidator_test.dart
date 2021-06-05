import 'package:TimeliNUS/utils/fieldValidator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('empty email returns error string', () {
    final result = EmailFieldValidator.validate('');
    expect(result, 'Email can\'t be empty');
  });

  test('non-empty email returns value', () {
    final result = EmailFieldValidator.validate('email');
    expect(result, null);
  });

  test('empty password returns error string', () {
    final result = PasswordFieldValidator.validate('');
    expect(result, 'Password can\'t be empty');
  });

  test('non-empty password returns value', () {
    final result = PasswordFieldValidator.validate('password');
    expect(result, null);
  });
}
