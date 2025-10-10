

import 'package:flutter/material.dart';
import 'package:mobile_attendance_application/data/local_storage/local_storage_impl.dart';
import 'package:mobile_attendance_application/data/repositories/attendance_repository_impl.dart';
import 'package:mobile_attendance_application/domain/repositories/user/user_home_screen.dart';
import 'package:mobile_attendance_application/presentation/admin/admin_dashboard.dart';
import 'package:mobile_attendance_application/presentation/auth/register_screen.dart';

class LoginScreen extends StatefulWidget {
  final String role;
  final LocalStorageImpl storage;
  final AttendanceRepositoryImpl repository;

  const LoginScreen({
    super.key,
    required this.role,
    required this.storage,
    required this.repository,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    final email = _emailController.text.trim();

    final user = widget.storage.getUserByEmailAndRole(email, widget.role);

    await Future.delayed(const Duration(seconds: 1));

    setState(() => _isLoading = false);

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('User not found')));
    } else {
      await widget.storage.saveCurrentUser(user);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => user.role == 'admin'
              ? AdminDashboard(user: user, repository: widget.repository)
              : UserHomeScreen(user: user, repository: widget.repository),
        ),
      );
    }
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterScreen(
          role: widget.role,
          storage: widget.storage,
          repository: widget.repository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = widget.role == 'admin';
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              elevation: 12,
              shadowColor: Colors.black54,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      '${isAdmin ? 'Admin' : 'User'} Login',
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6A11CB),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Colors.deepPurple,
                        shadowColor: Colors.black54,
                        elevation: 8,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: _goToRegister,
                      child: const Text(
                        'Create an account',
                        style: TextStyle(
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
