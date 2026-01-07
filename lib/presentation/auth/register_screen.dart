// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _departmentController = TextEditingController();
//   bool _isObscure = true;

//   bool _isLoading = false;
//   bool _isAdmin = false;
//   String _selectedRole = "user";

//   Future<void> _register() async {
//     if (!_formKey.currentState!.validate()) return;

//     final name = _nameController.text.trim();
//     final email = _emailController.text.trim();
//     final password = _passwordController.text.trim();
//     final department = _departmentController.text.trim();

//     if (_selectedRole == "user" && department.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter your department")),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final url = Uri.parse(
//         "https://trainerattendence-backed.onrender.com/api/users/register",
//       );

//       final body = {
//         "name": name,
//         "email": email,
//         "password": password,
//         "department": _selectedRole == "admin" ? "N/A" : department,
//         "role": _selectedRole,
//       };

//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final registeredUser = data;

//         if (_selectedRole == "admin") {
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setString('userId', registeredUser["userId"] ?? "");
//           await prefs.setString('name', registeredUser["name"] ?? "");
//           await prefs.setString('email', registeredUser["email"] ?? "");
//           await prefs.setString('role', registeredUser["role"] ?? "");
//           await prefs.setString(
//             'department',
//             registeredUser["department"] ?? "",
//           );
//           await prefs.setBool('isLoggedIn', true);

//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Admin registered successfully!")),
//           );
//           Navigator.pushNamedAndRemoveUntil(
//             context,
//             '/adminList',
//             (route) => false,
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Registration successful! Please login."),
//             ),
//           );
//           Navigator.pushReplacementNamed(context, '/login');
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(data["message"] ?? "Registration failed")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error: $e")));
//     } finally {
//       setState(() => _isLoading = false);
//     }
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
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     children: [
//                       Text(
//                         _isAdmin ? 'Admin Register' : 'User Register',
//                         style: const TextStyle(
//                           fontSize: 20,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.deepPurple,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       const Text(
//                         'Create Your Account',
//                         style: TextStyle(
//                           fontSize: 26,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF6A11CB),
//                         ),
//                       ),
//                       const SizedBox(height: 25),

//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Icon(
//                             Icons.person_outline,
//                             color: Colors.deepPurple,
//                           ),
//                           Switch(
//                             value: _isAdmin,
//                             activeColor: Colors.deepPurple,
//                             onChanged: (value) {
//                               setState(() {
//                                 _isAdmin = value;
//                                 _selectedRole = value ? "admin" : "user";
//                               });
//                             },
//                           ),
//                           const Icon(
//                             Icons.admin_panel_settings_outlined,
//                             color: Colors.deepPurple,
//                           ),
//                         ],
//                       ),
//                       Text(
//                         _isAdmin ? 'Admin Mode' : 'User Mode',
//                         style: const TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                           color: Color(0xFF6A11CB),
//                         ),
//                       ),

//                       const SizedBox(height: 30),

//                       TextFormField(
//                         controller: _nameController,
//                         decoration: const InputDecoration(
//                           labelText: 'Full Name',
//                           prefixIcon: Icon(Icons.person),
//                           border: OutlineInputBorder(),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your name';
//                           }
//                           final nameRegExp = RegExp(r'^[A-Za-z\s]{3,}$');
//                           if (!nameRegExp.hasMatch(value)) {
//                             return 'Enter a valid name (letters only, min 3 chars)';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 20),

//                       TextFormField(
//                         controller: _emailController,
//                         decoration: const InputDecoration(
//                           labelText: 'Email Address',
//                           prefixIcon: Icon(Icons.email),
//                           border: OutlineInputBorder(),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your email';
//                           }
//                           final emailRegExp = RegExp(
//                             r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
//                           );
//                           if (!emailRegExp.hasMatch(value)) {
//                             return 'Enter a valid email address';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 20),

//                       TextFormField(
//                         controller: _passwordController,
//                         obscureText: _isObscure,
//                         decoration: InputDecoration(
//                           labelText: 'Password',
//                           prefixIcon: Icon(Icons.lock),
//                           suffixIcon: IconButton(
//                             icon: Icon(
//                               _isObscure
//                                   ? Icons.visibility
//                                   : Icons.visibility_off,
//                             ),
//                             onPressed: () {
//                               setState(() {
//                                 _isObscure = !_isObscure;
//                               });
//                             },
//                           ),
//                           border: OutlineInputBorder(),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter a password';
//                           }
//                           final passwordRegExp = RegExp(
//                             r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
//                           );
//                           if (!passwordRegExp.hasMatch(value)) {
//                             return 'Password must be 8+ chars with upper, lower, number & symbol';
//                           }
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 20),

