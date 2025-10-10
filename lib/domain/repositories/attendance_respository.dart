
import 'package:flutter/material.dart';
import '../../data/models/attendance_model.dart';

abstract class AttendanceRepository {
  Future<AttendanceModel> checkIn(Location location);
  Future<AttendanceModel> checkOut(Location location);
  Future<List<AttendanceModel>> getUserAttendance(String userId, [DateTimeRange? dateRange]);
  Future<List<AttendanceModel>> getAllAttendance({DateTimeRange? dateRange, String? department});
  Future<AttendanceModel?> getCurrentAttendance(String userId);
}
