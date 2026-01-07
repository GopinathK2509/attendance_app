// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:mobile_attendance_application/presentation/widgets/logout_dialog.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AdminUserListScreen extends StatefulWidget {
//   const AdminUserListScreen({super.key});

//   @override
//   State<AdminUserListScreen> createState() => _AdminUserListScreenState();
// }

// class _AdminUserListScreenState extends State<AdminUserListScreen> {
//   bool isLoading = true;
//   List users = [];

//   String userId = '';
//   String name = '';
//   String email = '';
//   String department = '';
//   String role = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadAdminInfo();
//     fetchUsers();
//   }

//   Future<void> _loadAdminInfo() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       userId = prefs.getString('userId') ?? '';
//       name = prefs.getString('name') ?? '';
//       email = prefs.getString('email') ?? '';
//       department = prefs.getString('department') ?? '';
//       role = prefs.getString('role') ?? '';
//     });
//   }

//   Future<void> fetchUsers() async {
//     try {
//       final response = await http.get(
//         Uri.parse(
//           'https://trainerattendence-backed.onrender.com/api/users/all',
//         ),
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           users = data;
//           isLoading = false;
//         });
//       } else {
//         throw Exception('Failed to load users');
//       }
//     } catch (e) {
//       setState(() => isLoading = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Error: $e')));
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: ShaderMask(
//           shaderCallback: (bounds) => const LinearGradient(
//             colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//             begin: Alignment.centerLeft,
//             end: Alignment.centerRight,
//           ).createShader(bounds),
//           child: const Text(
//             '👥 Registered Users',
//             style: TextStyle(
//               fontWeight: FontWeight.bold,
//               fontSize: 22,
//               color: Colors.white,
//               letterSpacing: 1.2,
//             ),
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 10,
//         centerTitle: true,
//         iconTheme: const IconThemeData(color: Color(0xFF6A11CB)),
//         shadowColor: Colors.deepPurpleAccent.withOpacity(0.3),
//         actions: [
//           IconButton(
//             icon: const Icon(
//               Icons.refresh_rounded,
//               color: Color(0xFF6A11CB),
//               size: 28,
//             ),
//             tooltip: 'Refresh User List',
//             onPressed: fetchUsers,
//           ),
//         ],
//         shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.vertical(bottom: Radius.circular(18)),
//         ),
//       ),

//       drawer: Drawer(
//         child: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//           child: ListView(
//             padding: EdgeInsets.zero,
//             children: [
//               DrawerHeader(
//                 decoration: const BoxDecoration(color: Colors.transparent),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const CircleAvatar(
//                       radius: 30,
//                       backgroundColor: Colors.white,
//                       child: Icon(
//                         Icons.admin_panel_settings,
//                         color: Color(0xFF6A11CB),
//                         size: 35,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       name,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 1.1,
//                       ),
//                     ),
//                     const SizedBox(height: 5),
//                     Text(
//                       email,
//                       style: const TextStyle(
//                         color: Colors.white70,
//                         fontSize: 14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               ListTile(
//                 leading: const Icon(Icons.dashboard, color: Colors.white),
//                 title: const Text(
//                   'Dashboard',
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//                 onTap: () {
//                   // Navigator.pushAndRemoveUntil(
//                   //   context,
//                   //   MaterialPageRoute(builder: (_) => AdminDashboardScreen()),
//                   //   (route) => false,
//                   // );

//                   Navigator.pushNamedAndRemoveUntil(
//                     context,
//                     '/adminDashboard',
//                     (route) => false,
//                   );
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.people, color: Colors.white),
//                 title: const Text(
//                   'All Users',
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//                 onTap: () {
//                   Navigator.pushNamed(context, '/adminList');
//                 },
//               ),
//               ListTile(
//                 leading: const Icon(Icons.calendar_today, color: Colors.white),
//                 title: const Text(
//                   'Attendance Records',
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//                 onTap: () {
//                   Navigator.pushNamed(context, '/adminAttendanceHistory');
//                 },
//               ),
//               const Divider(
//                 color: Colors.white54,
//                 thickness: 1,
//                 indent: 12,
//                 endIndent: 12,
//               ),
//               ListTile(
//                 leading: const Icon(Icons.logout, color: Colors.white),
//                 title: const Text(
//                   "Logout",
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 onTap: () async {
//                   // final prefs = await SharedPreferences.getInstance();
//                   // await prefs.clear();
//                   // Navigator.pushNamedAndRemoveUntil(
//                   //   context,
//                   //   '/login',
//                   //   (route) => false,
//                   // );
//                   LogoutDialog.show(context);
//                 },
//               ),
//             ],
//           ),
//         ),
//       ),

//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//         ),
//         child: isLoading
//             ? const Center(
//                 child: CircularProgressIndicator(color: Colors.white),
//               )
//             : RefreshIndicator(
//                 onRefresh: fetchUsers,
//                 child: users.isEmpty
//                     ? const Center(
//                         child: Text(
//                           'No users found',
//                           style: TextStyle(color: Colors.white, fontSize: 18),
//                         ),
//                       )
//                     : ListView.builder(
//                         padding: const EdgeInsets.all(16),
//                         itemCount: users.length,
//                         itemBuilder: (context, index) {
//                           final user = users[index];
//                           final name = user['name'] ?? 'Unknown';
//                           final email = user['email'] ?? 'No email';
//                           final department =
//                               user['department'] ?? 'No department';
//                           final role = (user['role'] ?? 'user')
//                               .toString()
//                               .trim()
//                               .toLowerCase();

//                           return Container(
//                             margin: const EdgeInsets.symmetric(vertical: 8),
//                             decoration: BoxDecoration(
//                               color: Colors.white.withOpacity(0.15),
//                               borderRadius: BorderRadius.circular(16),
//                               border: Border.all(
//                                 color: Colors.white.withOpacity(0.2),
//                               ),
//                               boxShadow: [
//                                 BoxShadow(
//                                   color: Colors.black.withOpacity(0.2),
//                                   blurRadius: 6,
//                                   offset: const Offset(0, 3),
//                                 ),
//                               ],
//                             ),
//                             child: ListTile(
//                               contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 12,
//                               ),
//                               leading: CircleAvatar(
//                                 radius: 26,
//                                 backgroundColor: Colors.white.withOpacity(0.3),
//                                 child: Text(
//                                   name.isNotEmpty ? name[0].toUpperCase() : '?',
//                                   style: const TextStyle(
//                                     fontSize: 22,
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ),
//                               title: Text(
//                                 name,
//                                 style: const TextStyle(
//                                   fontWeight: FontWeight.bold,
//                                   color: Colors.white,
//                                   fontSize: 18,
//                                 ),
//                               ),
//                               subtitle: Padding(
//                                 padding: const EdgeInsets.only(top: 6.0),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       email,
//                                       style: TextStyle(
//                                         color: Colors.white.withOpacity(0.9),
//                                       ),
//                                     ),
//                                     const SizedBox(height: 4),
//                                     Text(
//                                       department,
//                                       style: TextStyle(
//                                         color: Colors.white.withOpacity(0.7),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               trailing: Container(
//                                 padding: const EdgeInsets.symmetric(
//                                   horizontal: 10,
//                                   vertical: 6,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   color: role == 'admin'
//                                       ? Colors.amber
//                                       : Colors.greenAccent.shade400,
//                                   borderRadius: BorderRadius.circular(12),
//                                 ),
//                                 child: Text(
//                                   department.toUpperCase(),
//                                   style: const TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.black87,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//               ),
//       ),
//     );
//   }
// }

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_attendance_application/presentation/widgets/logout_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminUserListScreen extends StatefulWidget {
  const AdminUserListScreen({super.key});

  @override
  State<AdminUserListScreen> createState() => _AdminUserListScreenState();
}

