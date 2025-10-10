
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_attendance_application/bloc/attendance/attendance_bloc.dart';
import 'package:mobile_attendance_application/bloc/attendance/attendance_events.dart';
import 'package:mobile_attendance_application/data/models/user_model.dart';
import 'package:mobile_attendance_application/data/repositories/attendance_repository_impl.dart';
import 'user_attendance_view.dart';

class UserDashboard extends StatelessWidget {
  final UserModel user;
  final AttendanceRepositoryImpl repository;

  const UserDashboard({
    super.key,
    required this.user,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Welcome, ${user.name}')),
      body: BlocProvider(
        create: (_) => AttendanceBloc(attendanceRepository: repository)
          ..add(LoadAttendanceEvent(userId: user.id)),
        child: UserAttendanceView(user: user, repository: repository),
      ),
    );
  }
}
