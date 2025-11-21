// class AttendanceModel {
//   String id;
//   String userId;
//   String userName;
//   String? department;
//   DateTime checkInTime;
//   DateTime? checkOutTime;
//   double? latitude;
//   double? longitude;
//   String? address;

//   AttendanceModel({
//     required this.id,
//     required this.userId,
//     required this.userName,
//     this.department,
//     required this.checkInTime,
//     this.checkOutTime,
//     this.latitude,
//     this.longitude,
//     this.address,
//   });

//   factory AttendanceModel.fromJson(Map<String, dynamic> json) {
//     return AttendanceModel(
//       id: json['_id'] ?? json['id'] ?? '',
//       userId: json['userId'] ?? '',
//       userName: json['userName'] ?? 'Unknown',
//       department: json['department'],
//       checkInTime: DateTime.parse(json['checkInTime']),
//       checkOutTime: json['checkOutTime'] != null
//           ? DateTime.parse(json['checkOutTime'])
//           : null,
//       latitude: (json['latitude'] as num?)?.toDouble(),
//       longitude: (json['longitude'] as num?)?.toDouble(),
//       address: json['address'],
//     );
//   }

//   Map<String, dynamic> toJson() => {
//     'id': id,
//     'userId': userId,
//     'userName': userName,
//     'department': department,
//     'checkInTime': checkInTime.toIso8601String(),
//     'checkOutTime': checkOutTime?.toIso8601String(),
//     'latitude': latitude,
//     'longitude': longitude,
//     'address': address,
//   };

//   Duration get duration => checkOutTime != null
//       ? checkOutTime!.difference(checkInTime)
//       : DateTime.now().difference(checkInTime);
// }

class AttendanceModel {
  String id;
  String userId;
  String userName;
  String? department;
  DateTime checkInTime;
  DateTime? checkOutTime;

  double? checkInLatitude;
  double? checkInLongitude;
  String? checkInAddress;

  double? checkOutLatitude;
  double? checkOutLongitude;
  String? checkOutAddress;
  bool? checkInMode;
  bool? checkOutMode;

  AttendanceModel({
    required this.id,
    required this.userId,
    required this.userName,
    this.department,
    required this.checkInTime,
    this.checkOutTime,
    this.checkInLatitude,
    this.checkInLongitude,
    this.checkInAddress,
    this.checkOutLatitude,
    this.checkOutLongitude,
    this.checkOutAddress,
    this.checkInMode,
    this.checkOutMode,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? 'Unknown',
      department: json['department'],
      checkInTime: DateTime.parse(json['checkInTime']),
      checkOutTime: json['checkOutTime'] != null
          ? DateTime.parse(json['checkOutTime'])
          : null,
      checkInLatitude: (json['checkInLatitude'] as num?)?.toDouble(),
      checkInLongitude: (json['checkInLongitude'] as num?)?.toDouble(),
      checkInAddress: json['checkInAddress'],
      checkOutLatitude: (json['checkOutLatitude'] as num?)?.toDouble(),
      checkOutLongitude: (json['checkOutLongitude'] as num?)?.toDouble(),
      checkOutAddress: json['checkOutAddress'],
      checkInMode: json['checkInMode'],

      checkOutMode: json['checkOutMode'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'userName': userName,
    'department': department,
    'checkInTime': checkInTime.toIso8601String(),
    'checkOutTime': checkOutTime?.toIso8601String(),
    'checkInLatitude': checkInLatitude,
    'checkInLongitude': checkInLongitude,
    'checkInAddress': checkInAddress,
    'checkOutLatitude': checkOutLatitude,
    'checkOutLongitude': checkOutLongitude,
    'checkOutAddress': checkOutAddress,
    'checkInMode': checkInMode,
    "checkOutMode": checkOutMode,
  };

  Duration get duration => checkOutTime != null
      ? checkOutTime!.difference(checkInTime)
      : DateTime.now().difference(checkInTime);
}