//                       if (!_isAdmin)
//                         TextFormField(
//                           controller: _departmentController,
//                           decoration: const InputDecoration(
//                             labelText: 'Department',
//                             prefixIcon: Icon(Icons.apartment),
//                             border: OutlineInputBorder(),
//                           ),
//                           validator: (value) {
//                             if (!_isAdmin && (value == null || value.isEmpty)) {
//                               return 'Please enter your department';
//                             }
//                             return null;
//                           },
//                         ),

//                       const SizedBox(height: 30),

//                       ElevatedButton(
//                         onPressed: _isLoading ? null : _register,
//                         style: ElevatedButton.styleFrom(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 50,
//                             vertical: 16,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(16),
//                           ),
//                           backgroundColor: Colors.deepPurple,
//                           elevation: 8,
//                         ),
//                         child: _isLoading
//                             ? const CircularProgressIndicator(
//                                 color: Colors.white,
//                               )
//                             : Text(
//                                 'Register ${_isAdmin ? 'Admin' : 'User'}',
//                                 style: const TextStyle(
//                                   fontSize: 18,
//                                   color: Colors.white,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                       ),
//                     ],
//                   ),
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
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _departmentController.dispose();
//     super.dispose();
//   }
// }

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});

//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }

// class _RegisterScreenState extends State<RegisterScreen>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _departmentController = TextEditingController();

//   bool _isObscure = true;
//   bool _isLoading = false;
//   bool _isAdmin = false;
//   String _selectedRole = "user";

//   late AnimationController _controller;
//   late Animation<double> _animation;

//   @override
//   void initState() {
//     super.initState();

//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 700),
//     );

//     _animation = CurvedAnimation(
//       parent: _controller,
//       curve: Curves.easeOutBack,
//     );

//     _controller.forward();
//   }

//   Future<void> _register() async {
//     if (!_formKey.currentState!.validate()) return;

//     final name = _nameController.text.trim();
//     final email = _emailController.text.trim();
//     final password = _passwordController.text.trim();
//     final department = _departmentController.text.trim();

//     if (_selectedRole == "user" && department.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please enter your department")),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);

//     try {
//       final url = Uri.parse(
//         "https://trainerattendence-backed.onrender.com/api/users/register",
//       );

//       final body = {
//         "name": name,
//         "email": email,
//         "password": password,
//         "department": _selectedRole == "admin" ? "N/A" : department,
//         "role": _selectedRole,
//       };

//       final response = await http.post(
//         url,
//         headers: {"Content-Type": "application/json"},
//         body: jsonEncode(body),
//       );

//       final data = jsonDecode(response.body);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         if (_selectedRole == "admin") {
//           final prefs = await SharedPreferences.getInstance();
//           await prefs.setString('userId', data["userId"] ?? "");
//           await prefs.setString('name', data["name"] ?? "");
//           await prefs.setString('email', data["email"] ?? "");
//           await prefs.setString('role', data["role"] ?? "");
//           await prefs.setString('department', data["department"] ?? "");
//           await prefs.setBool('isLoggedIn', true);

//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text("Admin registered successfully!")),
//           );

//           Navigator.pushNamedAndRemoveUntil(
//             context,
//             '/adminList',
//             (route) => false,
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text("Registration successful! Please login."),
//             ),
//           );
//           Navigator.pushReplacementNamed(context, '/login');
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(data["message"] ?? "Registration failed")),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text("Error: $e")));
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           // Background gradient
//           Container(
//             decoration: const BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//             ),
//           ),

