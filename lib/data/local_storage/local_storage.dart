import 'package:flutter/material.dart';
import 'package:mobile_attendance_application/data/models/attendance_model.dart';
import 'package:mobile_attendance_application/data/models/user_model.dart';

abstract class LocalStorage {
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearUser();
  
  Future<void> saveAttendance(AttendanceModel attendance);
  Future<void> updateAttendance(AttendanceModel attendance);
  Future<List<AttendanceModel>> getUserAttendance(
    String userId, [
    DateTimeRange? dateRange,
  ]);
  Future<List<AttendanceModel>> getAllAttendance({
    DateTimeRange? dateRange,
    String? department,
  });
}
