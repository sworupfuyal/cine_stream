import 'package:cine_stream/features/dashboard/userprofile/domain/entities/profile_entity.dart';

class ProfileApiModel {
  final String? userId;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? location;
  final String? profileImage;

  ProfileApiModel({
    this.userId,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.location,
    this.profileImage,
  });

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "fullName": fullName,
      "email": email,
      "phoneNumber": phoneNumber,
      "userLocation": location,
      "profile_image": profileImage,
    };
  }

  factory ProfileApiModel.fromJson(Map<String, dynamic> json) {
    return ProfileApiModel(
      userId: json["userId"]?.toString(),
      fullName: json["fullName"]?.toString(),
      email: json["email"]?.toString(),
      phoneNumber: json["phoneNumber"]?.toString(),
      location: json["userLocation"]?.toString(),
      profileImage: json["profile_image"]?.toString(),
    );
  }

  ProfileEntity toEntity() {
    return ProfileEntity(
      userId: userId,
      email: email,
      fullName: fullName,
      location: location,
      phoneNumber: phoneNumber,
      profileImage: profileImage,
    );
  }

  factory ProfileApiModel.fromEntity(ProfileEntity entity) {
    return ProfileApiModel(
      userId: entity.userId,
      fullName: entity.fullName,
      email: entity.email,
      location: entity.location,
      phoneNumber: entity.phoneNumber,
      profileImage: entity.profileImage,
    );
  }

  static List<ProfileEntity> toEntityList(
    List<ProfileApiModel> models,
  ) {
    return models.map((model) => model.toEntity()).toList();
  }
}
