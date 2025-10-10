import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:mobile_attendance_application/data/models/attendance_model.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object> get props => [];
}

class CheckInEvent extends AttendanceEvent {
  final Location location;

  const CheckInEvent({required this.location});

  @override
  List<Object> get props => [location];
}

class CheckOutEvent extends AttendanceEvent {
  final Location location;

  const CheckOutEvent({required this.location});

  @override
  List<Object> get props => [location];
}

class LoadAttendanceEvent extends AttendanceEvent {
  final String userId;
  final DateTimeRange? dateRange;

  const LoadAttendanceEvent({required this.userId, this.dateRange});

  @override
  List<Object> get props => [userId];
}

class LoadAllAttendanceEvent extends AttendanceEvent {
  final DateTimeRange? dateRange;
  final String? department;

  const LoadAllAttendanceEvent({this.dateRange, this.department});

  @override
  List<Object> get props => [];
}