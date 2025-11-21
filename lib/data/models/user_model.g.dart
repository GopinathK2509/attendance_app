// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      name: json['name'] as String,
      email: json['email'] as String,
      password: json['password'] as String?,
      department: json['department'] as String?,
      role: json['role'] as String,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'email': instance.email,
      'password': instance.password,
      'department': instance.department,
      'role': instance.role,
    };
