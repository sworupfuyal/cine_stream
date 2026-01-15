
import 'package:cine_stream/features/auth/domain/entities/auth_entity.dart';


class AuthApiModel {
  final String? id;
  final String fullName;
  final String email;
  final String? password;
  final String? confirmPassword;
  final String? role;

  AuthApiModel({
    this.id,
    required this.fullName,
    required this.email,
    this.password,
    this.confirmPassword,
    String? role,
  }): role = role ?? "consumer" ;

  // to json
  Map<String, dynamic> toJson() {
    return {
      "fullname": fullName,
      "email": email,
      "password": password,
      "confirmPassword": confirmPassword,
      "role": role,
    };
  }

  // from json 
  factory AuthApiModel.fromJson(Map<String,dynamic> json){
    return AuthApiModel(
      id: json["_id"] as String,
      fullName: json['fullName'] as String,
      email: json["email"] as String,
      password: json["password"] as String,
      confirmPassword: json["password"] as String,
      role: json["role"] as String
    );
  }
  // From entity
  factory AuthApiModel.fromEntity(AuthEntity entity) {
    return AuthApiModel(
      id: entity.userId,
      fullName: entity.fullName,
      email: entity.email,
      password: entity.password,
      confirmPassword: entity.confirmPassword,
    );
  }

  // To entity
  AuthEntity toEntity() {
    return AuthEntity(
      userId: id,
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  //  list of models to list of entities
  static List<AuthEntity> toEntityList(List<AuthApiModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}