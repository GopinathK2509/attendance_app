
import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String email;

  @HiveField(3)
  String role; 

  @HiveField(4)
  String? department;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.department,
  });
}
