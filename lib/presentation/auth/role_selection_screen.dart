
import 'package:flutter/material.dart';
import 'package:mobile_attendance_application/core/themes/role_card.dart';
import 'package:mobile_attendance_application/data/local_storage/local_storage_impl.dart';
import 'package:mobile_attendance_application/presentation/auth/login_screen.dart';
import 'package:mobile_attendance_application/data/repositories/attendance_repository_impl.dart';

class RoleSelectionScreen extends StatelessWidget {
  final LocalStorageImpl storage;
  const RoleSelectionScreen({super.key, required this.storage});

  void _selectRole(BuildContext context, String role) async {
    await storage.saveSelectedRole(role);
    final repo = AttendanceRepositoryImpl(localStorage: storage);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            LoginScreen(role: role, storage: storage, repository: repo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Select Role',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 50),
                RoleCard(
                  icon: Icons.admin_panel_settings,
                  label: 'Admin',
                  color: Colors.deepPurple,
                  onTap: () => _selectRole(context, 'admin'),
                ),
                const SizedBox(height: 30),
                RoleCard(
                  icon: Icons.person,
                  label: 'User',
                  color: Colors.teal,
                  onTap: () => _selectRole(context, 'user'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
