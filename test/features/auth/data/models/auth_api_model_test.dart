import 'package:cine_stream/features/auth/data/models/auth_api_model.dart';
import 'package:cine_stream/features/auth/domain/entities/auth_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AuthApiModel', () {
    test('should create with required fields and default role', () {
      final model = AuthApiModel(fullName: 'John', email: 'a@b.com');
      expect(model.fullName, 'John');
      expect(model.email, 'a@b.com');
      expect(model.role, 'consumer');
      expect(model.id, isNull);
    });

    test('should create with custom role', () {
      final model = AuthApiModel(
        fullName: 'Admin',
        email: 'admin@b.com',
        role: 'admin',
      );
      expect(model.role, 'admin');
    });

    test('toJson should return correct map', () {
      final model = AuthApiModel(
        fullName: 'John',
        email: 'a@b.com',
        password: 'pass',
        confirmPassword: 'pass',
      );
      final json = model.toJson();
      expect(json['fullname'], 'John');
      expect(json['email'], 'a@b.com');
      expect(json['password'], 'pass');
      expect(json['confirmPassword'], 'pass');
      expect(json['role'], 'consumer');
    });

    test('fromJson should parse correctly', () {
      final json = {
        '_id': '123',
        'fullname': 'John',
        'email': 'a@b.com',
        'password': 'pass',
        'role': 'consumer',
      };
      final model = AuthApiModel.fromJson(json);
      expect(model.id, '123');
      expect(model.fullName, 'John');
      expect(model.email, 'a@b.com');
      expect(model.role, 'consumer');
    });

    test('toEntity should convert to AuthEntity correctly', () {
      final model = AuthApiModel(
        id: '123',
        fullName: 'John',
        email: 'a@b.com',
        password: 'pass',
      );
      final entity = model.toEntity();
      expect(entity, isA<AuthEntity>());
      expect(entity.userId, '123');
      expect(entity.fullName, 'John');
      expect(entity.email, 'a@b.com');
    });

    test('fromEntity should convert from AuthEntity correctly', () {
      const entity = AuthEntity(
        userId: '456',
        fullName: 'Jane',
        email: 'jane@b.com',
        password: 'secret',
      );
      final model = AuthApiModel.fromEntity(entity);
      expect(model.id, '456');
      expect(model.fullName, 'Jane');
      expect(model.email, 'jane@b.com');
    });

    test('toEntityList should convert list of models', () {
      final models = [
        AuthApiModel(fullName: 'A', email: 'a@a.com'),
        AuthApiModel(fullName: 'B', email: 'b@b.com'),
      ];
      final entities = AuthApiModel.toEntityList(models);
      expect(entities.length, 2);
      expect(entities[0].fullName, 'A');
      expect(entities[1].fullName, 'B');
    });
  });
}
