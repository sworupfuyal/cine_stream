import 'package:cine_stream/core/error/failures.dart';
import 'package:cine_stream/features/dashboard/userprofile/data/datasources/user_profile_datasource.dart';
import 'package:cine_stream/features/dashboard/userprofile/data/models/profile_api_model.dart';
import 'package:cine_stream/features/dashboard/userprofile/data/repositories/user_profile_repository.dart';
import 'package:cine_stream/features/dashboard/userprofile/domain/entities/profile_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockUserProfileRemoteDatasource extends Mock
    implements IUserProfileRemoteDatasource {}

void main() {
  late UserProfileRepository repository;
  late MockUserProfileRemoteDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockUserProfileRemoteDatasource();
    repository = UserProfileRepository(
      userProfileRemoteDatasource: mockDatasource,
    );
  });

  final tProfileModel = ProfileApiModel(
    userId: '123',
    fullName: 'John Doe',
    email: 'john@example.com',
    phoneNumber: '+1234567890',
    location: 'NYC',
    profileImage: 'pic.jpg',
  );

  group('getUserDetails', () {
    test('should return ProfileEntity on success', () async {
      when(() => mockDatasource.getUserProfile())
          .thenAnswer((_) async => tProfileModel);

      final result = await repository.getUserDetails();

      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should be Right'),
        (r) {
          expect(r, isA<ProfileEntity>());
          expect(r.fullName, 'John Doe');
          expect(r.email, 'john@example.com');
        },
      );
    });

    test('should return ServerFailure on exception', () async {
      when(() => mockDatasource.getUserProfile())
          .thenThrow(Exception('Server down'));

      final result = await repository.getUserDetails();

      expect(result.isLeft(), true);
      result.fold(
        (l) => expect(l, isA<ServerFailure>()),
        (r) => fail('Should be Left'),
      );
    });
  });

}
