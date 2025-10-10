


import 'package:flutter/material.dart';
import 'package:mobile_attendance_application/data/local_storage/local_storage_impl.dart';
import 'package:mobile_attendance_application/presentation/admin/admin_dashboard.dart';
import 'package:mobile_attendance_application/domain/repositories/user/user_home_screen.dart';
import 'package:mobile_attendance_application/data/repositories/attendance_repository_impl.dart';
import 'package:mobile_attendance_application/presentation/auth/role_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  final LocalStorageImpl storage;
  const SplashScreen({super.key, required this.storage});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await Future.delayed(const Duration(seconds: 2));

    final user = await widget.storage.getCurrentUser();
    final role = await widget.storage.getSelectedRole();
    final repo = AttendanceRepositoryImpl(localStorage: widget.storage);

    if (user != null) {
      if (user.role == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => AdminDashboard(user: user, repository: repo),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => UserHomeScreen(user: user, repository: repo),
          ),
        );
      }
    } else if (role != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RoleSelectionScreen(storage: widget.storage),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RoleSelectionScreen(storage: widget.storage),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
