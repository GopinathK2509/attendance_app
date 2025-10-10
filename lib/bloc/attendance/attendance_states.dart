
import 'package:equatable/equatable.dart';
import 'package:mobile_attendance_application/data/models/attendance_model.dart';

abstract class AttendanceState extends Equatable {
  const AttendanceState();

  @override
  List<Object> get props => [];
}

class AttendanceInitial extends AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceSuccess extends AttendanceState {
  final List<AttendanceModel> attendanceRecords;
  final AttendanceModel? currentAttendance;

  const AttendanceSuccess({
    required this.attendanceRecords,
    this.currentAttendance,
  });

  @override
  List<Object> get props => [attendanceRecords];
}

class AttendanceError extends AttendanceState {
  final String error;

  const AttendanceError({required this.error});

  @override
  List<Object> get props => [error];
}

class CheckInSuccess extends AttendanceState {
  final AttendanceModel attendance;

  const CheckInSuccess({required this.attendance});

  @override
  List<Object> get props => [attendance];
}

class CheckOutSuccess extends AttendanceState {
  final AttendanceModel attendance;

  const CheckOutSuccess({required this.attendance});

  @override
  List<Object> get props => [attendance];
}
