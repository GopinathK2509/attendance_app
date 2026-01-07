
// import 'package:json_annotation/json_annotation.dart';

// part 'user_model.g.dart';

// @JsonSerializable()
// class UserModel {
//   final String? id;
//   final String? userId;
//   final String? name;
//   final String? email;
//   final String? password;
//   final String? department;
//   final String? role;

//   UserModel({
//     this.id,
//     this.userId,
//     this.name,
//     this.email,
//     this.password,
//     this.department,
//     this.role,
//   });

//   factory UserModel.fromJson(Map<String, dynamic> json) =>
//       _$UserModelFromJson(json);

//   Map<String, dynamic> toJson() => _$UserModelToJson(this);
// }





class UserModel {
  final String? userId;
  final String? name;
  final String? email;
  final String? department;
  final String? role;
  final String? photoUrl; 

  UserModel({
    this.userId,
    this.name,
    this.email,
    this.department,
    this.role,
    this.photoUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId']?.toString(),
      name: json['name'] as String?,
      email: json['email'] as String?,
      department: json['department'] as String?,
      role: json['role'] as String?,
      photoUrl: json['photoUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'email': email,
        'department': department,
        'role': role,
        'photoUrl': photoUrl,
      };

  UserModel copyWith({
    String? userId,
    String? name,
    String? email,
    String? department,
    String? role,
    String? photoUrl,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email,
      department: department ?? this.department,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }
}
