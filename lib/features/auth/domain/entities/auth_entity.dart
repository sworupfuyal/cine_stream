import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String? userId;
  final String userName;
  final String? password;

  const AuthEntity({
    this.userId,
    required this.userName,
    this.password,
  });
  @override
  List<Object?> get props => [userId, userName, password, ];
}