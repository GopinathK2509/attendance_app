// import 'package:flutter/material.dart';
// import 'package:mobile_attendance_application/presentation/auth/splash_screen.dart';

// void main() {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key,});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Attendance App',
//       theme: ThemeData(primarySwatch: Colors.blue),
//       debugShowCheckedModeBanner: false,
//       home: SplashScreen(),
//     );
//   }
// }

// import 'package:flutter/material.dart';
// import 'package:mobile_attendance_application/presentation/admin/admin_attendance_view.dart';
// import 'package:mobile_attendance_application/presentation/admin/admin_dashboard.dart';
// import 'package:mobile_attendance_application/presentation/auth/login_screen.dart';
// import 'package:mobile_attendance_application/domain/repositories/user/user_home_screen.dart';
// import 'package:mobile_attendance_application/presentation/admin/admin_user_list_screen.dart';
// import 'package:mobile_attendance_application/presentation/auth/register_screen.dart';
// import 'package:mobile_attendance_application/presentation/auth/role_selection_screen.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   final prefs = await SharedPreferences.getInstance();
//   final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
//   final role = prefs.getString('role');

//   runApp(MyApp(isLoggedIn: isLoggedIn, role: role));
// }

// class MyApp extends StatelessWidget {
//   final bool isLoggedIn;
//   final String? role;

//   const MyApp({super.key, required this.isLoggedIn, this.role});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Trainer Attendance',
//       theme: ThemeData(primarySwatch: Colors.deepPurple),
//       initialRoute: isLoggedIn
//           ? (role == 'admin' ? '/adminList' : '/userHome')
//           : '/login',
//       routes: {
//         '/login': (_) => const LoginScreen(),
//         '/userHome': (_) => const UserHomeScreen(),
//         '/adminList': (_) => const AdminUserListScreen(),
//         '/register': (context) => const RegisterScreen(),
//         '/adminDashboard': (context) => const AdminDashboardScreen(),
//         '/adminAttendanceHistory': (context) =>
//             const AdminAttendanceHistoryScreen(),
//         '/roleSelection': (_) => const RoleSelectionScreen(),
//       },
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:mobile_attendance_application/data/models/user_model.dart';
import 'package:mobile_attendance_application/presentation/admin/admin_attendance_view.dart';
import 'package:mobile_attendance_application/presentation/admin/admin_dashboard.dart';
import 'package:mobile_attendance_application/presentation/auth/login_screen.dart';
import 'package:mobile_attendance_application/domain/repositories/user/user_home_screen.dart';
import 'package:mobile_attendance_application/presentation/admin/admin_user_list_screen.dart';
import 'package:mobile_attendance_application/presentation/auth/register_screen.dart';
import 'package:mobile_attendance_application/presentation/auth/role_selection_screen.dart';
import 'package:mobile_attendance_application/presentation/auth/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trainer Attendance',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        // '/userHome': (_) => const UserHomeScreen(user: ),
        '/adminList': (_) => const AdminUserListScreen(),
        '/register': (_) => const RegisterScreen(),
        '/adminDashboard': (_) => const AdminDashboardScreen(),
        '/adminAttendanceHistory': (_) => const AdminAttendanceHistoryScreen(),
        '/roleSelection': (_) => const RoleSelectionScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/userHome') {
          final user = settings.arguments as UserModel;
          return MaterialPageRoute(builder: (_) => UserHomeScreen(user: user));
        }
        return null;
      },
    );
  }
}
