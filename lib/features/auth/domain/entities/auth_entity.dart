import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String email;
  final String fullName;
  final String? password;
  final String? confirmPassword;

  const AuthEntity({
    this.userId,
    required this.email,
    this.password, required this.fullName, this.confirmPassword,
  });
  @override
  List<Object?> get props => [userId, fullName, email, password, confirmPassword];
}