//           // Glassmorphic animated card
//           Center(
//             child: ScaleTransition(
//               scale: _animation,
//               child: Container(
//                 margin: const EdgeInsets.all(20),
//                 padding: const EdgeInsets.all(24),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.15),
//                   borderRadius: BorderRadius.circular(28),
//                   border: Border.all(color: Colors.white30, width: 1.5),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black.withOpacity(0.2),
//                       blurRadius: 16,
//                       offset: const Offset(0, 6),
//                     ),
//                   ],
//                   //backdropFilter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
//                 ),
//                 child: Form(
//                   key: _formKey,
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       const SizedBox(height: 10),

//                       Text(
//                         _isAdmin ? "Admin Register" : "User Register",
//                         style: const TextStyle(
//                           fontSize: 22,
//                           fontWeight: FontWeight.w700,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       const Text(
//                         "Create Your Account",
//                         style: TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                       const SizedBox(height: 22),

//                       // Admin/User toggle
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 10,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white.withOpacity(0.1),
//                           borderRadius: BorderRadius.circular(20),
//                           border: Border.all(color: Colors.white30),
//                         ),
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             const Icon(
//                               Icons.person_outline,
//                               color: Colors.white,
//                               size: 26,
//                             ),
//                             Switch(
//                               value: _isAdmin,
//                               activeColor: Colors.white,
//                               activeTrackColor: Colors.deepPurpleAccent,
//                               onChanged: (value) {
//                                 setState(() {
//                                   _isAdmin = value;
//                                   _selectedRole = value ? "admin" : "user";
//                                 });
//                               },
//                             ),
//                             const Icon(
//                               Icons.admin_panel_settings,
//                               color: Colors.white,
//                               size: 26,
//                             ),
//                           ],
//                         ),
//                       ),

//                       const SizedBox(height: 10),

//                       Text(
//                         _isAdmin ? 'Admin Mode' : 'User Mode',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 17,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),

//                       const SizedBox(height: 25),

//                       // NAME
//                       _inputField(
//                         controller: _nameController,
//                         label: "Full Name",
//                         icon: Icons.person,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your name';
//                           }
//                           if (!RegExp(r'^[A-Za-z\s]{3,}$').hasMatch(value)) {
//                             return 'Enter a valid name (letters only)';
//                           }
//                           return null;
//                         },
//                       ),

//                       const SizedBox(height: 20),

//                       // EMAIL
//                       _inputField(
//                         controller: _emailController,
//                         label: "Email Address",
//                         icon: Icons.email,
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Please enter your email';
//                           }
//                           if (!RegExp(
//                             r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
//                           ).hasMatch(value)) {
//                             return 'Enter a valid email';
//                           }
//                           return null;
//                         },
//                       ),

//                       const SizedBox(height: 20),

//                       // PASSWORD
//                       _inputField(
//                         controller: _passwordController,
//                         label: "Password",
//                         icon: Icons.lock,
//                         obscure: _isObscure,
//                         suffix: IconButton(
//                           icon: Icon(
//                             _isObscure
//                                 ? Icons.visibility
//                                 : Icons.visibility_off,
//                             color: Colors.white,
//                           ),
//                           onPressed: () =>
//                               setState(() => _isObscure = !_isObscure),
//                         ),
//                         validator: (value) {
//                           if (value == null || value.isEmpty) {
//                             return 'Enter a password';
//                           }
//                           if (!RegExp(
//                             r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$',
//                           ).hasMatch(value)) {
//                             return 'Password must be 8+ chars & include symbols';
//                           }
//                           return null;
//                         },
//                       ),

//                       const SizedBox(height: 20),

//                       if (!_isAdmin)
//                         _inputField(
//                           controller: _departmentController,
//                           label: "Department",
//                           icon: Icons.apartment_rounded,
//                           validator: (value) {
//                             if (!_isAdmin && (value == null || value.isEmpty)) {
//                               return "Enter department";
//                             }
//                             return null;
//                           },
//                         ),

//                       const SizedBox(height: 28),

//                       // REGISTER BUTTON
//                       ElevatedButton(
//                         onPressed: _isLoading ? null : _register,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.deepPurpleAccent,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 50,
//                             vertical: 16,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(18),
//                           ),
//                           elevation: 10,
//                         ),
//                         child: _isLoading
//                             ? const CircularProgressIndicator(
//                                 color: Colors.white,
//                               )
//                             : Text(
//                                 "Register ${_isAdmin ? "Admin" : "User"}",
//                                 style: const TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ✨ Custom styled input field
//   Widget _inputField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     String? Function(String?)? validator,
//     Widget? suffix,
//     bool obscure = false,
//   }) {
//     return TextFormField(
//       controller: controller,
//       obscureText: obscure,
//       validator: validator,
//       style: const TextStyle(color: Colors.white, fontSize: 16),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.white70),
//         prefixIcon: Icon(icon, color: Colors.white),
//         suffixIcon: suffix,
//         filled: true,
//         fillColor: Colors.white.withOpacity(0.1),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: const BorderSide(color: Colors.white54),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: const BorderSide(color: Colors.white, width: 1.5),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _departmentController.dispose();
//     _controller.dispose();
//     super.dispose();
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _departmentController = TextEditingController();

  bool _isObscure = true;
  bool _isLoading = false;
  bool _isAdmin = false;
  String _selectedRole = "user";

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _controller.forward();
  }

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
        if (_selectedRole == "admin") {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('userId', data["userId"] ?? "");
          await prefs.setString('name', data["name"] ?? "");
          await prefs.setString('email', data["email"] ?? "");
          await prefs.setString('role', data["role"] ?? "");
          await prefs.setString('department', data["department"] ?? "");
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
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          // Scrollable content to prevent overflow
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 40,
                ),
                child: ScaleTransition(
                  scale: _animation,
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white30, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 10),

                          Text(
                            _isAdmin ? "Admin Register" : "User Register",
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Create Your Account",
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 22),

                          // Admin/User toggle
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.white30),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.person_outline,
                                  color: Colors.white,
                                  size: 26,
                                ),
                                Switch(
                                  value: _isAdmin,
                                  activeColor: Colors.white,
                                  activeTrackColor: Colors.deepPurpleAccent,
                                  onChanged: (value) {
                                    setState(() {
                                      _isAdmin = value;
                                      _selectedRole = value ? "admin" : "user";
                                    });
                                  },
                                ),
                                const Icon(
                                  Icons.admin_panel_settings,
                                  color: Colors.white,
                                  size: 26,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),
                          Text(
                            _isAdmin ? 'Admin Mode' : 'User Mode',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 25),

                          // NAME
                          _inputField(
                            controller: _nameController,
                            label: "Full Name",
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your name';
                              }
                              if (!RegExp(
                                r'^[A-Za-z\s]{3,}$',
                              ).hasMatch(value)) {
                                return 'Enter a valid name (letters only)';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // EMAIL
                          _inputField(
                            controller: _emailController,
                            label: "Email Address",
                            icon: Icons.email,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!RegExp(
                                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                              ).hasMatch(value)) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // PASSWORD
                          _inputField(
                            controller: _passwordController,
                            label: "Password",
                            icon: Icons.lock,
                            obscure: _isObscure,
                            suffix: IconButton(
                              icon: Icon(
                                _isObscure
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white,
                              ),
                              onPressed: () =>
                                  setState(() => _isObscure = !_isObscure),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Enter a password';
                              }
                              if (!RegExp(
                                r'^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[@$!%*?&]).{8,}$',
                              ).hasMatch(value)) {
                                return 'Password must be 8+ chars & include symbols';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          if (!_isAdmin)
                            _inputField(
                              controller: _departmentController,
                              label: "Department",
                              icon: Icons.apartment_rounded,
                              validator: (value) {
                                if (!_isAdmin &&
                                    (value == null || value.isEmpty)) {
                                  return "Enter department";
                                }
                                return null;
                              },
                            ),

                          const SizedBox(height: 28),

                          // REGISTER BUTTON
                          ElevatedButton(
                            onPressed: _isLoading ? null : _register,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurpleAccent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 50,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 10,
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    "Register ${_isAdmin ? "Admin" : "User"}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
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
        ],
      ),
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    Widget? suffix,
    bool obscure = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white54),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white, width: 1.5),
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
    _controller.dispose();
    super.dispose();
  }
}
