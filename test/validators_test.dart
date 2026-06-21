import 'package:flutter_test/flutter_test.dart';
import 'package:eventhubapp/core/utils/validators.dart';

void main() {
  group('AppValidators Tests', () {
    group('validateEmail', () {
      test('should return error message when email is null or empty', () {
        expect(AppValidators.validateEmail(null), 'El correo electrónico es obligatorio');
        expect(AppValidators.validateEmail(''), 'El correo electrónico es obligatorio');
        expect(AppValidators.validateEmail('   '), 'El correo electrónico es obligatorio');
      });

      test('should return error message when email format is invalid', () {
        expect(AppValidators.validateEmail('invalid-email'), 'Ingrese un correo electrónico válido');
        expect(AppValidators.validateEmail('abc@'), 'Ingrese un correo electrónico válido');
        expect(AppValidators.validateEmail('abc@domain'), 'Ingrese un correo electrónico válido');
      });

      test('should return null when email format is valid', () {
        expect(AppValidators.validateEmail('user@example.com'), null);
        expect(AppValidators.validateEmail('user.name@domain.co'), null);
      });
    });

    group('validatePassword', () {
      test('should return error message when password is null or empty', () {
        expect(AppValidators.validatePassword(null), 'La contraseña es obligatoria');
        expect(AppValidators.validatePassword(''), 'La contraseña es obligatoria');
      });

      test('should return error message when password is too short', () {
        expect(AppValidators.validatePassword('123'), 'La contraseña debe tener al menos 6 caracteres');
        expect(AppValidators.validatePassword('12345'), 'La contraseña debe tener al menos 6 caracteres');
      });

      test('should return null when password is valid', () {
        expect(AppValidators.validatePassword('123456'), null);
        expect(AppValidators.validatePassword('secure_pass_123'), null);
      });
    });

    group('validateRequired', () {
      test('should return error message with field name when value is null or empty', () {
        expect(AppValidators.validateRequired(null, 'Nombre'), 'Nombre es obligatorio');
        expect(AppValidators.validateRequired('', 'Nombre'), 'Nombre es obligatorio');
        expect(AppValidators.validateRequired('   ', 'Nombre'), 'Nombre es obligatorio');
      });

      test('should return null when value is present', () {
        expect(AppValidators.validateRequired('John Doe', 'Nombre'), null);
      });
    });
  });
}
