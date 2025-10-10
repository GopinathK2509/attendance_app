import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_attendance_application/bloc/attendance/attendance_bloc.dart';
import 'package:mobile_attendance_application/bloc/attendance/attendance_events.dart';
import 'package:mobile_attendance_application/data/models/user_model.dart';
import 'package:mobile_attendance_application/data/repositories/attendance_repository_impl.dart';
import 'package:mobile_attendance_application/presentation/auth/role_selection_screen.dart';
import 'admin_attendance_view.dart';

class AdminDashboard extends StatelessWidget {
  final UserModel user;
  final AttendanceRepositoryImpl repository;

  const AdminDashboard({
    super.key,
    required this.user,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard - ${user.name}'),

        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await repository.localStorage.clearCurrentUser();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      RoleSelectionScreen(storage: repository.localStorage),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: BlocProvider(
        create: (_) =>
            AttendanceBloc(attendanceRepository: repository)
              ..add(const LoadAllAttendanceEvent()),
        child: AdminAttendanceView(repository: repository),
      ),
    );
  }
}
