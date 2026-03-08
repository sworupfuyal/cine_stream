import 'package:cine_stream/features/auth/domain/usecases/login_usecases.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoginUsecasesParams', () {
    test('should store email and password', () {
      const params = LoginUsecasesParams(
        email: 'test@example.com',
        password: 'pass123',
      );
      expect(params.email, 'test@example.com');
      expect(params.password, 'pass123');
    });

    test('props should contain email and password', () {
      const params = LoginUsecasesParams(
        email: 'a@b.com',
        password: 'p',
      );
      expect(params.props, ['a@b.com', 'p']);
    });

    test('two params with same values should be equal', () {
      const p1 = LoginUsecasesParams(email: 'a@b.com', password: 'p');
      const p2 = LoginUsecasesParams(email: 'a@b.com', password: 'p');
      expect(p1, equals(p2));
    });

    test('two params with different values should not be equal', () {
      const p1 = LoginUsecasesParams(email: 'a@b.com', password: 'p1');
      const p2 = LoginUsecasesParams(email: 'a@b.com', password: 'p2');
      expect(p1, isNot(equals(p2)));
    });
  });
}
