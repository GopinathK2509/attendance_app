// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:mobile_attendance_application/data/models/user_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class LoginScreen extends StatefulWidget {
//   final String? role;
//   const LoginScreen({super.key, this.role});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;
//   bool _isAdmin = false;
//   bool _isObscure = true;

//   @override
//   void initState() {
//     super.initState();
//     _isAdmin = widget.role == "admin";
//   }

//   Future<void> _login() async {
//     if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please enter email and password')),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final url = Uri.parse(
//         "https://trainerattendence-backed.onrender.com/api/users/login",
//       );

//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "email": _emailController.text.trim(),
//           "password": _passwordController.text.trim(),
//         }),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200 && data['status'] == 'success') {
//         final userJson = data['user'];
//         final user = UserModel.fromJson(userJson);

//         final prefs = await SharedPreferences.getInstance();
//         await prefs.setBool('isLoggedIn', true);
//         await prefs.setString('role', user.role!);
//         await prefs.setString('userId', user.userId!);
//         await prefs.setString('name', user.name!);
//         await prefs.setString('email', user.email!);
//         await prefs.setString('department', user.department ?? 'N/A');

//         if (_isAdmin && user.role == 'admin') {
//           Navigator.pushNamedAndRemoveUntil(
//             context,
//             '/adminList',
//             (route) => false,
//           );
//         } else if (!_isAdmin && user.role == 'user') {
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(SnackBar(content: Text('Welcome ${user.name}')));
//           Navigator.pushNamedAndRemoveUntil(
//             context,
//             '/userHome',
//             arguments: user,
//             (route) => false,
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Invalid login mode. Please check your role.'),
//             ),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(data['message'] ?? 'Invalid credentials')),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _goToRegister() {
//     Navigator.pushNamed(context, '/register');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         width: double.infinity,
//         height: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(20),
//             child: Card(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               elevation: 12,
//               shadowColor: Colors.black54,
//               child: Padding(
//                 padding: const EdgeInsets.all(24.0),
//                 child: Column(
//                   children: [
//                     Text(
//                       _isAdmin ? 'Admin Login' : 'User Login',
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.deepPurple,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     const Text(
//                       'Welcome Back',
//                       style: TextStyle(
//                         fontSize: 26,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF6A11CB),
//                       ),
//                     ),
//                     const SizedBox(height: 25),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         const Icon(
//                           Icons.person_outline,
//                           color: Colors.deepPurple,
//                         ),
//                         Switch(
//                           value: _isAdmin,
//                           activeColor: Colors.deepPurple,
//                           onChanged: (value) {
//                             setState(() => _isAdmin = value);
//                           },
//                         ),
//                         const Icon(
//                           Icons.admin_panel_settings_outlined,
//                           color: Colors.deepPurple,
//                         ),
//                       ],
//                     ),
//                     Text(
//                       _isAdmin ? 'Admin Mode' : 'User Mode',
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF6A11CB),
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     TextFormField(
//                       controller: _emailController,
//                       decoration: const InputDecoration(
//                         labelText: 'Email Address',
//                         prefixIcon: Icon(Icons.email_outlined),
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     TextFormField(
//                       controller: _passwordController,
//                       obscureText: _isObscure,
//                       decoration: InputDecoration(
//                         labelText: 'Password',
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _isObscure
//                                 ? Icons.visibility
//                                 : Icons.visibility_off,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _isObscure = !_isObscure;
//                             });
//                           },
//                         ),
//                         prefixIcon: Icon(Icons.lock_outline),
//                         border: OutlineInputBorder(),
//                       ),
//                     ),
//                     const SizedBox(height: 30),
//                     ElevatedButton(
//                       onPressed: _isLoading ? null : _login,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.deepPurple,
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 50,
//                           vertical: 16,
//                         ),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(16),
//                         ),
//                         elevation: 8,
//                       ),
//                       child: _isLoading
//                           ? const CircularProgressIndicator(color: Colors.white)
//                           : Text(
//                               'Login ${_isAdmin ? 'Admin' : 'User'}',
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 color: Colors.white,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                     ),
//                     const SizedBox(height: 20),
//                     TextButton(
//                       onPressed: _goToRegister,
//                       child: const Text(
//                         "Don't have an account? Register here",
//                         style: TextStyle(
//                           fontSize: 16,
//                           decoration: TextDecoration.underline,
//                           color: Colors.deepPurple,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_attendance_application/data/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  final String? role;
  const LoginScreen({super.key, this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isAdmin = false;
  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    _isAdmin = widget.role == "admin";
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final url = Uri.parse(
        "https://trainerattendence-backed.onrender.com/api/users/login",
      );

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        final userJson = data['user'];
        final user = UserModel.fromJson(userJson);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('role', user.role!);
        await prefs.setString('userId', user.userId!);
        await prefs.setString('name', user.name!);
        await prefs.setString('email', user.email!);
        await prefs.setString('department', user.department ?? 'N/A');

        if (_isAdmin && user.role == 'admin') {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/adminList',
            (route) => false,
          );
        } else if (!_isAdmin && user.role == 'user') {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Welcome ${user.name}')));
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/userHome',
            arguments: user,
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Invalid login mode. Please check your role.'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Invalid credentials')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _goToRegister() {
    Navigator.pushNamed(context, '/register');
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
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -40,
              child: AnimatedContainer(
                duration: const Duration(seconds: 2),
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: Colors.white.withOpacity(0.15),
                    border: Border.all(color: Colors.white24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      Text(
                        _isAdmin ? 'Admin Login' : 'User Login',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Welcome Back',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [buildRoleSwitcher()],
                      ),

                      const SizedBox(height: 25),

                      AnimatedOpacity(
                        opacity: _isLoading ? 0.4 : 1,
                        duration: const Duration(milliseconds: 300),
                        child: AbsorbPointer(
                          absorbing: _isLoading,
                          child: TextFormField(
                            controller: _emailController,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDecoration(
                              "Email Address",
                              Icons.email_outlined,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      AnimatedOpacity(
                        opacity: _isLoading ? 0.4 : 1,
                        duration: const Duration(milliseconds: 300),
                        child: AbsorbPointer(
                          absorbing: _isLoading,
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _isObscure,
                            style: const TextStyle(color: Colors.white),
                            decoration: _passwordDecoration(),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      ElevatedButton(
                        onPressed: _isLoading ? null : _login,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.deepPurple,
                                  strokeWidth: 3,
                                ),
                              )
                            : Text(
                                'Login ${_isAdmin ? 'Admin' : 'User'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),

                      const SizedBox(height: 18),

                      TextButton(
                        onPressed: _isLoading ? null : _goToRegister,
                        child: const Text(
                          "Don't have an account? Register here",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRoleSwitcher() {
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                Colors.deepPurple.withOpacity(0.4),
                Colors.deepPurple.withOpacity(0.15),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 28,
                color: _isAdmin ? Colors.white70 : Colors.white,
              ),

              const SizedBox(width: 15),

              Transform.scale(
                scale: 1.2,
                child: Switch(
                  value: _isAdmin,
                  onChanged: (v) => setState(() => _isAdmin = v),
                  activeColor: Colors.white,
                  inactiveThumbColor: Colors.white,
                  activeTrackColor: Colors.deepPurple.shade700,
                  inactiveTrackColor: Colors.grey.shade500,
                ),
              ),

              const SizedBox(width: 15),

              Icon(
                Icons.admin_panel_settings_outlined,
                size: 30,
                color: _isAdmin ? Colors.white : Colors.white60,
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        AnimatedDefaultTextStyle(
          duration: const Duration(milliseconds: 400),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: _isAdmin ? Colors.deepPurple.shade100 : Colors.white70,
            shadows: [
              Shadow(color: Colors.black.withOpacity(0.3), blurRadius: 8),
            ],
          ),
          child: Text(_isAdmin ? "Admin Mode" : "User Mode"),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white54),
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  InputDecoration _passwordDecoration() {
    return InputDecoration(
      labelText: 'Password',
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
      suffixIcon: IconButton(
        icon: Icon(
          _isObscure ? Icons.visibility : Icons.visibility_off,
          color: Colors.white,
        ),
        onPressed: _isLoading
            ? null
            : () {
                setState(() => _isObscure = !_isObscure);
              },
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white54),
        borderRadius: BorderRadius.circular(14),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Colors.white),
        borderRadius: BorderRadius.circular(14),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
