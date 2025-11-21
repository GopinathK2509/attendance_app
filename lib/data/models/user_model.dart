
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String? id;
  final String? userId;
  final String? name;
  final String? email;
  final String? password;
  final String? department;
  final String? role;

  UserModel({
    this.id,
    this.userId,
    this.name,
    this.email,
    this.password,
    this.department,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

