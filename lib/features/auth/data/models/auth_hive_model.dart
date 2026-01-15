import 'package:cine_stream/core/constants/hive_table_constant.dart';
import 'package:cine_stream/features/auth/domain/entities/auth_entity.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.authTypeId)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? userId;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? password;

  @HiveField(4)
  final String? confirmPassword;

  AuthHiveModel({
    String? userId,
    required this.fullName,
    required this.email,
    this.password,
    this.confirmPassword,
  }) : userId = userId ?? Uuid().v4();

  // From entity
  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      userId: entity.userId,
      fullName: entity.fullName,
      email: entity.email,
      password: entity.password,
      confirmPassword: entity.confirmPassword,
    );
  }

  // To entity
  AuthEntity toEntity() {
    return AuthEntity(
      userId: userId,
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );
  }

  //  list of models to list of entities
  static List<AuthEntity> toEntityList(List<AuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}