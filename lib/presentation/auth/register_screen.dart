import 'package:flutter/material.dart';
import 'package:mobile_attendance_application/data/local_storage/local_storage_impl.dart';
import 'package:mobile_attendance_application/data/models/user_model.dart';
import 'package:mobile_attendance_application/data/repositories/attendance_repository_impl.dart';
import 'package:mobile_attendance_application/domain/repositories/user/user_home_screen.dart';
import 'package:mobile_attendance_application/presentation/admin/admin_dashboard.dart';
import 'package:uuid/uuid.dart';

class RegisterScreen extends StatefulWidget {
  final String role;
  final LocalStorageImpl storage;
  final AttendanceRepositoryImpl repository;

  const RegisterScreen({
    super.key,
    required this.role,
    required this.storage,
    required this.repository,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _departmentController = TextEditingController();

  bool _isLoading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final uuid = const Uuid().v4();

    final newUser = UserModel(
      id: uuid,
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      role: widget.role,
      department: widget.role == 'user'
          ? _departmentController.text.trim()
          : null,
    );

    await widget.storage.saveUser(newUser);
    await widget.storage.saveCurrentUser(newUser);

    setState(() => _isLoading = false);

    if (widget.role == 'admin') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              AdminDashboard(user: newUser, repository: widget.repository),
        ),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              UserHomeScreen(user: newUser, repository: widget.repository),
        ),
        (route) => false,
      );
    }
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Text(
                        'Register as ${isAdmin ? 'Admin' : 'User'}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A11CB),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your name' : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Please enter your email' : null,
                      ),
                      const SizedBox(height: 20),
                      if (!isAdmin)
                        TextFormField(
                          controller: _departmentController,
                          decoration: const InputDecoration(
                            labelText: 'Department',
                            prefixIcon: Icon(Icons.apartment),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value!.isEmpty
                              ? 'Please enter your department'
                              : null,
                        ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: _isLoading ? null : _register,
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
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Register ${isAdmin ? 'Admin' : 'User'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
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
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _departmentController.dispose();
    super.dispose();
  }
}