class _AdminUserListScreenState extends State<AdminUserListScreen> {
  bool isLoading = true;
  List users = [];
  List filteredUsers = [];

  String searchQuery = "";
  String sortBy = "A-Z";

  String userId = '';
  String name = '';
  String email = '';
  String department = '';
  String role = '';

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
    fetchUsers();
  }

  Future<void> _loadAdminInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userId = prefs.getString('userId') ?? '';
      name = prefs.getString('name') ?? '';
      email = prefs.getString('email') ?? '';
      department = prefs.getString('department') ?? '';
      role = prefs.getString('role') ?? '';
    });
  }

  Future<void> fetchUsers() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://trainerattendence-backed.onrender.com/api/users/all',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          users = data;
          filteredUsers = data;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load users');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  void filterUsers(String query) {
    searchQuery = query.toLowerCase();

    setState(() {
      filteredUsers = users.where((user) {
        final name = (user['name'] ?? '').toLowerCase();
        final email = (user['email'] ?? '').toLowerCase();
        final dept = (user['department'] ?? '').toLowerCase();
        return name.contains(searchQuery) ||
            email.contains(searchQuery) ||
            dept.contains(searchQuery);
      }).toList();

      sortUsers();
    });
  }

  void sortUsers() {
    setState(() {
      if (sortBy == "A-Z") {
        filteredUsers.sort(
          (a, b) => (a['name'] ?? '').toLowerCase().compareTo(
            (b['name'] ?? '').toLowerCase(),
          ),
        );
      } else {
        filteredUsers.sort(
          (a, b) => (b['name'] ?? '').toLowerCase().compareTo(
            (a['name'] ?? '').toLowerCase(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gradientBG = const LinearGradient(
      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: ShaderMask(
          shaderCallback: (bounds) => gradientBG.createShader(bounds),
          child: Text(
            'Registered Users',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black,
              letterSpacing: 1.2,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      drawer: _buildDrawer(),

      body: Container(
        decoration: BoxDecoration(gradient: gradientBG),
        child: Column(
          children: [
            const SizedBox(height: 110),

            _buildSearchAndSortBar(),

            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : filteredUsers.isEmpty
                  ? const Center(
                      child: Text(
                        'No users found',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchUsers,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return _buildUserCard(user);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ========================= UI COMPONENTS ============================

  Widget _buildDrawer() {
    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      size: 35,
                      color: Color(0xFF6A11CB),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(email, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),

            _drawerItem(Icons.dashboard, "Dashboard", '/adminDashboard'),
            _drawerItem(Icons.people, "All Users", '/adminList'),
            _drawerItem(
              Icons.calendar_month,
              "Attendance",
              '/adminAttendanceHistory',
            ),

            const Divider(color: Colors.white54),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => LogoutDialog.show(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, String route) {
    return ListTile(
      leading: Icon(icon, color: Colors.white),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }

  Widget _buildSearchAndSortBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // SEARCH BAR
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                onChanged: filterUsers,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Search users...",
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.white),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          // SORT DROPDOWN
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButton<String>(
              value: sortBy,
              underline: const SizedBox(),
              iconEnabledColor: Colors.white,
              dropdownColor: Colors.blue.shade600,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              items: const [
                DropdownMenuItem(value: "A-Z", child: Text("A → Z")),
                DropdownMenuItem(value: "Z-A", child: Text("Z → A")),
              ],
              onChanged: (val) {
                setState(() {
                  sortBy = val!;
                  sortUsers();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(dynamic user) {
    final name = user['name'] ?? 'Unknown';
    final email = user['email'] ?? 'No email';
    final department = user['department'] ?? 'No department';
    final role = (user['role'] ?? 'user').toString();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 350),
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        // backdropFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      ),
      child: Row(
        children: [
          // PROFILE AVATAR
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white.withOpacity(0.3),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "?",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(width: 14),

          // DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: TextStyle(color: Colors.white.withOpacity(0.9)),
                ),
                const SizedBox(height: 2),
                Text(
                  department,
                  style: TextStyle(color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),

          // ROLE BADGE
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: role == "admin" ? Colors.amber : Colors.greenAccent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              role.toUpperCase(),
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
