import 'package:cine_stream/features/dashboard/userprofile/domain/entities/profile_entity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileEntity', () {
    test('should create with all null optional fields', () {
      const entity = ProfileEntity();
      expect(entity.userId, isNull);
      expect(entity.fullName, isNull);
      expect(entity.email, isNull);
      expect(entity.phoneNumber, isNull);
      expect(entity.location, isNull);
      expect(entity.profileImage, isNull);
    });

    test('should create with all fields populated', () {
      const entity = ProfileEntity(
        userId: '123',
        fullName: 'John Doe',
        email: 'john@example.com',
        phoneNumber: '+1234567890',
        location: 'New York',
        profileImage: 'http://example.com/pic.jpg',
      );
      expect(entity.userId, '123');
      expect(entity.fullName, 'John Doe');
      expect(entity.email, 'john@example.com');
      expect(entity.phoneNumber, '+1234567890');
      expect(entity.location, 'New York');
      expect(entity.profileImage, 'http://example.com/pic.jpg');
    });

    test('two entities with same values should be equal', () {
      const e1 = ProfileEntity(userId: '1', fullName: 'John');
      const e2 = ProfileEntity(userId: '1', fullName: 'John');
      expect(e1, equals(e2));
    });

    test('two entities with different values should not be equal', () {
      const e1 = ProfileEntity(userId: '1', fullName: 'John');
      const e2 = ProfileEntity(userId: '2', fullName: 'Jane');
      expect(e1, isNot(equals(e2)));
    });

    test('props should contain all fields', () {
      const entity = ProfileEntity(
        userId: '1',
        fullName: 'John',
        email: 'a@b.com',
        phoneNumber: '123',
        location: 'NYC',
        profileImage: 'pic.jpg',
      );
      expect(entity.props, ['1', 'John', 'a@b.com', '123', 'NYC', 'pic.jpg']);
    });
  });
}
