import 'package:cine_stream/features/auth/data/models/auth_hive_model.dart';
import 'package:cine_stream/features/auth/domain/entities/auth_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthHiveModel', () {
    test('should generate userId when not provided', () {
      final model = AuthHiveModel(fullName: 'John', email: 'a@b.com');
      expect(model.userId, isNotNull);
      expect(model.userId!.length, greaterThan(0));
    });

    test('should use provided userId', () {
      final model = AuthHiveModel(
        userId: 'custom-id',
        fullName: 'John',
        email: 'a@b.com',
      );
      expect(model.userId, 'custom-id');
    });

    test('toEntity should convert to AuthEntity correctly', () {
      final model = AuthHiveModel(
        userId: '123',
        fullName: 'John',
        email: 'a@b.com',
        password: 'pass',
      );
      final entity = model.toEntity();
      expect(entity, isA<AuthEntity>());
      expect(entity.userId, '123');
      expect(entity.fullName, 'John');
      expect(entity.email, 'a@b.com');
      expect(entity.password, 'pass');
    });

    test('fromEntity should convert from AuthEntity correctly', () {
      const entity = AuthEntity(
        userId: '456',
        fullName: 'Jane',
        email: 'jane@b.com',
        password: 'secret',
        confirmPassword: 'secret',
      );
      final model = AuthHiveModel.fromEntity(entity);
      expect(model.fullName, 'Jane');
      expect(model.email, 'jane@b.com');
      expect(model.password, 'secret');
      expect(model.confirmPassword, 'secret');
    });

    test('toEntityList should convert list of models', () {
      final models = [
        AuthHiveModel(fullName: 'A', email: 'a@a.com'),
        AuthHiveModel(fullName: 'B', email: 'b@b.com'),
        AuthHiveModel(fullName: 'C', email: 'c@c.com'),
      ];
      final entities = AuthHiveModel.toEntityList(models);
      expect(entities.length, 3);
      expect(entities[0].fullName, 'A');
      expect(entities[2].fullName, 'C');
    });
  });
}
