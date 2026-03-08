import 'package:cine_stream/features/auth/domain/entities/auth_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthEntity', () {
    test('should create AuthEntity with required fields', () {
      const entity = AuthEntity(email: 'a@b.com', fullName: 'John');
      expect(entity.email, 'a@b.com');
      expect(entity.fullName, 'John');
      expect(entity.userId, isNull);
      expect(entity.password, isNull);
      expect(entity.confirmPassword, isNull);
    });

    test('should create AuthEntity with all fields', () {
      const entity = AuthEntity(
        userId: '123',
        email: 'a@b.com',
        fullName: 'John Doe',
        password: 'pass',
        confirmPassword: 'pass',
      );
      expect(entity.userId, '123');
      expect(entity.password, 'pass');
      expect(entity.confirmPassword, 'pass');
    });

    test('two entities with same values should be equal', () {
      const e1 = AuthEntity(email: 'a@b.com', fullName: 'John');
      const e2 = AuthEntity(email: 'a@b.com', fullName: 'John');
      expect(e1, equals(e2));
    });

    test('two entities with different values should not be equal', () {
      const e1 = AuthEntity(email: 'a@b.com', fullName: 'John');
      const e2 = AuthEntity(email: 'x@y.com', fullName: 'Jane');
      expect(e1, isNot(equals(e2)));
    });

    test('props should contain all fields', () {
      const entity = AuthEntity(
        userId: '1',
        email: 'a@b.com',
        fullName: 'John',
        password: 'p',
        confirmPassword: 'p',
      );
      expect(entity.props, ['1', 'John', 'a@b.com', 'p', 'p']);
    });
  });
}
