import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _departmentController = TextEditingController();

  bool _isLoading = false;
  bool _isAdmin = false;
  String _selectedRole = "user";

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final department = _departmentController.text.trim();

    if (_selectedRole == "user" && department.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your department")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse(
        "https://trainerattendence-backed.onrender.com/api/users/register",
      );

      final body = {
        "name": name,
        "email": email,
        "password": password,
        "department": _selectedRole == "admin" ? "N/A" : department,
        "role": _selectedRole,
      };

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final registeredUser = data;

        if (_selectedRole == "admin") {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', registeredUser["userId"] ?? "");
          await prefs.setString('name', registeredUser["name"] ?? "");
          await prefs.setString('email', registeredUser["email"] ?? "");
          await prefs.setString('role', registeredUser["role"] ?? "");
          await prefs.setString(
            'department',
            registeredUser["department"] ?? "",
          );
          await prefs.setBool('isLoggedIn', true);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Admin registered successfully!")),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/adminList',
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Registration successful! Please login."),
            ),
          );
          Navigator.pushReplacementNamed(context, '/login');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data["message"] ?? "Registration failed")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        _isAdmin ? 'Admin Register' : 'User Register',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Create Your Account',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A11CB),
                        ),
                      ),
                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person_outline,
                            color: Colors.deepPurple,
                          ),
                          Switch(
                            value: _isAdmin,
                            activeColor: Colors.deepPurple,
                            onChanged: (value) {
                              setState(() {
                                _isAdmin = value;
                                _selectedRole = value ? "admin" : "user";
                              });
                            },
                          ),
                          const Icon(
                            Icons.admin_panel_settings_outlined,
                            color: Colors.deepPurple,
                          ),
                        ],
                      ),
                      Text(
                        _isAdmin ? 'Admin Mode' : 'User Mode',
                        style: const TextStyle(
                          fontSize: 18,
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your name';
                          }
                          final nameRegExp = RegExp(r'^[A-Za-z\s]{3,}$');
                          if (!nameRegExp.hasMatch(value)) {
                            return 'Enter a valid name (letters only, min 3 chars)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email Address',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          final emailRegExp = RegExp(
                            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                          );
                          if (!emailRegExp.hasMatch(value)) {
                            return 'Enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          final passwordRegExp = RegExp(
                            r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
                          );
                          if (!passwordRegExp.hasMatch(value)) {
                            return 'Password must be 8+ chars with upper, lower, number & symbol';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      if (!_isAdmin)
                        TextFormField(
                          controller: _departmentController,
                          decoration: const InputDecoration(
                            labelText: 'Department',
                            prefixIcon: Icon(Icons.apartment),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (!_isAdmin && (value == null || value.isEmpty)) {
                              return 'Please enter your department';
                            }
                            return null;
                          },
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
                          elevation: 8,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : Text(
                                'Register ${_isAdmin ? 'Admin' : 'User'}',
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
    _passwordController.dispose();
    _departmentController.dispose();
    super.dispose();
  }
}
