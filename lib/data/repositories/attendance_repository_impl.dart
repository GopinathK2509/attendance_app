import 'package:flutter/material.dart';
import '../../data/local_storage/local_storage_impl.dart';
import '../../data/models/attendance_model.dart';
import '../../domain/repositories/attendance_respository.dart';

class AttendanceRepositoryImpl implements AttendanceRepository {
  final LocalStorageImpl localStorage;

  AttendanceRepositoryImpl({required this.localStorage});

  @override
  Future<AttendanceModel> checkIn(Location location) async {
    final user = await localStorage.getCurrentUser();
    if (user == null) throw Exception('User not logged in');

    final attendance = AttendanceModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: user.id,
      userName: user.name,
      department: user.department,
      checkInTime: DateTime.now(),
      checkOutTime: null,
      latitude: location.latitude,
      longitude: location.longitude,
      address: location.address,
    );

    await localStorage.saveAttendance(attendance);
    return attendance;
  }

  @override
  Future<AttendanceModel> checkOut(Location location) async {
    final user = await localStorage.getCurrentUser();
    if (user == null) throw Exception('User not logged in');

    final current = await getCurrentAttendance(user.id);
    if (current == null) {
      throw Exception('No active check-in found for this user');
    }

    current.checkOutTime = DateTime.now();
    current.latitude = location.latitude;
    current.longitude = location.longitude;
    current.address = location.address;

    await localStorage.updateAttendance(current);
    return current;
  }

  @override
  Future<List<AttendanceModel>> getUserAttendance(
    String userId, [
    DateTimeRange? dateRange,
  ]) async {
    return await localStorage.getUserAttendance(userId, dateRange);
  }

  @override
  Future<List<AttendanceModel>> getAllAttendance({
    DateTimeRange? dateRange,
    String? department,
  }) async {
    return await localStorage.getAllAttendance(
      dateRange: dateRange,
      department: department,
    );
  }

  @override
  Future<AttendanceModel?> getCurrentAttendance(String userId) async {
    return await localStorage.getCurrentAttendance(userId);
  }
}
