
import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String? userId;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? location;
  final String? profileImage;

  const ProfileEntity({
    this.userId,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.location,
    this.profileImage
  });

  @override
  List<Object?> get props => [userId, fullName, email, phoneNumber, location,profileImage];
}