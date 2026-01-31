import 'package:cine_stream/core/error/failures.dart';
import 'package:cine_stream/features/auth/domain/entities/auth_entity.dart';
import 'package:cine_stream/features/auth/domain/repositories/auth_repository.dart';
import 'package:cine_stream/features/auth/domain/usecases/login_usecases.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';


class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late LoginUsecase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = LoginUsecase(authRepository: mockRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';

  const tUser = AuthEntity(
    fullName: 'Test User',
    email: tEmail,
  );

  group('LoginUsecase', () {
    test('should return AuthEntity when login is successful', () async {
      when(
        () => mockRepository.loginUser(tEmail, tPassword),
      ).thenAnswer((_) async => const Right(tUser));

      final result = await usecase(
        const LoginUsecasesParams(email: tEmail, password: tPassword),
      );

      expect(result, const Right(tUser));
      verify(() => mockRepository.loginUser(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return failure when login fails', () async {
     
      const failure = ServerFailure(message: 'Invalid credentials');
      when(
        () => mockRepository.loginUser(tEmail, tPassword),
      ).thenAnswer((_) async => const Left(failure));

     
      final result = await usecase(
        const LoginUsecasesParams(email: tEmail, password: tPassword),
      );

      
      expect(result, const Left(failure));
      verify(() => mockRepository.loginUser(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return NetworkFailure when there is no internet', () async {
      const failure = ServerFailure(message: 'No internet connection');
      when(
        () => mockRepository.loginUser(tEmail, tPassword),
      ).thenAnswer((_) async => const Left(failure));

    
      final result = await usecase(
        const LoginUsecasesParams(email: tEmail, password: tPassword),
      );

      
      expect(result, const Left(failure));
      verify(() => mockRepository.loginUser(tEmail, tPassword)).called(1);
    });

    test('should pass correct email and password to repository', () async {
       
      when(
        () => mockRepository.loginUser(any(), any()),
      ).thenAnswer((_) async => const Right(tUser));

      await usecase(const LoginUsecasesParams(email: tEmail, password: tPassword));

  
      verify(() => mockRepository.loginUser(tEmail, tPassword)).called(1);
    });

    test(
      'should succeed with correct credentials and fail with wrong credentials',
      () async {
        const wrongEmail = 'wrong@example.com';
        const wrongPassword = 'wrongpassword';
        const failure = ServerFailure(message: 'Invalid credentials');

        when(() => mockRepository.loginUser(any(), any())).thenAnswer((
          invocation,
        ) async {
          final email = invocation.positionalArguments[0] as String;
          final password = invocation.positionalArguments[1] as String;

          if (email == tEmail && password == tPassword) {
            return const Right(tUser);
          }
          return const Left(failure);
        });

        final successResult = await usecase(
          const LoginUsecasesParams (email: tEmail, password: tPassword),
        );
        expect(successResult, const Right(tUser));

        final wrongEmailResult = await usecase(
          const LoginUsecasesParams (email: wrongEmail, password: tPassword),
        );
        expect(wrongEmailResult, const Left(failure));

        final wrongPasswordResult = await usecase(
          const LoginUsecasesParams(email: tEmail, password: wrongPassword),
        );
        expect(wrongPasswordResult, const Left(failure));
      },
    );
  });

}