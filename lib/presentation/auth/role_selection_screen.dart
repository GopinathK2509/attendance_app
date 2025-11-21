

import 'package:flutter/material.dart';
import 'package:mobile_attendance_application/core/themes/role_card.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  void _selectRole(BuildContext context, String role) {
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
