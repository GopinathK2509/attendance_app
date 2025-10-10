import 'package:hive/hive.dart';

part 'attendance_model.g.dart';

@HiveType(typeId: 0)
class AttendanceModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String userName;

  @HiveField(3)
  String? department;

  @HiveField(4)
  DateTime checkInTime;

  @HiveField(5)
  DateTime? checkOutTime;

  @HiveField(6)
  double? latitude;

  @HiveField(7)
  double? longitude;

  @HiveField(8)
  String? address;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.department,
    required this.checkInTime,
    this.checkOutTime,
    this.latitude,
    this.longitude,
    this.address,
  });

  Duration get duration => checkOutTime != null
      ? checkOutTime!.difference(checkInTime)
      : DateTime.now().difference(checkInTime);
}

class Location {
  final double latitude;
  final double longitude;
  final String? address;

  Location({required this.latitude, required this.longitude, this.address});

  Map<String, dynamic> toJson() {
    return {'latitude': latitude, 'longitude': longitude, 'address': address};
  }

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude'],
      longitude: json['longitude'],
      address: json['address'],
    );
  }
}
