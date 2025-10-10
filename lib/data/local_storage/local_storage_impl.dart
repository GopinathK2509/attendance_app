


import 'package:hive/hive.dart';
import '../../data/models/user_model.dart';
import '../../data/models/attendance_model.dart';
import 'package:flutter/material.dart';

class LocalStorageImpl {
  late Box<UserModel> userBox;
  late Box appBox;
  late Box<AttendanceModel> attendanceBox;

  static const String _currentUserKey = 'current_user_id';
  static const String _selectedRoleKey = 'selected_role';

  Future<void> init() async {
    userBox = Hive.box<UserModel>('users');
    appBox = Hive.box('app_data');
    attendanceBox = Hive.box<AttendanceModel>('attendance');
  }

  Future<void> saveUser(UserModel user) async {
    await userBox.put(user.id, user);
  }

  Future<void> saveCurrentUser(UserModel user) async {
    await appBox.put(_currentUserKey, user.id);
  }

  Future<UserModel?> getCurrentUser() async {
    final id = appBox.get(_currentUserKey);
    if (id == null) return null;
    return userBox.get(id);
  }

  Future<void> clearCurrentUser() async {
    await appBox.delete(_currentUserKey);
  }

  UserModel? getUserByEmailAndRole(String email, String role) {
    try {
      return userBox.values.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase() && u.role == role,
      );
    } catch (e) {
      return null;
    }
  }


  Future<void> saveSelectedRole(String role) async {
    await appBox.put(_selectedRoleKey, role);
  }

  Future<String?> getSelectedRole() async {
    return appBox.get(_selectedRoleKey);
  }

  Future<void> clearSelectedRole() async {
    await appBox.delete(_selectedRoleKey);
  }


  Future<void> saveAttendance(AttendanceModel attendance) async {
    await attendanceBox.put(attendance.id, attendance);
  }

  Future<void> updateAttendance(AttendanceModel attendance) async {
    await attendanceBox.put(attendance.id, attendance);
  }

  Future<List<AttendanceModel>> getUserAttendance(String userId, [DateTimeRange? dateRange]) async {
    var records = attendanceBox.values.where((a) => a.userId == userId).toList();

    if (dateRange != null) {
      records = records.where((record) =>
        record.checkInTime.isAfter(dateRange.start) && record.checkInTime.isBefore(dateRange.end)
      ).toList();
    }

    records.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
    return records;
  }

  Future<List<AttendanceModel>> getAllAttendance({DateTimeRange? dateRange, String? department}) async {
    var records = attendanceBox.values.toList();

    if (department != null) {
      records = records.where((r) => r.department == department).toList();
    }

    if (dateRange != null) {
      records = records.where((r) =>
        r.checkInTime.isAfter(dateRange.start) && r.checkInTime.isBefore(dateRange.end)
      ).toList();
    }

    records.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));
    return records;
  }

  Future<AttendanceModel?> getCurrentAttendance(String userId) async {
    try {
      return attendanceBox.values.firstWhere((r) => r.userId == userId && r.checkOutTime == null);
    } catch (e) {
      return null;
    }
  }
}
