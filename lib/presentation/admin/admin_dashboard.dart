// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:mobile_attendance_application/presentation/widgets/logout_dialog.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AdminDashboardScreen extends StatefulWidget {
//   const AdminDashboardScreen({super.key});

//   @override
//   State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
// }

// class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
//   bool _isLoading = true;
//   int totalUsers = 0;
//   int totalCheckIns = 0;
//   int pendingCheckOuts = 0;
//   List recentActivities = [];

//   String name = '';
//   String email = '';
//   String department = '';
//   String role = '';
//   String userId = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadAdminInfo();
//     _fetchDashboardData();
//   }

//   Future<void> _loadAdminInfo() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       name = prefs.getString('name') ?? '';
//       email = prefs.getString('email') ?? '';
//       department = prefs.getString('department') ?? '';
//       role = prefs.getString('role') ?? '';
//       userId = prefs.getString('userId') ?? '';
//     });
//   }

//   Future<void> _fetchDashboardData() async {
//     try {
//       final response = await http.get(
//         Uri.parse(
//           "https://trainerattendence-backed.onrender.com/api/attendance/all",
//         ),
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> attendanceList = jsonDecode(response.body);

//         setState(() {
//           totalUsers = attendanceList.map((e) => e['userId']).toSet().length;
//           totalCheckIns = attendanceList
//               .where((e) => e['checkInTime'] != null)
//               .length;
//           pendingCheckOuts = attendanceList
//               .where((e) => e['checkOutTime'] == null)
//               .length;
//           recentActivities = attendanceList.reversed.take(6).toList();
//           _isLoading = false;
//         });
//       } else {
//         setState(() => _isLoading = false);
//       }
//     } catch (e) {
//       print("❌ Error fetching dashboard data: $e");
//       setState(() => _isLoading = false);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load dashboard data: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF1E1E2C),
//       appBar: AppBar(
//         title: const Text("Admin Dashboard"),
//         backgroundColor: const Color(0xFF6A11CB),
//         centerTitle: true,
//       ),
//       drawer: _buildDrawer(context),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: Colors.white))
//           : SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildAdminHeader(),
//                   const SizedBox(height: 20),
//                   _buildSummaryCards(),
//                   const SizedBox(height: 25),
//                   const Text(
//                     "Recent Activities",
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   _buildRecentActivityList(),
//                 ],
//               ),
//             ),
//     );
//   }

//   Widget _buildAdminHeader() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Row(
//         children: [
//           const CircleAvatar(
//             radius: 35,
//             backgroundColor: Colors.white,
//             child: Icon(
//               Icons.admin_panel_settings,
//               size: 40,
//               color: Color(0xFF6A11CB),
//             ),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Text(
//               "Welcome, $name\n($role)",
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSummaryCards() {
//     return GridView.count(
//       shrinkWrap: true,
//       crossAxisCount: 2,
//       mainAxisSpacing: 15,
//       crossAxisSpacing: 15,
//       physics: const NeverScrollableScrollPhysics(),
//       children: [
//         _summaryCard(
//           Icons.people,
//           "Total Users",
//           totalUsers.toString(),
//           Colors.blue,
//         ),
//         _summaryCard(
//           Icons.login,
//           "Total Check-ins",
//           totalCheckIns.toString(),
//           Colors.green,
//         ),
//         _summaryCard(
//           Icons.pending_actions,
//           "Pending Check-outs",
//           pendingCheckOuts.toString(),
//           Colors.orange,
//         ),
//         _summaryCard(
//           Icons.calendar_month,
//           "Records",
//           (totalCheckIns + pendingCheckOuts).toString(),
//           Colors.purple,
//         ),
//       ],
//     );
//   }

//   Widget _summaryCard(IconData icon, String title, String value, Color color) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF2C2C3E),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, color: color, size: 35),
//           const SizedBox(height: 10),
//           Text(
//             value,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 20,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(title, style: TextStyle(color: Colors.grey[300], fontSize: 14)),
//         ],
//       ),
//     );
//   }

//   Widget _buildRecentActivityList() {
//     if (recentActivities.isEmpty) {
//       return const Center(
//         child: Text(
//           "No recent activity found.",
//           style: TextStyle(color: Colors.white70),
//         ),
//       );
//     }

//     return ListView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: recentActivities.length,
//       itemBuilder: (context, index) {
//         final activity = recentActivities[index];
//         return Card(
//           color: const Color(0xFF2C2C3E),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           margin: const EdgeInsets.symmetric(vertical: 6),
//           child: ListTile(
//             leading: const Icon(Icons.access_time, color: Colors.white),
//             title: Text(
//               activity['userName'] ?? 'Unknown User',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             subtitle: Text(
//               "Check-in: ${activity['checkInTime'] ?? 'N/A'}\n"
//               "Check-out: ${activity['checkOutTime'] ?? 'N/A'}",
//               style: const TextStyle(color: Colors.white70, fontSize: 13),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildDrawer(BuildContext context) {
//     return Drawer(
//       backgroundColor: const Color(0xFF2C2C3E),
//       child: Column(
//         children: [
//           DrawerHeader(
//             decoration: const BoxDecoration(color: Colors.transparent),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const CircleAvatar(
//                   radius: 30,
//                   backgroundColor: Colors.white,
//                   child: Icon(
//                     Icons.admin_panel_settings,
//                     color: Color(0xFF6A11CB),
//                     size: 35,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Text(
//                   name,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                     letterSpacing: 1.1,
//                   ),
//                 ),
//                 const SizedBox(height: 5),
//                 Text(
//                   email,
//                   style: const TextStyle(color: Colors.white70, fontSize: 14),
//                 ),
//               ],
//             ),
//           ),
//           ListTile(
//             leading: const Icon(Icons.people, color: Colors.white),
//             title: const Text(
//               "User List",
//               style: TextStyle(color: Colors.white),
//             ),
//             onTap: () {
//               Navigator.pushReplacementNamed(context, '/adminList');
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.history, color: Colors.white),
//             title: const Text(
//               "Attendance History",
//               style: TextStyle(color: Colors.white),
//             ),
//             onTap: () {
//               Navigator.pushNamed(context, '/adminAttendanceHistory');
//             },
//           ),
//           const Spacer(),
//           ListTile(
//             leading: const Icon(Icons.logout, color: Colors.white),
//             title: const Text("Logout", style: TextStyle(color: Colors.white)),
//             onTap: () {
//               LogoutDialog.show(context);
//             },
//           ),
//         ],
//       ),
//     );
//   }

// }

// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:mobile_attendance_application/presentation/widgets/logout_dialog.dart';

// class AdminDashboardScreen extends StatefulWidget {
//   const AdminDashboardScreen({super.key});

//   @override
//   State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
// }

// class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
//   bool _isLoading = true;
//   bool _isError = false;
//   String _errorMessage = '';

//   // Dashboard data
//   int totalUsers = 0;
//   int totalCheckIns = 0;
//   int pendingCheckOuts = 0;
//   List<Map<String, dynamic>> recentActivities = [];

//   // Admin info
//   String name = '';
//   String email = '';
//   String role = '';

//   @override
//   void initState() {
//     super.initState();
//     _loadProfileAndFetch();
//   }

//   Future<void> _loadProfileAndFetch() async {
//     await _loadAdminInfo();
//     await _fetchDashboardData();
//   }

//   Future<void> _loadAdminInfo() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       setState(() {
//         name = prefs.getString('name') ?? 'Admin';
//         email = prefs.getString('email') ?? '';
//         role = prefs.getString('role') ?? 'Admin';
//       });
//     } catch (_) {
//       // ignore - optional
//     }
//   }

//   Future<void> _fetchDashboardData() async {
//     setState(() {
//       _isLoading = true;
//       _isError = false;
//       _errorMessage = '';
//     });

//     try {
//       final uri = Uri.parse(
//         "https://trainerattendence-backed.onrender.com/api/attendance/all",
//       );
//       final res = await http.get(uri);

//       if (res.statusCode != 200) {
//         throw Exception('Server returned ${res.statusCode}');
//       }

//       final List<dynamic> list = jsonDecode(res.body) as List<dynamic>;

//       // Compute metrics
//       final uniqueUsers = <dynamic>{};
//       int checkIns = 0;
//       int pending = 0;

//       // ensure reversed recent order (latest first)
//       final reversed = List<Map<String, dynamic>>.from(
//         list.map((e) => Map<String, dynamic>.from(e as Map)).toList().reversed,
//       );

//       for (final item in list) {
//         uniqueUsers.add(item['userId'] ?? item['userId']);
//         if (item['checkInTime'] != null) checkIns++;
//         if (item['checkOutTime'] == null) pending++;
//       }

//       setState(() {
//         totalUsers = uniqueUsers.length;
//         totalCheckIns = checkIns;
//         pendingCheckOuts = pending;
//         // keep a safe slice of most recent activities
//         recentActivities = reversed.take(8).toList();
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//         _isError = true;
//         _errorMessage = e.toString();
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Failed to load: $e')));
//       }
//     }
//   }

//   // small helper to format time or fallback
//   String _formatShort(dynamic raw) {
//     if (raw == null) return 'N/A';
//     try {
//       final dt = DateTime.parse(raw.toString());
//       return DateFormat('dd MMM, hh:mm a').format(dt);
//     } catch (_) {
//       return raw.toString();
//     }
//   }

//   // animated counter widget
//   Widget _animatedCount(String label, int value, IconData icon, Color accent) {
//     return TweenAnimationBuilder<int>(
//       tween: IntTween(begin: 0, end: value),
//       duration: const Duration(milliseconds: 800),
//       builder: (context, val, child) {
//         return _MetricCard(
//           icon: icon,
//           label: label,
//           value: val.toString(),
//           accent: accent,
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // deep purple gradient
//     final appGradient = const LinearGradient(
//       colors: [Color(0xFF4A148C), Color(0xFF6A11CB)],
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//     );

//     return Scaffold(
//       backgroundColor: const Color(0xFF0E0E10),
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text('Admin Dashboard'),
//         centerTitle: true,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(gradient: appGradient),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh_rounded),
//             onPressed: _fetchDashboardData,
//             tooltip: 'Refresh',
//           ),
//         ],
//       ),
//       drawer: _buildDrawer(appGradient),
//       body: SafeArea(
//         child: RefreshIndicator(
//           color: const Color(0xFF6A11CB),
//           onRefresh: _fetchDashboardData,
//           child: _isLoading
//               ? const Center(
//                   child: CircularProgressIndicator(color: Colors.white),
//                 )
//               : _isError
//               ? ListView(
//                   physics: const AlwaysScrollableScrollPhysics(),
//                   children: [
//                     const SizedBox(height: 60),
//                     Center(
//                       child: Text(
//                         'Error loading dashboard\n$_errorMessage',
//                         textAlign: TextAlign.center,
//                         style: const TextStyle(color: Colors.white70),
//                       ),
//                     ),
//                   ],
//                 )
//               : ListView(
//                   padding: const EdgeInsets.all(16),
//                   children: [
//                     _HeaderCard(name: name, role: role, email: email),
//                     const SizedBox(height: 20),
//                     // responsive grid for metrics
//                     LayoutBuilder(
//                       builder: (context, constraints) {
//                         final crossAxis = constraints.maxWidth > 900
//                             ? 4
//                             : constraints.maxWidth > 600
//                             ? 2
//                             : 1;
//                         return GridView.count(
//                           physics: const NeverScrollableScrollPhysics(),
//                           shrinkWrap: true,
//                           crossAxisCount: crossAxis,
//                           mainAxisSpacing: 12,
//                           crossAxisSpacing: 12,
//                           childAspectRatio: 3.2,
//                           children: [
//                             _animatedCount(
//                               'Total Users',
//                               totalUsers,
//                               Icons.people,
//                               Colors.blueAccent,
//                             ),
//                             _animatedCount(
//                               'Total Check-ins',
//                               totalCheckIns,
//                               Icons.login,
//                               Colors.greenAccent,
//                             ),
//                             _animatedCount(
//                               'Pending Check-outs',
//                               pendingCheckOuts,
//                               Icons.pending_actions,
//                               Colors.orangeAccent,
//                             ),
//                             _MetricCard(
//                               icon: Icons.calendar_today,
//                               label: 'Records',
//                               value: (totalCheckIns + pendingCheckOuts)
//                                   .toString(),
//                               accent: Colors.purpleAccent,
//                               extra:
//                                   'Last updated: ${DateFormat('dd MMM, hh:mm a').format(DateTime.now())}',
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 24),
//                     const Text(
//                       'Recent Activities',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     ...recentActivities.map((act) {
//                       final user = (act['userName'] ?? act['name'] ?? 'Unknown')
//                           .toString();
//                       final checkIn = act['checkInTime'];
//                       final checkOut = act['checkOutTime'];
//                       final dept = (act['department'] ?? '-').toString();
//                       final avatar = act['photoUrl'] ?? act['photo'] ?? null;

//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 10),
//                         child: _ActivityTile(
//                           name: user,
//                           department: dept,
//                           checkIn: _formatShort(checkIn),
//                           checkOut: checkOut == null
//                               ? 'Pending'
//                               : _formatShort(checkOut),
//                           avatarUrl: avatar?.toString(),
//                           checkedOut: checkOut != null,
//                         ),
//                       );
//                     }).toList(),
//                     const SizedBox(height: 20),
//                     // footer small note
//                     Center(
//                       child: Text(
//                         'Built on ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
//                         style: const TextStyle(
//                           color: Colors.white54,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 50),
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }

//   Drawer _buildDrawer(Gradient gradient) {
//     return Drawer(
//       child: Container(
//         decoration: BoxDecoration(gradient: gradient),
//         child: Column(
//           children: [
//             DrawerHeader(
//               decoration: const BoxDecoration(color: Colors.transparent),
//               child: Row(
//                 children: [
//                   const CircleAvatar(
//                     radius: 28,
//                     backgroundColor: Colors.white,
//                     child: Icon(
//                       Icons.admin_panel_settings,
//                       color: Color(0xFF6A11CB),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           name,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           role,
//                           style: const TextStyle(color: Colors.white70),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           email,
//                           style: const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             _drawerTile(
//               Icons.people,
//               'User List',
//               () => Navigator.pushNamed(context, '/adminList'),
//             ),
//             _drawerTile(
//               Icons.history,
//               'Attendance History',
//               () => Navigator.pushNamed(context, '/adminAttendanceHistory'),
//             ),
//             const Spacer(),
//             ListTile(
//               leading: const Icon(Icons.logout, color: Colors.white),
//               title: const Text(
//                 'Logout',
//                 style: TextStyle(color: Colors.white),
//               ),
//               onTap: () => LogoutDialog.show(context),
//             ),
//             const SizedBox(height: 12),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _drawerTile(IconData icon, String text, VoidCallback onTap) {
//     return ListTile(
//       leading: Icon(icon, color: Colors.white70),
//       title: Text(text, style: const TextStyle(color: Colors.white)),
//       onTap: onTap,
//     );
//   }
// }

// /// Small header card with gradient + welcome copy
// class _HeaderCard extends StatelessWidget {
//   final String name;
//   final String role;
//   final String email;
//   const _HeaderCard({
//     required this.name,
//     required this.role,
//     required this.email,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF6A11CB), Color(0xFF4A148C)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.45),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           const CircleAvatar(
//             radius: 34,
//             backgroundColor: Colors.white,
//             child: Icon(
//               Icons.admin_panel_settings,
//               color: Color(0xFF6A11CB),
//               size: 34,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Welcome back,',
//                   style: TextStyle(color: Colors.white.withOpacity(0.9)),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   name,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '$role • $email',
//                   style: const TextStyle(color: Colors.white70, fontSize: 12),
//                 ),
//               ],
//             ),
//           ),
//           // ElevatedButton.icon(
//           //   style: ElevatedButton.styleFrom(
//           //     backgroundColor: Colors.white24,
//           //     elevation: 0,
//           //     shape: RoundedRectangleBorder(
//           //       borderRadius: BorderRadius.circular(10),
//           //     ),
//           //   ),
//           //   onPressed: () {},
//           //   icon: const Icon(Icons.add, color: Colors.white, size: 18),
//           //   label: const Text(
//           //     'Quick Action',
//           //     style: TextStyle(color: Colors.white),
//           //   ),
//           // ),
//         ],
//       ),
//     );
//   }
// }

// /// Metric card used in grid
// class _MetricCard extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color accent;
//   final String? extra;

//   const _MetricCard({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.accent,
//     this.extra,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       decoration: BoxDecoration(
//         color: const Color(0xFF141417),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white12),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: accent.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: accent, size: 26),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   label,
//                   style: const TextStyle(color: Colors.white70, fontSize: 12),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 if (extra != null) ...[
//                   const SizedBox(height: 6),
//                   Text(
//                     extra!,
//                     style: const TextStyle(color: Colors.white54, fontSize: 11),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// /// Activity tile with subtle improvements
// class _ActivityTile extends StatelessWidget {
//   final String name;
//   final String department;
//   final String checkIn;
//   final String checkOut;
//   final String? avatarUrl;
//   final bool checkedOut;

//   const _ActivityTile({
//     required this.name,
//     required this.department,
//     required this.checkIn,
//     required this.checkOut,
//     this.avatarUrl,
//     this.checkedOut = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: const Color(0xFF141416),
//       borderRadius: BorderRadius.circular(12),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () {},
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//           child: Row(
//             children: [
//               CircleAvatar(
//                 radius: 26,
//                 backgroundColor: Colors.white10,
//                 backgroundImage: avatarUrl != null
//                     ? NetworkImage(avatarUrl!)
//                     : null,
//                 child: avatarUrl == null
//                     ? Text(
//                         name.isNotEmpty ? name[0].toUpperCase() : '?',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       )
//                     : null,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             name,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: checkedOut
//                                 ? Colors.greenAccent.shade400
//                                 : Colors.orangeAccent,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Text(
//                             checkedOut ? 'Checked' : 'Pending',
//                             style: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       department,
//                       style: const TextStyle(
//                         color: Colors.white70,
//                         fontSize: 12,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         const Icon(
//                           Icons.login,
//                           color: Colors.greenAccent,
//                           size: 14,
//                         ),
//                         const SizedBox(width: 6),
//                         Expanded(
//                           child: Text(
//                             'In: $checkIn',
//                             style: const TextStyle(
//                               color: Colors.white60,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         const Icon(
//                           Icons.logout,
//                           color: Colors.redAccent,
//                           size: 14,
//                         ),
//                         const SizedBox(width: 6),
//                         Expanded(
//                           child: Text(
//                             'Out: $checkOut',
//                             style: const TextStyle(
//                               color: Colors.white60,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'dart:convert';

// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AdminDashboardScreen extends StatefulWidget {
//   const AdminDashboardScreen({super.key});

//   @override
//   State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
// }

// class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
//   // --- UI / state flags
//   bool _loading = true;
//   bool _error = false;
//   String _errorMessage = '';

//   // --- data
//   List<Map<String, dynamic>> _records = [];
//   List<Map<String, dynamic>> _recent = [];

//   // metrics
//   int _totalUsers = 0;
//   int _totalCheckIns = 0;
//   int _pendingCheckOuts = 0;
//   Map<String, int> _deptDistribution = {};

//   // derived analytics
//   Map<String, int> _weeklyCounts = {}; // "Mon", "Tue", ...
//   Map<String, int> _monthlyCounts = {}; // "Jan", "Feb", ...
//   Map<String, Duration> _userHours = {}; // userName -> total duration
//   List<Map<String, dynamic>> _pendingDefaulters = [];
//   List<Map<String, dynamic>> _lateArrivals = [];

//   // admin profile
//   String _name = 'Admin';
//   String _email = '';
//   String _role = 'Admin';

//   // polling timer (for "real-time")
//   Timer? _pollTimer;
//   final Duration _pollInterval = const Duration(seconds: 25);

//   // config
//   final TimeOfDay lateThreshold = const TimeOfDay(hour: 9, minute: 30);

//   @override
//   void initState() {
//     super.initState();
//     _initScreen();
//     // start polling after initial load
//     _pollTimer = Timer.periodic(_pollInterval, (_) => _fetchAndProcess());
//   }

//   Future<void> _initScreen() async {
//     await _loadProfile();
//     await _fetchAndProcess();
//   }

//   @override
//   void dispose() {
//     _pollTimer?.cancel();
//     super.dispose();
//   }

//   Future<void> _loadProfile() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       if (!mounted) return;
//       setState(() {
//         _name = prefs.getString('name') ?? 'Admin';
//         _email = prefs.getString('email') ?? '';
//         _role = prefs.getString('role') ?? 'Admin';
//       });
//     } catch (_) {
//       // silent
//     }
//   }

//   Future<void> _fetchAndProcess() async {
//     if (!mounted) return;
//     setState(() {
//       _loading = true;
//       _error = false;
//       _errorMessage = '';
//     });

//     try {
//       final uri = Uri.parse(
//         'https://trainerattendence-backed.onrender.com/api/attendance/all',
//       );
//       final res = await http.get(uri).timeout(const Duration(seconds: 20));

//       if (res.statusCode != 200) {
//         throw Exception('Server responded with ${res.statusCode}');
//       }

//       final data = jsonDecode(res.body) as List<dynamic>;

//       final list = data
//           .map((e) => Map<String, dynamic>.from(e as Map))
//           .toList(growable: false);

//       // process
//       _processRecords(list);

//       if (!mounted) return;
//       setState(() {
//         _records = list;
//         _loading = false;
//       });
//     } catch (e, st) {
//       if (!mounted) return;
//       setState(() {
//         _error = true;
//         _errorMessage = e.toString();
//         _loading = false;
//         _records = [];
//       });
//       // optionally print error in debug
//       // ignore: avoid_print
//       print('Fetch error: $e\n$st');
//     }
//   }

//   void _processRecords(List<Map<String, dynamic>> list) {
//     // reset
//     final userSet = <dynamic>{};
//     final deptCounts = <String, int>{};
//     final weekly = <String, int>{};
//     final monthly = <String, int>{};
//     final userHours = <String, Duration>{};
//     final recent = <Map<String, dynamic>>[];

//     final pendingDef = <Map<String, dynamic>>[];
//     final lateArrivalsLocal = <Map<String, dynamic>>[];

//     // helper
//     String weekdayLabel(DateTime dt) =>
//         DateFormat('EEE').format(dt); // Mon, Tue
//     String monthLabel(DateTime dt) => DateFormat('MMM').format(dt); // Jan, Feb
//     DateTime now = DateTime.now();

//     // iterate
//     for (var item in list) {
//       final userId = item['userId'];
//       final userName = (item['userName'] ?? item['name'] ?? 'Unknown')
//           .toString();
//       final dept = (item['department'] ?? '-').toString();
//       final checkInRaw = item['checkInTime'];
//       final checkOutRaw = item['checkOutTime'];

//       userSet.add(userId ?? userName);
//       deptCounts[dept] = (deptCounts[dept] ?? 0) + 1;

//       DateTime? checkInDt;
//       DateTime? checkOutDt;

//       try {
//         if (checkInRaw != null)
//           checkInDt = DateTime.parse(checkInRaw.toString());
//       } catch (_) {}

//       try {
//         if (checkOutRaw != null)
//           checkOutDt = DateTime.parse(checkOutRaw.toString());
//       } catch (_) {}

//       // weekly/monthly counts: use checkIn date, fallback to today
//       final forDt = checkInDt ?? DateTime.now();
//       final wLabel = weekdayLabel(forDt);
//       weekly[wLabel] = (weekly[wLabel] ?? 0) + 1;

//       final mLabel = monthLabel(forDt);
//       monthly[mLabel] = (monthly[mLabel] ?? 0) + 1;

//       // user hours: compute if checkOut present
//       Duration duration = Duration.zero;
//       if (checkInDt != null && checkOutDt != null) {
//         duration = checkOutDt.difference(checkInDt);
//         userHours[userName] = (userHours[userName] ?? Duration.zero) + duration;
//       }

//       // pending defaulter
//       if (checkInDt != null && checkOutDt == null) {
//         // didn't checkout -> pending
//         pendingDef.add({
//           'userName': userName,
//           'department': dept,
//           'checkInTime': checkInDt,
//           'record': item,
//         });
//       }

//       // late arrival detection: if checkIn exists and is after threshold
//       if (checkInDt != null) {
//         final thresholdDt = DateTime(
//           checkInDt.year,
//           checkInDt.month,
//           checkInDt.day,
//           lateThreshold.hour,
//           lateThreshold.minute,
//         );
//         if (checkInDt.isAfter(thresholdDt)) {
//           lateArrivalsLocal.add({
//             'userName': userName,
//             'department': dept,
//             'checkInTime': checkInDt,
//             'lateBy': checkInDt.difference(thresholdDt),
//             'record': item,
//           });
//         }
//       }

//       // recent activities: include if within last 7 days OR simply collect latest by payload order
//       final rec = <String, dynamic>{};
//       rec['userName'] = userName;
//       rec['department'] = dept;
//       rec['checkInTime'] = checkInDt;
//       rec['checkOutTime'] = checkOutDt;
//       rec['isPending'] = checkOutDt == null;
//       rec['timestamp'] = checkInDt ?? now;
//       recent.add(rec);
//     }

//     // sort recent by timestamp desc and take top 8
//     recent.sort((a, b) {
//       final aT = a['timestamp'] as DateTime;
//       final bT = b['timestamp'] as DateTime;
//       return bT.compareTo(aT);
//     });

//     _recent = recent.take(8).toList();

//     // compute aggregations final
//     _totalUsers = userSet.length;
//     _totalCheckIns = list.where((r) => r['checkInTime'] != null).length;
//     _pendingCheckOuts = list.where((r) => r['checkOutTime'] == null).length;

//     _deptDistribution = Map<String, int>.fromEntries(
//       deptCounts.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
//     ); // top-first

//     _weeklyCounts = weekly;
//     _monthlyCounts = monthly;
//     _userHours = userHours;
//     _pendingDefaulters = pendingDef;
//     _lateArrivals = lateArrivalsLocal;
//   }

//   // --- UI helpers and computations

//   String _formatShort(dynamic raw) {
//     if (raw == null) return 'N/A';
//     try {
//       final dt = raw is DateTime ? raw : DateTime.parse(raw.toString());
//       return DateFormat('dd MMM, hh:mm a').format(dt);
//     } catch (_) {
//       return raw.toString();
//     }
//   }

//   String _formatDuration(Duration d) {
//     if (d == Duration.zero) return '-';
//     final h = d.inHours;
//     final m = d.inMinutes.remainder(60);
//     return '${h}h ${m}m';
//   }

//   // Quick actions: placeholders you can wire to your export/share methods
//   Future<void> _onQuickExportPdf() async {
//     // TODO: call your PDF export routine
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Export PDF (TODO)')));
//   }

//   Future<void> _onQuickExportExcel() async {
//     // TODO: call your Excel export routine
//     ScaffoldMessenger.of(
//       context,
//     ).showSnackBar(const SnackBar(content: Text('Export Excel (TODO)')));
//   }

//   Future<void> _onRefreshTapped() async {
//     await _fetchAndProcess();
//   }

//   // Insights calculation example: finds top 3 users by hours
//   List<Map<String, String>> _topUsersByHours(int topN) {
//     final list = _userHours.entries.toList()
//       ..sort((a, b) => b.value.compareTo(a.value));
//     return list
//         .take(topN)
//         .map((e) => {'name': e.key, 'hours': _formatDuration(e.value)})
//         .toList();
//   }

//   // simple department distribution data for UI
//   List<Map<String, dynamic>> _deptDistributionList() {
//     return _deptDistribution.entries
//         .map((e) => {'dept': e.key, 'count': e.value})
//         .toList();
//   }

//   // --- BUILD UI

//   @override
//   Widget build(BuildContext context) {
//     final gradient = const LinearGradient(
//       colors: [Color(0xFF4A148C), Color(0xFF6A11CB)],
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//     );

//     return Scaffold(
//       backgroundColor: const Color(0xFF0E0E10),
//       appBar: AppBar(
//         title: const Text('Admin Dashboard'),
//         centerTitle: true,
//         elevation: 0,
//         flexibleSpace: Container(decoration: BoxDecoration(gradient: gradient)),
//         actions: [
//           IconButton(
//             onPressed: _onRefreshTapped,
//             icon: const Icon(Icons.refresh_rounded),
//           ),
//           PopupMenuButton<String>(
//             onSelected: (s) async {
//               if (s == 'exp_pdf') await _onQuickExportPdf();
//               if (s == 'exp_xlsx') await _onQuickExportExcel();
//             },
//             itemBuilder: (_) => const [
//               PopupMenuItem(value: 'exp_pdf', child: Text('Export PDF')),
//               PopupMenuItem(value: 'exp_xlsx', child: Text('Export Excel')),
//             ],
//           ),
//         ],
//       ),
//       drawer: _buildDrawer(gradient),
//       body: RefreshIndicator(
//         onRefresh: _fetchAndProcess,
//         color: const Color(0xFF6A11CB),
//         child: _loading
//             ? _buildLoading()
//             : _error
//             ? _buildError()
//             : _buildContent(),
//       ),
//       floatingActionButton: _buildQuickActions(),
//     );
//   }

//   Widget _buildDrawer(Gradient gradient) {
//     return Drawer(
//       child: Container(
//         decoration: BoxDecoration(gradient: gradient),
//         child: SafeArea(
//           child: Column(
//             children: [
//               ListTile(
//                 leading: const CircleAvatar(
//                   backgroundColor: Colors.white,
//                   child: Icon(
//                     Icons.admin_panel_settings,
//                     color: Color(0xFF6A11CB),
//                   ),
//                 ),
//                 title: Text(
//                   _name,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 subtitle: Text(
//                   _email,
//                   style: const TextStyle(color: Colors.white70),
//                 ),
//               ),
//               const Divider(color: Colors.white24),
//               ListTile(
//                 leading: const Icon(Icons.people, color: Colors.white),
//                 title: const Text(
//                   'User List',
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 onTap: () => Navigator.pushNamed(context, '/adminList'),
//               ),
//               ListTile(
//                 leading: const Icon(Icons.history, color: Colors.white),
//                 title: const Text(
//                   'Attendance History',
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 onTap: () =>
//                     Navigator.pushNamed(context, '/adminAttendanceHistory'),
//               ),
//               const Spacer(),
//               ListTile(
//                 leading: const Icon(Icons.logout, color: Colors.white),
//                 title: const Text(
//                   'Logout',
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 onTap: () => showDialog(
//                   context: context,
//                   builder: (_) => AlertDialog(
//                     title: const Text('Logout'),
//                     content: const Text('Implement logout flow here'),
//                     actions: [
//                       TextButton(
//                         onPressed: () => Navigator.pop(context),
//                         child: const Text('OK'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLoading() {
//     return ListView(
//       children: const [
//         SizedBox(height: 60),
//         Center(child: CircularProgressIndicator(color: Colors.white)),
//       ],
//     );
//   }

//   Widget _buildError() {
//     return ListView(
//       children: [
//         const SizedBox(height: 60),
//         Center(
//           child: Text(
//             'Error: $_errorMessage',
//             style: const TextStyle(color: Colors.white70),
//           ),
//         ),
//         const SizedBox(height: 12),
//         Center(
//           child: ElevatedButton(
//             onPressed: _fetchAndProcess,
//             child: const Text('Retry'),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildContent() {
//     return ListView(
//       padding: const EdgeInsets.all(16),
//       children: [
//         _buildHeaderCard(),
//         const SizedBox(height: 16),
//         _buildMetricsGrid(),
//         const SizedBox(height: 18),
//         _buildInsightsPanel(),
//         const SizedBox(height: 18),
//         _buildChartsRow(),
//         const SizedBox(height: 18),
//         _buildRecentActivities(),
//         const SizedBox(height: 20),
//         _buildDefaultersAndLate(),
//         const SizedBox(height: 40),
//       ],
//     );
//   }

//   Widget _buildHeaderCard() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF6A11CB), Color(0xFF4A148C)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.45),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           const CircleAvatar(
//             radius: 36,
//             backgroundColor: Colors.white,
//             child: Icon(
//               Icons.admin_panel_settings,
//               color: Color(0xFF6A11CB),
//               size: 34,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Welcome back,',
//                   style: TextStyle(color: Colors.white.withOpacity(0.9)),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   _name,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '$_role • $_email',
//                   style: const TextStyle(color: Colors.white70, fontSize: 12),
//                 ),
//               ],
//             ),
//           ),
//           ElevatedButton.icon(
//             icon: const Icon(Icons.download_outlined, color: Colors.white),
//             label: const Text('Export', style: TextStyle(color: Colors.white)),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.white24,
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             onPressed: () async {
//               // quick export default (pdf)
//               await _onQuickExportPdf();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildMetricsGrid() {
//     final recordsCount = (_totalCheckIns + _pendingCheckOuts);
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final cross = constraints.maxWidth > 900
//             ? 4
//             : (constraints.maxWidth > 600 ? 2 : 1);
//         return GridView.count(
//           crossAxisCount: cross,
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           crossAxisSpacing: 12,
//           mainAxisSpacing: 12,
//           childAspectRatio: 3.2,
//           children: [
//             _metricCard(
//               Icons.people,
//               'Total Users',
//               _totalUsers.toString(),
//               Colors.blueAccent,
//             ),
//             _metricCard(
//               Icons.login,
//               'Total Check-ins',
//               _totalCheckIns.toString(),
//               Colors.greenAccent,
//             ),
//             _metricCard(
//               Icons.pending_actions,
//               'Pending Check-outs',
//               _pendingCheckOuts.toString(),
//               Colors.orangeAccent,
//             ),
//             _metricCard(
//               Icons.calendar_today,
//               'Records',
//               recordsCount.toString(),
//               Colors.purpleAccent,
//               subtitle:
//                   'Updated ${DateFormat('dd MMM, hh:mm a').format(DateTime.now())}',
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _metricCard(
//     IconData icon,
//     String title,
//     String value,
//     Color accent, {
//     String? subtitle,
//   }) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//       decoration: BoxDecoration(
//         color: const Color(0xFF141417),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white12),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: accent.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: accent),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   title,
//                   style: const TextStyle(color: Colors.white70, fontSize: 12),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 if (subtitle != null) ...[
//                   const SizedBox(height: 6),
//                   Text(
//                     subtitle,
//                     style: const TextStyle(color: Colors.white54, fontSize: 11),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildInsightsPanel() {
//     final topUsers = _topUsersByHours(3);
//     final deptList = _deptDistributionList();
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           flex: 2,
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: const Color(0xFF141417),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Insights',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 Text(
//                   'Top active users (by hours):',
//                   style: TextStyle(color: Colors.white70),
//                 ),
//                 const SizedBox(height: 8),
//                 ...topUsers.map(
//                   (u) => ListTile(
//                     contentPadding: EdgeInsets.zero,
//                     leading: const Icon(Icons.person, color: Colors.white24),
//                     title: Text(
//                       u['name']!,
//                       style: const TextStyle(color: Colors.white),
//                     ),
//                     subtitle: Text(
//                       u['hours']!,
//                       style: const TextStyle(color: Colors.white70),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   'Department distribution:',
//                   style: TextStyle(color: Colors.white70),
//                 ),
//                 const SizedBox(height: 8),
//                 Wrap(
//                   spacing: 8,
//                   children: deptList
//                       .map(
//                         (d) => Chip(
//                           label: Text('${d['dept']} (${d['count']})'),
//                           backgroundColor: Colors.white12,
//                         ),
//                       )
//                       .toList(),
//                 ),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: const Color(0xFF141417),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Alerts',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 10),
//                 ListTile(
//                   leading: const Icon(
//                     Icons.warning,
//                     color: Colors.orangeAccent,
//                   ),
//                   title: Text(
//                     '${_pendingCheckOuts} pending check-outs',
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 ),
//                 ListTile(
//                   leading: const Icon(Icons.schedule, color: Colors.redAccent),
//                   title: Text(
//                     '${_lateArrivals.length} late arrivals today',
//                     style: const TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildChartsRow() {
//     // Minimal text charts: weekly & monthly sparkline-like representation using bars
//     return Row(
//       children: [
//         Expanded(child: _buildSimpleBarChart('Week', _weeklyCounts)),
//         const SizedBox(width: 12),
//         Expanded(child: _buildSimpleBarChart('Month', _monthlyCounts)),
//       ],
//     );
//   }

//   Widget _buildSimpleBarChart(String title, Map<String, int> data) {
//     if (data.isEmpty) {
//       return Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: const Color(0xFF141417),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: const Text('No data', style: TextStyle(color: Colors.white70)),
//       );
//     }
//     final max = data.values.fold<int>(0, (prev, e) => e > prev ? e : prev);
//     final entries = data.entries.toList()
//       ..sort((a, b) => a.key.compareTo(b.key));
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: const Color(0xFF141417),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           SizedBox(
//             height: 56,
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: entries.map((e) {
//                 final value = e.value;
//                 final height = max == 0 ? 6.0 : (value / max) * 48.0;
//                 return Expanded(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.end,
//                     children: [
//                       Container(
//                         height: height,
//                         margin: const EdgeInsets.symmetric(horizontal: 4),
//                         decoration: BoxDecoration(
//                           color: Colors.white24,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         e.key,
//                         style: const TextStyle(
//                           color: Colors.white70,
//                           fontSize: 11,
//                         ),
//                       ),
//                     ],
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRecentActivities() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: const Color(0xFF141417),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Recent Activities',
//             style: TextStyle(
//               color: Colors.white,
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           ..._recent.map((r) {
//             final user = r['userName'] as String;
//             final dept = r['department'] as String;
//             final inT = r['checkInTime'] as DateTime?;
//             final outT = r['checkOutTime'] as DateTime?;
//             final pending = r['isPending'] as bool;
//             return ListTile(
//               contentPadding: EdgeInsets.zero,
//               leading: CircleAvatar(
//                 backgroundColor: Colors.white10,
//                 child: Text(
//                   user.isNotEmpty ? user[0].toUpperCase() : '?',
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               ),
//               title: Text(user, style: const TextStyle(color: Colors.white)),
//               subtitle: Text(
//                 '$dept • In: ${inT != null ? DateFormat('dd MMM, hh:mm a').format(inT) : 'N/A'}',
//                 style: const TextStyle(color: Colors.white70),
//               ),
//               trailing: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: pending ? Colors.orange : Colors.green,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   pending ? 'Pending' : 'Checked',
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               ),
//               onTap: () {
//                 // tap for detail — implement navigation to detail screen if needed
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Open detail for $user (TODO)')),
//                 );
//               },
//             );
//           }).toList(),
//         ],
//       ),
//     );
//   }

//   Widget _buildDefaultersAndLate() {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Expanded(
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: const Color(0xFF141417),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Pending Defaulters',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 if (_pendingDefaulters.isEmpty)
//                   const Text(
//                     'No pending check-outs',
//                     style: TextStyle(color: Colors.white70),
//                   )
//                 else
//                   ..._pendingDefaulters.take(6).map((d) {
//                     final name = d['userName'] as String;
//                     final dept = d['department'] as String;
//                     final ci = d['checkInTime'] as DateTime?;
//                     return ListTile(
//                       contentPadding: EdgeInsets.zero,
//                       leading: const Icon(Icons.person, color: Colors.white70),
//                       title: Text(
//                         name,
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                       subtitle: Text(
//                         '$dept • In: ${ci != null ? DateFormat('dd MMM, hh:mm a').format(ci) : 'N/A'}',
//                         style: const TextStyle(
//                           color: Colors.white70,
//                           fontSize: 12,
//                         ),
//                       ),
//                       trailing: TextButton(
//                         onPressed: () {
//                           /* take action to nudge or mark checkout */
//                         },
//                         child: const Text('Nudge'),
//                       ),
//                     );
//                   }),
//               ],
//             ),
//           ),
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: const Color(0xFF141417),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Late Arrivals',
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 8),
//                 if (_lateArrivals.isEmpty)
//                   const Text(
//                     'No late arrivals',
//                     style: TextStyle(color: Colors.white70),
//                   )
//                 else
//                   ..._lateArrivals.take(6).map((d) {
//                     final name = d['userName'] as String;
//                     final dept = d['department'] as String;
//                     final ci = d['checkInTime'] as DateTime?;
//                     final lateBy = d['lateBy'] as Duration;
//                     return ListTile(
//                       contentPadding: EdgeInsets.zero,
//                       leading: const Icon(
//                         Icons.schedule,
//                         color: Colors.white70,
//                       ),
//                       title: Text(
//                         name,
//                         style: const TextStyle(color: Colors.white),
//                       ),
//                       subtitle: Text(
//                         '$dept • In: ${ci != null ? DateFormat('dd MMM, hh:mm a').format(ci) : 'N/A'}',
//                         style: const TextStyle(
//                           color: Colors.white70,
//                           fontSize: 12,
//                         ),
//                       ),
//                       trailing: Text(
//                         _formatDuration(lateBy),
//                         style: const TextStyle(color: Colors.orangeAccent),
//                       ),
//                     );
//                   }),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildQuickActions() {
//     return FloatingActionButton.extended(
//       onPressed: () async {
//         // open a quick actions sheet
//         await showModalBottomSheet(
//           context: context,
//           builder: (_) => _quickActionsSheet(),
//         );
//       },
//       icon: const Icon(Icons.flash_on),
//       label: const Text('Quick'),
//       backgroundColor: const Color(0xFF6A11CB),
//     );
//   }

//   Widget _quickActionsSheet() {
//     return Container(
//       color: const Color(0xFF0E0E10),
//       padding: const EdgeInsets.all(12),
//       child: Wrap(
//         runSpacing: 8,
//         children: [
//           ListTile(
//             leading: const Icon(Icons.refresh, color: Colors.white),
//             title: const Text(
//               'Refresh data',
//               style: TextStyle(color: Colors.white),
//             ),
//             onTap: () {
//               Navigator.pop(context);
//               _fetchAndProcess();
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.picture_as_pdf, color: Colors.white),
//             title: const Text(
//               'Export PDF',
//               style: TextStyle(color: Colors.white),
//             ),
//             onTap: () {
//               Navigator.pop(context);
//               _onQuickExportPdf();
//             },
//           ),
//           ListTile(
//             leading: const Icon(Icons.table_chart, color: Colors.white),
//             title: const Text(
//               'Export Excel',
//               style: TextStyle(color: Colors.white),
//             ),
//             onTap: () {
//               Navigator.pop(context);
//               _onQuickExportExcel();
//             },
//           ),
//           ListTile(
//             leading: const Icon(
//               Icons.notifications_active,
//               color: Colors.white,
//             ),
//             title: const Text(
//               'Notify pending users',
//               style: TextStyle(color: Colors.white),
//             ),
//             onTap: () {
//               Navigator.pop(context);
//               _notifyPendingUsers();
//             },
//           ),
//           const SizedBox(height: 10),
//           Center(
//             child: Text(
//               'Last updated: ${DateFormat('dd MMM, hh:mm a').format(DateTime.now())}',
//               style: const TextStyle(color: Colors.white54),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _notifyPendingUsers() async {
//     // TODO: implement notification / nudge logic. Placeholder:
//     if (!mounted) return;
//     final count = _pendingDefaulters.length;
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text('Would notify $count pending users (TODO)')),
//     );
//   }
// }

// import 'dart:convert';
// import 'dart:io';
// import 'package:excel/excel.dart' hide Border;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:share_plus/share_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:mobile_attendance_application/presentation/widgets/logout_dialog.dart';

// class AdminDashboardScreen extends StatefulWidget {
//   const AdminDashboardScreen({super.key});

//   @override
//   State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
// }

// class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
//   // Loading / error
//   bool _isLoading = true;
//   bool _isError = false;
//   String _errorMessage = '';

//   // Dashboard metrics
//   int totalUsers = 0;
//   int totalCheckIns = 0;
//   int pendingCheckOuts = 0;
//   List<Map<String, dynamic>> recentActivities = [];

//   // All attendance records (used for export + history filters)
//   List<Map<String, dynamic>> _attendanceRecords = [];

//   // Admin profile
//   String name = '';
//   String email = '';
//   String role = '';

//   // Export busy
//   bool _isExporting = false;

//   // UI Theme colors
//   final Color _bg = const Color(0xFF0E0E10);
//   final Color _panel = const Color(0xFF151516);
//   final Color _deepPurple = const Color(0xFF4A148C);

//   @override
//   void initState() {
//     super.initState();
//     _initAll();
//   }

//   Future<void> _initAll() async {
//     await _loadAdminInfo();
//     await _fetchAttendanceAll(); // loads attendanceRecords + metrics
//   }

//   Future<void> _loadAdminInfo() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       if (!mounted) return;
//       setState(() {
//         name = prefs.getString('name') ?? 'Admin';
//         email = prefs.getString('email') ?? '';
//         role = prefs.getString('role') ?? 'Admin';
//       });
//     } catch (_) {
//       // ignore
//     }
//   }

//   Future<void> _fetchAttendanceAll() async {
//     if (mounted) {
//       setState(() {
//         _isLoading = true;
//         _isError = false;
//         _errorMessage = '';
//       });
//     }

//     try {
//       final uri = Uri.parse(
//         "https://trainerattendence-backed.onrender.com/api/attendance/all",
//       );
//       final res = await http.get(uri);

//       if (res.statusCode != 200) {
//         throw Exception('Server returned ${res.statusCode}');
//       }

//       final List<dynamic> list = jsonDecode(res.body) as List<dynamic>;
//       final records = list
//           .map((e) => Map<String, dynamic>.from(e as Map))
//           .toList();

//       // Compute metrics
//       final uniqueUsers = <dynamic>{};
//       int checkIns = 0;
//       int pending = 0;

//       for (final item in records) {
//         uniqueUsers.add(item['userId'] ?? item['userId']);
//         if (item['checkInTime'] != null) checkIns++;
//         if (item['checkOutTime'] == null) pending++;
//       }

//       // recent activities (latest first)
//       final reversed = List<Map<String, dynamic>>.from(records.reversed);

//       if (mounted) {
//         setState(() {
//           _attendanceRecords = records;
//           totalUsers = uniqueUsers.length;
//           totalCheckIns = checkIns;
//           pendingCheckOuts = pending;
//           recentActivities = reversed.take(8).toList();
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _isError = true;
//           _errorMessage = e.toString();
//           _attendanceRecords = [];
//           recentActivities = [];
//         });
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Failed to load: $e')));
//       }
//     }
//   }

//   // ------------------ Helpers ------------------

//   DateTime _tryParse(String? raw) {
//     if (raw == null) return DateTime.fromMillisecondsSinceEpoch(0);
//     try {
//       return DateTime.parse(raw);
//     } catch (_) {
//       // try removing milliseconds or timezone artifacts
//       try {
//         return DateTime.parse(raw.replaceAll('Z', ''));
//       } catch (_) {
//         return DateTime.fromMillisecondsSinceEpoch(0);
//       }
//     }
//   }

//   Duration _computeDurationFromRecord(Map<String, dynamic> r) {
//     final checkInRaw = r['checkInTime'];
//     final checkOutRaw = r['checkOutTime'];
//     if (checkInRaw == null) return Duration.zero;
//     final dtIn = _tryParse(checkInRaw.toString());
//     if (checkOutRaw == null) return Duration.zero;
//     final dtOut = _tryParse(checkOutRaw.toString());
//     if (dtOut.isBefore(dtIn)) return Duration.zero;
//     return dtOut.difference(dtIn);
//   }

//   String _formatShort(dynamic raw) {
//     if (raw == null) return 'N/A';
//     try {
//       final dt = DateTime.parse(raw.toString());
//       return DateFormat('dd MMM, hh:mm a').format(dt);
//     } catch (_) {
//       return raw.toString();
//     }
//   }

//   // ------------------ Export / Share ------------------

//   /// Get download directory cross-platform (Downloads on Android if available).
//   Future<Directory> _getDownloadDir() async {
//     if (Platform.isAndroid) {
//       final candidate = Directory('/storage/emulated/0/Download');
//       if (await candidate.exists()) return candidate;
//       final ext = await getExternalStorageDirectory();
//       if (ext != null) return ext;
//     }
//     return await getApplicationDocumentsDirectory();
//   }

//   /// Build filtered rows from parameters. This is used by the Filter & Export UI.
//   List<Map<String, dynamic>> _filterRecords({
//     DateTime? start,
//     DateTime? end,
//     String? userName,
//     String? department,
//     String status = 'all', // all / checkedout / pending
//   }) {
//     final startDt = start != null
//         ? DateTime(start.year, start.month, start.day)
//         : null;
//     final endDt = end != null
//         ? DateTime(end.year, end.month, end.day, 23, 59, 59)
//         : null;

//     List<Map<String, dynamic>> rows = List.from(_attendanceRecords);

//     if (userName != null && userName.isNotEmpty) {
//       rows = rows
//           .where((r) => (r['userName'] ?? '').toString() == userName)
//           .toList();
//     }
//     if (department != null && department.isNotEmpty) {
//       rows = rows
//           .where((r) => (r['department'] ?? '').toString() == department)
//           .toList();
//     }
//     if (status == 'checkedout') {
//       rows = rows.where((r) => r['checkOutTime'] != null).toList();
//     } else if (status == 'pending') {
//       rows = rows.where((r) => r['checkOutTime'] == null).toList();
//     }
//     if (startDt != null && endDt != null) {
//       rows = rows.where((r) {
//         final raw = r['checkInTime'];
//         if (raw == null) return false;
//         try {
//           final dt = DateTime.parse(raw.toString());
//           return (dt.isAfter(startDt) || dt.isAtSameMomentAs(startDt)) &&
//               (dt.isBefore(endDt) || dt.isAtSameMomentAs(endDt));
//         } catch (_) {
//           return false;
//         }
//       }).toList();
//     }

//     // Return newest-first
//     rows.sort(
//       (a, b) => _tryParse(
//         b['checkInTime']?.toString(),
//       ).compareTo(_tryParse(a['checkInTime']?.toString())),
//     );
//     return rows;
//   }

//   // Excel export (updated)
//   Future<File?> _exportExcelFileFromRows(
//     List<Map<String, dynamic>> exportRows,
//   ) async {
//     if (exportRows.isEmpty) {
//       if (mounted)
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('No records to export')));
//       return null;
//     }

//     final excel = Excel.createExcel();
//     final Sheet sheet = excel['Sheet1'];

//     // Header
//     sheet.appendRow([
//       TextCellValue('Name'),
//       TextCellValue('Department'),
//       TextCellValue('Date'),
//       TextCellValue('Check-In Time'),
//       TextCellValue('Check-Out Time'),
//       TextCellValue('Duration'),
//       TextCellValue('Check-In Address'),
//       TextCellValue('Check-Out Address'),
//       TextCellValue('Check-In Mode'),
//       TextCellValue('Check-Out Mode'),
//     ]);

//     for (final r in exportRows) {
//       final date = _formatShort(r['checkInTime']);
//       final inTime = _formatShort(r['checkInTime']);
//       final outTime = r['checkOutTime'] != null
//           ? _formatShort(r['checkOutTime'])
//           : '-';
//       final dur = _computeDurationFromRecord(r);
//       final durStr = dur == Duration.zero
//           ? '-'
//           : '${dur.inHours}h ${dur.inMinutes.remainder(60)}m';

//       final inAddr = (r['checkInAddress'] ?? '-').toString().replaceAll(
//         '\n',
//         ' ',
//       );
//       final outAddr = (r['checkOutAddress'] ?? '-').toString().replaceAll(
//         '\n',
//         ' ',
//       );

//       final inMode = (r['checkInMode'] == true) ? 'Online' : 'Offline';
//       final outMode = (r['checkOutMode'] == true) ? 'Online' : 'Offline';

//       sheet.appendRow([
//         TextCellValue(r['userName'] ?? '-'),
//         TextCellValue(r['department'] ?? '-'),
//         TextCellValue(date),
//         TextCellValue(inTime),
//         TextCellValue(outTime),
//         TextCellValue(durStr),
//         TextCellValue(inAddr),
//         TextCellValue(outAddr),
//         TextCellValue(inMode),
//         TextCellValue(outMode),
//       ]);
//     }

//     final bytes = excel.encode();
//     if (bytes == null) return null;

//     final fileName =
//         'attendance_export_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';
//     final dir = await _getDownloadDir();
//     final file = File('${dir.path}/$fileName');
//     await file.writeAsBytes(bytes, flush: true);
//     return file;
//   }

//   // PDF export (format like the sample you provided)
//   Future<File?> _exportPdfFileFromRows(
//     List<Map<String, dynamic>> exportRows, {
//     DateTime? start,
//     DateTime? end,
//   }) async {
//     if (exportRows.isEmpty) {
//       if (mounted)
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('No records to export')));
//       return null;
//     }

//     final pdf = pw.Document();

//     // total duration
//     Duration totalDuration = Duration.zero;
//     for (var r in exportRows) {
//       totalDuration += _computeDurationFromRecord(r);
//     }

//     String formatTotal(Duration d) =>
//         "${d.inHours}h ${d.inMinutes.remainder(60)}m";
//     String period = (start != null && end != null)
//         ? '${DateFormat('dd MMM yyyy').format(start)} - ${DateFormat('dd MMM yyyy').format(end)}'
//         : 'All Dates';

//     // Build table rows for pdf
//     final tableHeaders = [
//       'Date',
//       'In',
//       'Out',
//       'Duration',
//       'In Address',
//       'Out Address',
//       'In Mode',
//       'Out Mode',
//     ];

//     final tableData = exportRows.map((r) {
//       final checkIn = r['checkInTime'];
//       final checkOut = r['checkOutTime'];
//       final dtIn = _tryParse(checkIn?.toString());
//       final dateStr = dtIn.millisecondsSinceEpoch == 0
//           ? '-'
//           : DateFormat('yyyy-MM-dd').format(dtIn);
//       final inTime = dtIn.millisecondsSinceEpoch == 0
//           ? '-'
//           : DateFormat('HH:mm').format(dtIn);
//       final dtOut = checkOut != null ? _tryParse(checkOut.toString()) : null;
//       final outTime = dtOut != null && dtOut.millisecondsSinceEpoch != 0
//           ? DateFormat('HH:mm').format(dtOut)
//           : '-';
//       final dur = _computeDurationFromRecord(r);
//       final durStr = dur == Duration.zero
//           ? '-'
//           : '${dur.inHours}h ${dur.inMinutes.remainder(60)}m';

//       final inAddr = (r['checkInAddress'] ?? '-').toString().replaceAll(
//         '\n',
//         ' ',
//       );
//       final outAddr = (r['checkOutAddress'] ?? '-').toString().replaceAll(
//         '\n',
//         ' ',
//       );

//       final inMode = (r['checkInMode'] == true) ? 'Online' : 'Offline';
//       final outMode = (r['checkOutMode'] == true) ? 'Online' : 'Offline';

//       return [
//         dateStr,
//         inTime,
//         outTime,
//         durStr,
//         inAddr,
//         outAddr,
//         inMode,
//         outMode,
//       ];
//     }).toList();

//     // Create PDF with header, totals and table (paged)
//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(20),
//         footer: (context) => pw.Align(
//           alignment: pw.Alignment.centerRight,
//           child: pw.Text(
//             'Page ${context.pageNumber} of ${context.pagesCount}',
//             style: const pw.TextStyle(fontSize: 10),
//           ),
//         ),
//         build: (context) => [
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//             children: [
//               pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Text(
//                     'ATTENDANCE REPORT',
//                     style: pw.TextStyle(
//                       fontSize: 18,
//                       fontWeight: pw.FontWeight.bold,
//                       color: PdfColors.deepPurple,
//                     ),
//                   ),
//                   pw.SizedBox(height: 6),
//                   pw.Text(
//                     name.isNotEmpty ? name : 'Admin',
//                     style: pw.TextStyle(
//                       fontSize: 12,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.end,
//                 children: [
//                   pw.Text(period, style: const pw.TextStyle(fontSize: 11)),
//                   pw.SizedBox(height: 6),
//                   pw.Text(
//                     'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
//                     style: const pw.TextStyle(fontSize: 10),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           pw.SizedBox(height: 12),
//           pw.Container(
//             padding: const pw.EdgeInsets.all(10),
//             decoration: pw.BoxDecoration(
//               color: PdfColors.deepPurple50,
//               border: pw.Border.all(color: PdfColors.deepPurple, width: 1),
//               borderRadius: pw.BorderRadius.circular(6),
//             ),
//             child: pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//               children: [
//                 pw.Text(
//                   'Total Records: ${exportRows.length}',
//                   style: pw.TextStyle(
//                     fontSize: 12,
//                     fontWeight: pw.FontWeight.bold,
//                   ),
//                 ),
//                 pw.Text(
//                   'Total Hours: ${formatTotal(totalDuration)}',
//                   style: pw.TextStyle(
//                     fontSize: 12,
//                     fontWeight: pw.FontWeight.bold,
//                     color: PdfColors.deepPurple,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           pw.SizedBox(height: 12),
//           pw.Table.fromTextArray(
//             headers: tableHeaders,
//             data: tableData,
//             cellAlignment: pw.Alignment.centerLeft,
//             headerStyle: pw.TextStyle(
//               fontSize: 9,
//               fontWeight: pw.FontWeight.bold,
//             ),
//             cellStyle: const pw.TextStyle(fontSize: 8),
//             columnWidths: {
//               0: const pw.FlexColumnWidth(1.2),
//               1: const pw.FlexColumnWidth(1),
//               2: const pw.FlexColumnWidth(1),
//               3: const pw.FlexColumnWidth(1),
//               4: const pw.FlexColumnWidth(2.5),
//               5: const pw.FlexColumnWidth(2.5),
//               6: const pw.FlexColumnWidth(1),
//               7: const pw.FlexColumnWidth(1),
//             },
//             border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
//           ),
//         ],
//       ),
//     );

//     final bytes = await pdf.save();
//     final fileName =
//         'attendance_export_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';
//     final dir = await _getDownloadDir();
//     final file = File('${dir.path}/$fileName');
//     await file.writeAsBytes(bytes, flush: true);
//     return file;
//   }

//   // ------------------ Export UI (Filter popup + Export actions) ------------------

//   /// Opens a dialog that lets admin pick filters and then export the filtered result.
//   Future<void> _openFilterExportDialog() async {
//     // prepare helper lists for dropdowns (unique user names, depts)
//     final users = _attendanceRecords
//         .map((e) => (e['userName'] ?? 'Unknown').toString())
//         .toSet()
//         .toList();
//     final depts = _attendanceRecords
//         .map((e) => (e['department'] ?? 'Unknown').toString())
//         .toSet()
//         .toList();
//     users.sort();
//     depts.sort();

//     DateTime? start;
//     DateTime? end;
//     String? selectedUser;
//     String? selectedDept;
//     String status = 'all';

//     await showDialog(
//       context: context,
//       builder: (ctx) => StatefulBuilder(
//         builder: (ctx2, setStateDialog) {
//           return AlertDialog(
//             backgroundColor: _panel,
//             title: const Text(
//               'Filter & Export',
//               style: TextStyle(color: Colors.white),
//             ),

//             // content: SingleChildScrollView(

//             //   child: Column(
//             //     children: [
//             //       // Date range row
//             //       Row(
//             //         children: [
//             //           Expanded(
//             //             child: Text(
//             //               start == null
//             //                   ? 'Start date'
//             //                   : DateFormat('dd MMM yyyy').format(start!),
//             //               style: const TextStyle(color: Colors.white70),
//             //             ),
//             //           ),
//             //           const SizedBox(width: 8),
//             //           Expanded(
//             //             child: Text(
//             //               end == null
//             //                   ? 'End date'
//             //                   : DateFormat('dd MMM yyyy').format(end!),
//             //               style: const TextStyle(color: Colors.white70),
//             //             ),
//             //           ),
//             //           IconButton(
//             //             icon: const Icon(
//             //               Icons.date_range,
//             //               color: Colors.white70,
//             //             ),
//             //             onPressed: () async {
//             //               final picked = await showDateRangePicker(
//             //                 context: ctx2,
//             //                 firstDate: DateTime.now().subtract(
//             //                   const Duration(days: 365 * 5),
//             //                 ),
//             //                 lastDate: DateTime.now().add(
//             //                   const Duration(days: 365),
//             //                 ),
//             //                 initialDateRange: start != null && end != null
//             //                     ? DateTimeRange(start: start!, end: end!)
//             //                     : null,
//             //                 builder: (context, child) => Theme(
//             //                   data: Theme.of(
//             //                     context,
//             //                   ).copyWith(dialogBackgroundColor: _panel),
//             //                   child: child!,
//             //                 ),
//             //               );
//             //               if (picked != null) {
//             //                 setStateDialog(() {
//             //                   start = picked.start;
//             //                   end = picked.end;
//             //                 });
//             //               }
//             //             },
//             //           ),
//             //         ],
//             //       ),
//             //       const SizedBox(height: 8),

//             //       // User dropdown
//             //       DropdownButtonFormField<String?>(
//             //         value: selectedUser,
//             //         isExpanded: true,
//             //         dropdownColor: _panel,
//             //         decoration: InputDecoration(
//             //           filled: true,
//             //           fillColor: const Color(0xFF1A1A1A),
//             //           border: OutlineInputBorder(
//             //             borderRadius: BorderRadius.circular(6),
//             //             borderSide: BorderSide.none,
//             //           ),
//             //           contentPadding: const EdgeInsets.symmetric(
//             //             horizontal: 12,
//             //             vertical: 6,
//             //           ),
//             //         ),
//             //         items:
//             //             [
//             //               DropdownMenuItem<String?>(
//             //                 value: null,
//             //                 child: Text('All users'),
//             //               ),
//             //             ] +
//             //             users
//             //                 .map(
//             //                   (u) => DropdownMenuItem(value: u, child: Text(u)),
//             //                 )
//             //                 .toList(),
//             //         onChanged: (v) => setStateDialog(() => selectedUser = v),
//             //       ),
//             //       const SizedBox(height: 8),

//             //       // Dept dropdown
//             //       DropdownButtonFormField<String?>(
//             //         value: selectedDept,
//             //         isExpanded: true,
//             //         dropdownColor: _panel,
//             //         decoration: InputDecoration(
//             //           filled: true,
//             //           fillColor: const Color(0xFF1A1A1A),
//             //           border: OutlineInputBorder(
//             //             borderRadius: BorderRadius.circular(6),
//             //             borderSide: BorderSide.none,
//             //           ),
//             //           contentPadding: const EdgeInsets.symmetric(
//             //             horizontal: 12,
//             //             vertical: 6,
//             //           ),
//             //         ),
//             //         items:
//             //             [
//             //               const DropdownMenuItem<String>(
//             //                 value: null,
//             //                 child: Text('All departments'),
//             //               ),
//             //             ] +
//             //             depts
//             //                 .map(
//             //                   (d) => DropdownMenuItem(value: d, child: Text(d)),
//             //                 )
//             //                 .toList(),
//             //         onChanged: (v) => setStateDialog(() => selectedDept = v),
//             //       ),
//             //       const SizedBox(height: 8),

//             //       // Status
//             //       Row(
//             //         children: [
//             //           const Text(
//             //             'Status:',
//             //             style: TextStyle(color: Colors.white70),
//             //           ),
//             //           const SizedBox(width: 8),
//             //           ChoiceChip(
//             //             label: const Text('All'),
//             //             selected: status == 'all',
//             //             onSelected: (_) => setStateDialog(() => status = 'all'),
//             //             selectedColor: _deepPurple,
//             //           ),
//             //           const SizedBox(width: 6),
//             //           ChoiceChip(
//             //             label: const Text('Checked-out'),
//             //             selected: status == 'checkedout',
//             //             onSelected: (_) =>
//             //                 setStateDialog(() => status = 'checkedout'),
//             //             selectedColor: Colors.green,
//             //           ),
//             //           const SizedBox(width: 6),
//             //           ChoiceChip(
//             //             label: const Text('Pending'),
//             //             selected: status == 'pending',
//             //             onSelected: (_) =>
//             //                 setStateDialog(() => status = 'pending'),
//             //             selectedColor: Colors.orange,
//             //           ),
//             //         ],
//             //       ),
//             //     ],
//             //   ),
//             // ),
//             //
//             content: SingleChildScrollView(
//               child: ConstrainedBox(
//                 constraints: BoxConstraints(
//                   maxWidth: MediaQuery.of(context).size.width * 0.85,
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     // Date range row
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             start == null
//                                 ? 'Start date'
//                                 : DateFormat('dd MMM yyyy').format(start!),
//                             style: const TextStyle(color: Colors.white70),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             end == null
//                                 ? 'End date'
//                                 : DateFormat('dd MMM yyyy').format(end!),
//                             style: const TextStyle(color: Colors.white70),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         IconButton(
//                           icon: const Icon(
//                             Icons.date_range,
//                             color: Colors.white70,
//                           ),
//                           onPressed: () async {
//                             final picked = await showDateRangePicker(
//                               context: ctx2,
//                               firstDate: DateTime.now().subtract(
//                                 const Duration(days: 365 * 5),
//                               ),
//                               lastDate: DateTime.now().add(
//                                 const Duration(days: 365),
//                               ),
//                               initialDateRange: start != null && end != null
//                                   ? DateTimeRange(start: start!, end: end!)
//                                   : null,
//                             );
//                             if (picked != null) {
//                               setStateDialog(() {
//                                 start = picked.start;
//                                 end = picked.end;
//                               });
//                             }
//                           },
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),

//                     // User Dropdown
//                     DropdownButtonFormField<String?>(
//                       value: selectedUser,
//                       isExpanded: true,
//                       dropdownColor: _panel,
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: const Color(0xFF1A1A1A),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(6),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                       items: <DropdownMenuItem<String?>>[
//                         const DropdownMenuItem<String?>(
//                           value: null,
//                           child: Text('All users'),
//                         ),
//                         ...users.map(
//                           (u) => DropdownMenuItem<String?>(
//                             value: u,
//                             child: Text(u),
//                           ),
//                         ),
//                       ],
//                       onChanged: (v) => setStateDialog(() => selectedUser = v),
//                     ),

//                     const SizedBox(height: 12),

//                     // Dept Dropdown
//                     DropdownButtonFormField<String?>(
//                       value: selectedDept,
//                       isExpanded: true,
//                       dropdownColor: _panel,
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: const Color(0xFF1A1A1A),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(6),
//                           borderSide: BorderSide.none,
//                         ),
//                       ),
//                       items: <DropdownMenuItem<String?>>[
//                         const DropdownMenuItem<String?>(
//                           value: null,
//                           child: Text('All departments'),
//                         ),
//                         ...depts.map(
//                           (d) => DropdownMenuItem<String?>(
//                             value: d,
//                             child: Text(d),
//                           ),
//                         ),
//                       ],
//                       onChanged: (v) => setStateDialog(() => selectedDept = v),
//                     ),

//                     const SizedBox(height: 12),

//                     // Status Chips
//                     Wrap(
//                       spacing: 10,
//                       runSpacing: 10,
//                       children: [
//                         ChoiceChip(
//                           label: const Text('All'),
//                           selected: status == 'all',
//                           onSelected: (_) =>
//                               setStateDialog(() => status = 'all'),
//                           selectedColor: _deepPurple,
//                         ),
//                         ChoiceChip(
//                           label: const Text('Checked-out'),
//                           selected: status == 'checkedout',
//                           onSelected: (_) =>
//                               setStateDialog(() => status = 'checkedout'),
//                           selectedColor: Colors.green,
//                         ),
//                         ChoiceChip(
//                           label: const Text('Pending'),
//                           selected: status == 'pending',
//                           onSelected: (_) =>
//                               setStateDialog(() => status = 'pending'),
//                           selectedColor: Colors.orange,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),

//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(ctx2).pop(),
//                 child: const Text('Cancel'),
//               ),
//               TextButton(
//                 onPressed: () async {
//                   // Apply filters and export menu
//                   final rows = _filterRecords(
//                     start: start,
//                     end: end,
//                     userName: selectedUser,
//                     department: selectedDept,
//                     status: status,
//                   );
//                   Navigator.of(ctx2).pop();
//                   await _showExportOptionsForRows(rows, start: start, end: end);
//                 },
//                 child: const Text('Export'),
//               ),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   /// Present a small menu to choose PDF/Excel/Share
//   Future<void> _showExportOptionsForRows(
//     List<Map<String, dynamic>> rows, {
//     DateTime? start,
//     DateTime? end,
//   }) async {
//     if (rows.isEmpty) {
//       if (mounted)
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('No records match the filters')),
//         );
//       return;
//     }

//     await showModalBottomSheet(
//       context: context,
//       backgroundColor: _panel,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//       ),
//       builder: (ctx) {
//         return SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Export ${rows.length} records',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _deepPurple,
//                         ),
//                         icon: const Icon(Icons.picture_as_pdf),
//                         label: const Text('Export PDF'),
//                         onPressed: () async {
//                           Navigator.of(ctx).pop();
//                           await _performPdfExport(rows, start: start, end: end);
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                         ),
//                         icon: const Icon(Icons.table_view),
//                         label: const Text('Export Excel'),
//                         onPressed: () async {
//                           Navigator.of(ctx).pop();
//                           await _performExcelExport(rows);
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         icon: const Icon(Icons.share),
//                         label: const Text('Share PDF'),
//                         onPressed: () async {
//                           Navigator.of(ctx).pop();
//                           await _sharePdf(rows, start: start, end: end);
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         icon: const Icon(Icons.share_outlined),
//                         label: const Text('Share Excel'),
//                         onPressed: () async {
//                           Navigator.of(ctx).pop();
//                           await _shareExcel(rows);
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _performExcelExport(List<Map<String, dynamic>> rows) async {
//     setState(() => _isExporting = true);
//     try {
//       final file = await _exportExcelFileFromRows(rows);
//       if (file != null) {
//         await OpenFilex.open(file.path);
//         if (mounted)
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Excel exported: ${file.path.split('/').last}'),
//             ),
//           );
//       }
//     } catch (e) {
//       if (mounted)
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Excel export failed: $e')));
//     } finally {
//       if (mounted) setState(() => _isExporting = false);
//     }
//   }

//   Future<void> _performPdfExport(
//     List<Map<String, dynamic>> rows, {
//     DateTime? start,
//     DateTime? end,
//   }) async {
//     setState(() => _isExporting = true);
//     try {
//       final file = await _exportPdfFileFromRows(rows, start: start, end: end);
//       if (file != null) {
//         await OpenFilex.open(file.path);
//         if (mounted)
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('PDF exported: ${file.path.split('/').last}'),
//             ),
//           );
//       }
//     } catch (e) {
//       if (mounted)
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('PDF export failed: $e')));
//     } finally {
//       if (mounted) setState(() => _isExporting = false);
//     }
//   }

//   Future<void> _shareExcel(List<Map<String, dynamic>> rows) async {
//     setState(() => _isExporting = true);
//     try {
//       final f = await _exportExcelFileFromRows(rows);
//       if (f != null) {
//         await Share.shareXFiles([XFile(f.path)], text: 'Attendance (Excel)');
//       }
//     } catch (e) {
//       if (mounted)
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
//     } finally {
//       if (mounted) setState(() => _isExporting = false);
//     }
//   }

//   Future<void> _sharePdf(
//     List<Map<String, dynamic>> rows, {
//     DateTime? start,
//     DateTime? end,
//   }) async {
//     setState(() => _isExporting = true);
//     try {
//       final f = await _exportPdfFileFromRows(rows, start: start, end: end);
//       if (f != null) {
//         await Share.shareXFiles([XFile(f.path)], text: 'Attendance (PDF)');
//       }
//     } catch (e) {
//       if (mounted)
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
//     } finally {
//       if (mounted) setState(() => _isExporting = false);
//     }
//   }

//   // Quick "Export ALL" action (Option A)
//   Future<void> _exportAllPrompt() async {
//     final rows = List<Map<String, dynamic>>.from(_attendanceRecords);
//     await _showExportOptionsForRows(rows);
//   }

//   // ------------------ Build UI ------------------

//   @override
//   Widget build(BuildContext context) {
//     final appGradient = const LinearGradient(
//       colors: [Color(0xFF4A148C), Color(0xFF6A11CB)],
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//     );

//     return Scaffold(
//       backgroundColor: _bg,
//       appBar: AppBar(
//         title: const Text('Admin Dashboard'),
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(gradient: appGradient),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh_rounded),
//             onPressed: _fetchAttendanceAll,
//             tooltip: 'Refresh',
//           ),
//           PopupMenuButton<String>(
//             onSelected: (s) async {
//               if (s == 'export_all') {
//                 await _exportAllPrompt();
//               } else if (s == 'filter_export') {
//                 await _openFilterExportDialog();
//               }
//             },
//             itemBuilder: (_) => [
//               const PopupMenuItem(
//                 value: 'export_all',
//                 child: Text('Export ALL (PDF/Excel)'),
//               ),
//               const PopupMenuItem(
//                 value: 'filter_export',
//                 child: Text('Filter & Export'),
//               ),
//             ],
//           ),
//         ],
//       ),
//       drawer: _buildDrawer(appGradient),
//       body: SafeArea(
//         child: _isLoading
//             ? const Center(
//                 child: CircularProgressIndicator(color: Colors.white),
//               )
//             : _isError
//             ? ListView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 children: [
//                   const SizedBox(height: 60),
//                   Center(
//                     child: Text(
//                       'Error loading dashboard\n$_errorMessage',
//                       textAlign: TextAlign.center,
//                       style: const TextStyle(color: Colors.white70),
//                     ),
//                   ),
//                 ],
//               )
//             : RefreshIndicator(
//                 onRefresh: _fetchAttendanceAll,
//                 color: _deepPurple,
//                 child: ListView(
//                   padding: const EdgeInsets.all(16),
//                   children: [
//                     _HeaderCard(name: name, role: role, email: email),
//                     const SizedBox(height: 20),
//                     LayoutBuilder(
//                       builder: (context, constraints) {
//                         final crossAxis = constraints.maxWidth > 900
//                             ? 4
//                             : constraints.maxWidth > 600
//                             ? 2
//                             : 1;
//                         return GridView.count(
//                           physics: const NeverScrollableScrollPhysics(),
//                           shrinkWrap: true,
//                           crossAxisCount: crossAxis,
//                           mainAxisSpacing: 12,
//                           crossAxisSpacing: 12,
//                           childAspectRatio: 3.2,
//                           children: [
//                             _MetricCard(
//                               icon: Icons.people,
//                               label: 'Total Users',
//                               value: totalUsers.toString(),
//                               accent: Colors.blueAccent,
//                             ),
//                             _MetricCard(
//                               icon: Icons.login,
//                               label: 'Total Check-ins',
//                               value: totalCheckIns.toString(),
//                               accent: Colors.greenAccent,
//                             ),
//                             _MetricCard(
//                               icon: Icons.pending_actions,
//                               label: 'Pending Check-outs',
//                               value: pendingCheckOuts.toString(),
//                               accent: Colors.orangeAccent,
//                             ),
//                             _MetricCard(
//                               icon: Icons.calendar_today,
//                               label: 'Records',
//                               value: (totalCheckIns + pendingCheckOuts)
//                                   .toString(),
//                               accent: Colors.purpleAccent,
//                               extra:
//                                   'Last updated: ${DateFormat('dd MMM, hh:mm a').format(DateTime.now())}',
//                             ),
//                           ],
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 24),
//                     const Text(
//                       'Recent Activities',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 10),
//                     ...recentActivities.map((act) {
//                       final user = (act['userName'] ?? act['name'] ?? 'Unknown')
//                           .toString();
//                       final checkIn = act['checkInTime'];
//                       final checkOut = act['checkOutTime'];
//                       final dept = (act['department'] ?? '-').toString();
//                       final avatar = act['photoUrl'] ?? act['photo'] ?? null;
//                       return Padding(
//                         padding: const EdgeInsets.only(bottom: 10),
//                         child: _ActivityTile(
//                           name: user,
//                           department: dept,
//                           checkIn: _formatShort(checkIn),
//                           checkOut: checkOut == null
//                               ? 'Pending'
//                               : _formatShort(checkOut),
//                           avatarUrl: avatar?.toString(),
//                           checkedOut: checkOut != null,
//                         ),
//                       );
//                     }).toList(),
//                     const SizedBox(height: 20),
//                     Center(
//                       child: Text(
//                         'Built on ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
//                         style: const TextStyle(
//                           color: Colors.white54,
//                           fontSize: 12,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 50),
//                   ],
//                 ),
//               ),
//       ),
//       floatingActionButton: _isExporting
//           ? FloatingActionButton(
//               onPressed: () {},
//               backgroundColor: Colors.grey,
//               child: const CircularProgressIndicator(color: Colors.white),
//             )
//           : null,
//     );
//   }

//   Drawer _buildDrawer(Gradient gradient) {
//     return Drawer(
//       child: Container(
//         decoration: BoxDecoration(gradient: gradient),
//         child: Column(
//           children: [
//             DrawerHeader(
//               decoration: const BoxDecoration(color: Colors.transparent),
//               child: Row(
//                 children: [
//                   const CircleAvatar(
//                     radius: 28,
//                     backgroundColor: Colors.white,
//                     child: Icon(
//                       Icons.admin_panel_settings,
//                       color: Color(0xFF6A11CB),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           name,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           role,
//                           style: const TextStyle(color: Colors.white70),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           email,
//                           style: const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.people, color: Colors.white),
//               title: const Text(
//                 'User List',
//                 style: TextStyle(color: Colors.white),
//               ),
//               onTap: () => Navigator.pushNamed(context, '/adminList'),
//             ),
//             ListTile(
//               leading: const Icon(Icons.history, color: Colors.white),
//               title: const Text(
//                 'Attendance History',
//                 style: TextStyle(color: Colors.white),
//               ),
//               onTap: () =>
//                   Navigator.pushNamed(context, '/adminAttendanceHistory'),
//             ),
//             const Spacer(),
//             ListTile(
//               leading: const Icon(Icons.logout, color: Colors.white),
//               title: const Text(
//                 'Logout',
//                 style: TextStyle(color: Colors.white),
//               ),
//               onTap: () => LogoutDialog.show(context),
//             ),
//             const SizedBox(height: 12),
//           ],
//         ),
//       ),
//     );
//   }
// }

// /// UI components kept similar to your previous version

// class _HeaderCard extends StatelessWidget {
//   final String name;
//   final String role;
//   final String email;
//   const _HeaderCard({
//     required this.name,
//     required this.role,
//     required this.email,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF6A11CB), Color(0xFF4A148C)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.45),
//             blurRadius: 12,
//             offset: const Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           const CircleAvatar(
//             radius: 34,
//             backgroundColor: Colors.white,
//             child: Icon(
//               Icons.admin_panel_settings,
//               color: Color(0xFF6A11CB),
//               size: 34,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Welcome back,',
//                   style: TextStyle(color: Colors.white.withOpacity(0.9)),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   name,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '$role • $email',
//                   style: const TextStyle(color: Colors.white70, fontSize: 12),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _MetricCard extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;
//   final Color accent;
//   final String? extra;
//   const _MetricCard({
//     required this.icon,
//     required this.label,
//     required this.value,
//     required this.accent,
//     this.extra,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
//       decoration: BoxDecoration(
//         color: const Color(0xFF141417),
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.white12),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(10),
//             decoration: BoxDecoration(
//               color: accent.withOpacity(0.12),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: accent, size: 26),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   label,
//                   style: const TextStyle(color: Colors.white70, fontSize: 12),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 if (extra != null) ...[
//                   const SizedBox(height: 6),
//                   Text(
//                     extra!,
//                     style: const TextStyle(color: Colors.white54, fontSize: 11),
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _ActivityTile extends StatelessWidget {
//   final String name;
//   final String department;
//   final String checkIn;
//   final String checkOut;
//   final String? avatarUrl;
//   final bool checkedOut;
//   const _ActivityTile({
//     required this.name,
//     required this.department,
//     required this.checkIn,
//     required this.checkOut,
//     this.avatarUrl,
//     this.checkedOut = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: const Color(0xFF141416),
//       borderRadius: BorderRadius.circular(12),
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () {},
//         child: Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//           child: Row(
//             children: [
//               CircleAvatar(
//                 radius: 26,
//                 backgroundColor: Colors.white10,
//                 backgroundImage: avatarUrl != null
//                     ? NetworkImage(avatarUrl!)
//                     : null,
//                 child: avatarUrl == null
//                     ? Text(
//                         name.isNotEmpty ? name[0].toUpperCase() : '?',
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       )
//                     : null,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             name,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: checkedOut
//                                 ? Colors.greenAccent.shade400
//                                 : Colors.orangeAccent,
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           child: Text(
//                             checkedOut ? 'Checked' : 'Pending',
//                             style: const TextStyle(
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       department,
//                       style: const TextStyle(
//                         color: Colors.white70,
//                         fontSize: 12,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         const Icon(
//                           Icons.login,
//                           color: Colors.greenAccent,
//                           size: 14,
//                         ),
//                         const SizedBox(width: 6),
//                         Expanded(
//                           child: Text(
//                             'In: $checkIn',
//                             style: const TextStyle(
//                               color: Colors.white60,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         const Icon(
//                           Icons.logout,
//                           color: Colors.redAccent,
//                           size: 14,
//                         ),
//                         const SizedBox(width: 6),
//                         Expanded(
//                           child: Text(
//                             'Out: $checkOut',
//                             style: const TextStyle(
//                               color: Colors.white60,
//                               fontSize: 12,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'dart:convert';
// import 'dart:io';
// import 'package:excel/excel.dart' hide Border;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:share_plus/share_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:mobile_attendance_application/presentation/widgets/logout_dialog.dart';

// class AdminDashboardScreen extends StatefulWidget {
//   const AdminDashboardScreen({super.key});

//   @override
//   State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
// }

// class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
//   // loading / state
//   bool _isLoading = true;
//   bool _isError = false;
//   String _errorMessage = '';

//   // Raw records from API
//   List<Map<String, dynamic>> _records = [];

//   // Admin profile
//   String name = '';
//   String email = '';
//   String role = '';

//   // Export busy
//   bool _isExporting = false;

//   // UI theme
//   final Color _bg = const Color(0xFF0E0E10);
//   final Color _panel = const Color(0xFF151516);
//   final Color _accent = const Color(0xFF4A148C);

//   // UI filters
//   String _searchQuery = '';
//   String? _filterUser;
//   String? _filterDept;

//   // Today-only computed lists
//   List<Map<String, dynamic>> _todayRecords = [];
//   List<Map<String, dynamic>> _todayPending = [];
//   List<Map<String, dynamic>> _todayCheckedOut = [];
//   List<Map<String, dynamic>> _todayCheckIns = [];

//   // Helper lists for dropdowns
//   List<String> _userList = [];
//   List<String> _deptList = [];

//   // Map state
//   final MapController _mapController = MapController();
//   LatLng _initialMapCenter = LatLng(20.5937, 78.9629); // India center fallback

//   @override
//   void initState() {
//     super.initState();
//     _init();
//   }

//   Future<void> _init() async {
//     await _loadAdminInfo();
//     await _fetchRecords();
//   }

//   Future<void> _loadAdminInfo() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       if (!mounted) return;
//       setState(() {
//         name = prefs.getString('name') ?? 'Admin';
//         email = prefs.getString('email') ?? '';
//         role = prefs.getString('role') ?? 'Admin';
//       });
//     } catch (_) {}
//   }

//   Future<void> _fetchRecords() async {
//     if (mounted) {
//       setState(() {
//         _isLoading = true;
//         _isError = false;
//         _errorMessage = '';
//       });
//     }

//     try {
//       final uri = Uri.parse(
//         'https://trainerattendence-backed.onrender.com/api/attendance/all',
//       );
//       final res = await http.get(uri);

//       if (res.statusCode != 200) {
//         throw Exception('Server returned ${res.statusCode}');
//       }

//       final List<dynamic> list = jsonDecode(res.body) as List<dynamic>;
//       final records = list
//           .map((e) => Map<String, dynamic>.from(e as Map))
//           .toList();

//       // build helper lists
//       final u = records
//           .map((r) => (r['userName'] ?? 'Unknown').toString())
//           .toSet()
//           .toList();
//       final d = records
//           .map((r) => (r['department'] ?? 'Unknown').toString())
//           .toSet()
//           .toList();
//       u.sort();
//       d.sort();

//       // apply today filter (local device date)
//       final now = DateTime.now();
//       final todayStart = DateTime(now.year, now.month, now.day);
//       final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

//       final todays = records.where((r) {
//         final raw = r['checkInTime'];
//         if (raw == null) return false;
//         try {
//           final dt = DateTime.parse(raw.toString());
//           return (dt.isAfter(todayStart) || dt.isAtSameMomentAs(todayStart)) &&
//               (dt.isBefore(todayEnd) || dt.isAtSameMomentAs(todayEnd));
//         } catch (_) {
//           return false;
//         }
//       }).toList();

//       // classify
//       final pending = todays.where((r) => r['checkOutTime'] == null).toList();
//       final checkedOut = todays
//           .where((r) => r['checkOutTime'] != null)
//           .toList();

//       // set default map center to first todays marker if available
//       LatLng? center;
//       for (var r in todays) {
//         final lat = _tryParseDouble(
//           r['lat'] ?? r['latitude'] ?? r['latLng']?['lat'],
//         );
//         final lng = _tryParseDouble(
//           r['lng'] ?? r['longitude'] ?? r['latLng']?['lng'],
//         );
//         if (lat != null && lng != null) {
//           center = LatLng(lat, lng);
//           break;
//         }
//       }

//       if (mounted) {
//         setState(() {
//           _records = records;
//           _userList = u;
//           _deptList = d;
//           _todayRecords = todays;
//           _todayPending = pending;
//           _todayCheckedOut = checkedOut;
//           _todayCheckIns = todays;
//           if (center != null) _initialMapCenter = center;
//           _isLoading = false;
//         });
//       }

//       // move map to center once ready
//       if (center != null) {
//         // slight delay to ensure map has initialized
//         Future.delayed(const Duration(milliseconds: 400), () {
//           try {
//             _mapController.move(center!, 13);
//           } catch (_) {}
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _isError = true;
//           _errorMessage = e.toString();
//           _records = [];
//           _todayRecords = [];
//           _todayPending = [];
//           _todayCheckedOut = [];
//         });
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Failed to load: $e')));
//       }
//     }
//   }

//   double? _tryParseDouble(dynamic v) {
//     if (v == null) return null;
//     try {
//       if (v is double) return v;
//       if (v is int) return v.toDouble();
//       return double.tryParse(v.toString());
//     } catch (_) {
//       return null;
//     }
//   }

//   DateTime _tryParse(String? raw) {
//     if (raw == null) return DateTime.fromMillisecondsSinceEpoch(0);
//     try {
//       return DateTime.parse(raw);
//     } catch (_) {
//       try {
//         return DateTime.parse(raw.replaceAll('Z', ''));
//       } catch (_) {
//         return DateTime.fromMillisecondsSinceEpoch(0);
//       }
//     }
//   }

//   Duration _computeDuration(Map<String, dynamic> r) {
//     final inRaw = r['checkInTime'];
//     final outRaw = r['checkOutTime'];
//     if (inRaw == null) return Duration.zero;
//     final inDt = _tryParse(inRaw.toString());
//     if (outRaw == null) return Duration.zero;
//     final outDt = _tryParse(outRaw.toString());
//     if (outDt.isBefore(inDt)) return Duration.zero;
//     return outDt.difference(inDt);
//   }

//   // ================= Export / Share (reused and upgraded) =================

//   Future<Directory> _getDownloadDir() async {
//     if (Platform.isAndroid) {
//       final candidate = Directory('/storage/emulated/0/Download');
//       if (await candidate.exists()) return candidate;
//       final ext = await getExternalStorageDirectory();
//       if (ext != null) return ext;
//     }
//     return await getApplicationDocumentsDirectory();
//   }

//   List<Map<String, dynamic>> _applyUIFiltersToList(
//     List<Map<String, dynamic>> src,
//   ) {
//     var list = List<Map<String, dynamic>>.from(src);
//     final q = _searchQuery.trim().toLowerCase();
//     if (q.isNotEmpty) {
//       list = list.where((r) {
//         final name = (r['userName'] ?? '').toString().toLowerCase();
//         final dept = (r['department'] ?? '').toString().toLowerCase();
//         final date = (r['checkInTime'] ?? '').toString().toLowerCase();
//         return name.contains(q) || dept.contains(q) || date.contains(q);
//       }).toList();
//     }
//     if (_filterUser != null && _filterUser!.isNotEmpty) {
//       list = list
//           .where((r) => (r['userName'] ?? '').toString() == _filterUser)
//           .toList();
//     }
//     if (_filterDept != null && _filterDept!.isNotEmpty) {
//       list = list
//           .where((r) => (r['department'] ?? '').toString() == _filterDept)
//           .toList();
//     }
//     return list;
//   }

//   Future<File?> _exportExcel(List<Map<String, dynamic>> rows) async {
//     if (rows.isEmpty) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('No records to export')));
//       }
//       return null;
//     }

//     final excel = Excel.createExcel();
//     final sheet = excel['Sheet1'];

//     sheet.appendRow([
//       TextCellValue('Name'),
//       TextCellValue('Dept'),
//       TextCellValue('Date'),
//       TextCellValue('Check-In'),
//       TextCellValue('Check-Out'),
//       TextCellValue('Duration'),
//       TextCellValue('In Address'),
//       TextCellValue('Out Address'),
//       TextCellValue('Mode In'),
//       TextCellValue('Mode Out'),
//       TextCellValue('Lat'),
//       TextCellValue('Lng'),
//     ]);

//     for (var r in rows) {
//       final dtIn = _tryParse(r['checkInTime']?.toString());
//       final dtOut = r['checkOutTime'] != null
//           ? _tryParse(r['checkOutTime'].toString())
//           : null;
//       final dateStr = dtIn.millisecondsSinceEpoch == 0
//           ? '-'
//           : DateFormat('dd MMM yyyy').format(dtIn);
//       final inStr = dtIn.millisecondsSinceEpoch == 0
//           ? '-'
//           : DateFormat('hh:mm a').format(dtIn);
//       final outStr = (dtOut == null || dtOut.millisecondsSinceEpoch == 0)
//           ? '-'
//           : DateFormat('hh:mm a').format(dtOut);
//       final dur = _computeDuration(r);
//       final durStr = dur == Duration.zero
//           ? '-'
//           : '${dur.inHours}h ${dur.inMinutes.remainder(60)}m';
//       final inAddr = (r['checkInAddress'] ?? '-').toString().replaceAll(
//         '\n',
//         ' ',
//       );
//       final outAddr = (r['checkOutAddress'] ?? '-').toString().replaceAll(
//         '\n',
//         ' ',
//       );
//       final inMode = r['checkInMode'] == true ? 'Online' : 'Offline';
//       final outMode = r['checkOutMode'] == true ? 'Online' : 'Offline';
//       final lat = r['lat'] ?? r['latitude'] ?? r['latLng']?['lat'] ?? '-';
//       final lng = r['lng'] ?? r['longitude'] ?? r['latLng']?['lng'] ?? '-';

//       sheet.appendRow([
//         TextCellValue(r['userName'] ?? '-'),
//         TextCellValue(r['department'] ?? '-'),
//         TextCellValue(dateStr),
//         TextCellValue(inStr),
//         TextCellValue(outStr),
//         TextCellValue(durStr),
//         TextCellValue(inAddr),
//         TextCellValue(outAddr),
//         TextCellValue(inMode),
//         TextCellValue(outMode),
//         TextCellValue(lat.toString()),
//         TextCellValue(lng.toString()),
//       ]);
//     }

//     final bytes = excel.encode();
//     if (bytes == null) return null;
//     final fileName =
//         'attendance_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';
//     final dir = await _getDownloadDir();
//     final file = File('${dir.path}/$fileName');
//     await file.writeAsBytes(bytes, flush: true);
//     return file;
//   }

//   Future<File?> _exportPdf(
//     List<Map<String, dynamic>> rows, {
//     String period = 'Today',
//   }) async {
//     if (rows.isEmpty) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('No records to export')));
//       }
//       return null;
//     }
//     final pdf = pw.Document();

//     // totals
//     Duration total = Duration.zero;
//     for (var r in rows) {
//       total += _computeDuration(r);
//     }

//     String formatTotal(Duration d) =>
//         "${d.inHours}h ${d.inMinutes.remainder(60)}m";

//     final tableHeaders = [
//       'Date',
//       'In',
//       'Out',
//       'Duration',
//       'In Addr',
//       'Out Addr',
//       'In Mode',
//       'Out Mode',
//     ];

//     final tableData = rows.map((r) {
//       final dtIn = _tryParse(r['checkInTime']?.toString());
//       final dtOut = r['checkOutTime'] != null
//           ? _tryParse(r['checkOutTime'].toString())
//           : null;
//       final dateStr = dtIn.millisecondsSinceEpoch == 0
//           ? '-'
//           : DateFormat('yyyy-MM-dd').format(dtIn);
//       final inStr = dtIn.millisecondsSinceEpoch == 0
//           ? '-'
//           : DateFormat('HH:mm').format(dtIn);
//       final outStr = (dtOut == null || dtOut.millisecondsSinceEpoch == 0)
//           ? '-'
//           : DateFormat('HH:mm').format(dtOut);
//       final dur = _computeDuration(r);
//       final durStr = dur == Duration.zero
//           ? '-'
//           : '${dur.inHours}h ${dur.inMinutes.remainder(60)}m';
//       final inAddr = (r['checkInAddress'] ?? '-').toString().replaceAll(
//         '\n',
//         ' ',
//       );
//       final outAddr = (r['checkOutAddress'] ?? '-').toString().replaceAll(
//         '\n',
//         ' ',
//       );
//       return [
//         dateStr,
//         inStr,
//         outStr,
//         durStr,
//         inAddr,
//         outAddr,
//         r['checkInMode'] == true ? 'Online' : 'Offline',
//         r['checkOutMode'] == true ? 'Online' : 'Offline',
//       ];
//     }).toList();

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(20),
//         footer: (context) => pw.Align(
//           alignment: pw.Alignment.centerRight,
//           child: pw.Text(
//             'Page ${context.pageNumber} of ${context.pagesCount}',
//             style: const pw.TextStyle(fontSize: 10),
//           ),
//         ),
//         build: (context) => [
//           pw.Row(
//             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//             children: [
//               pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.start,
//                 children: [
//                   pw.Text(
//                     'ATTENDANCE REPORT',
//                     style: pw.TextStyle(
//                       fontSize: 18,
//                       fontWeight: pw.FontWeight.bold,
//                       color: PdfColors.deepPurple,
//                     ),
//                   ),
//                   pw.SizedBox(height: 6),
//                   pw.Text(
//                     name.isNotEmpty ? name : 'Admin',
//                     style: pw.TextStyle(
//                       fontSize: 12,
//                       fontWeight: pw.FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               pw.Column(
//                 crossAxisAlignment: pw.CrossAxisAlignment.end,
//                 children: [
//                   pw.Text(period, style: const pw.TextStyle(fontSize: 11)),
//                   pw.SizedBox(height: 6),
//                   pw.Text(
//                     'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
//                     style: const pw.TextStyle(fontSize: 10),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           pw.SizedBox(height: 12),
//           pw.Container(
//             padding: const pw.EdgeInsets.all(10),
//             decoration: pw.BoxDecoration(
//               color: PdfColors.deepPurple50,
//               border: pw.Border.all(color: PdfColors.deepPurple, width: 1),
//               borderRadius: pw.BorderRadius.circular(6),
//             ),
//             child: pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//               children: [
//                 pw.Text(
//                   'Total Records: ${rows.length}',
//                   style: pw.TextStyle(
//                     fontSize: 12,
//                     fontWeight: pw.FontWeight.bold,
//                   ),
//                 ),
//                 pw.Text(
//                   'Total Hours: ${formatTotal(total)}',
//                   style: pw.TextStyle(
//                     fontSize: 12,
//                     fontWeight: pw.FontWeight.bold,
//                     color: PdfColors.deepPurple,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           pw.SizedBox(height: 12),
//           pw.Table.fromTextArray(
//             headers: tableHeaders,
//             data: tableData,
//             cellAlignment: pw.Alignment.centerLeft,
//             headerStyle: pw.TextStyle(
//               fontSize: 9,
//               fontWeight: pw.FontWeight.bold,
//             ),
//             cellStyle: const pw.TextStyle(fontSize: 8),
//             columnWidths: {
//               0: pw.FlexColumnWidth(1.2),
//               1: pw.FlexColumnWidth(1),
//               2: pw.FlexColumnWidth(1),
//               3: pw.FlexColumnWidth(1),
//               4: pw.FlexColumnWidth(2.5),
//               5: pw.FlexColumnWidth(2.5),
//               6: pw.FlexColumnWidth(1),
//               7: pw.FlexColumnWidth(1),
//             },
//             border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
//           ),
//         ],
//       ),
//     );

//     final bytes = await pdf.save();
//     final fileName =
//         'attendance_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';
//     final dir = await _getDownloadDir();
//     final file = File('${dir.path}/$fileName');
//     await file.writeAsBytes(bytes, flush: true);
//     return file;
//   }

//   // ================= UI Actions =================

//   Future<void> _exportFilteredExcel() async {
//     final rows = _applyUIFiltersToList(_todayRecords);
//     setState(() => _isExporting = true);
//     try {
//       final f = await _exportExcel(rows);
//       if (f != null) {
//         await OpenFilex.open(f.path);
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Excel exported: ${f.path.split('/').last}'),
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Excel export failed: $e')));
//       }
//     } finally {
//       if (mounted) setState(() => _isExporting = false);
//     }
//   }

//   Future<void> _exportFilteredPdf() async {
//     final rows = _applyUIFiltersToList(_todayRecords);
//     setState(() => _isExporting = true);
//     try {
//       final f = await _exportPdf(rows, period: 'Today');
//       if (f != null) {
//         await OpenFilex.open(f.path);
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('PDF exported: ${f.path.split('/').last}')),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('PDF export failed: $e')));
//       }
//     } finally {
//       if (mounted) setState(() => _isExporting = false);
//     }
//   }

//   Future<void> _shareFilteredExcel() async {
//     final rows = _applyUIFiltersToList(_todayRecords);
//     setState(() => _isExporting = true);
//     try {
//       final f = await _exportExcel(rows);
//       if (f != null) {
//         await Share.shareXFiles([XFile(f.path)], text: 'Attendance (Excel)');
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
//       }
//     } finally {
//       if (mounted) setState(() => _isExporting = false);
//     }
//   }

//   Future<void> _shareFilteredPdf() async {
//     final rows = _applyUIFiltersToList(_todayRecords);
//     setState(() => _isExporting = true);
//     try {
//       final f = await _exportPdf(rows, period: 'Today');
//       if (f != null) {
//         await Share.shareXFiles([XFile(f.path)], text: 'Attendance (PDF)');
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
//       }
//     } finally {
//       if (mounted) setState(() => _isExporting = false);
//     }
//   }

//   // Show user summary & focus map on user's location (if any)
//   Future<void> _showUserSummary(String userName) async {
//     final rows = _todayRecords
//         .where((r) => (r['userName'] ?? '') == userName)
//         .toList();
//     final total = rows.fold<Duration>(
//       Duration.zero,
//       (p, e) => p + _computeDuration(e),
//     );
//     final checked = rows.where((r) => r['checkOutTime'] != null).length;
//     final pending = rows.where((r) => r['checkOutTime'] == null).length;

//     // Try to find lat/lng to center
//     LatLng? center;
//     for (var r in rows) {
//       final lat = _tryParseDouble(
//         r['lat'] ?? r['latitude'] ?? r['latLng']?['lat'],
//       );
//       final lng = _tryParseDouble(
//         r['lng'] ?? r['longitude'] ?? r['latLng']?['lng'],
//       );
//       if (lat != null && lng != null) {
//         center = LatLng(lat, lng);
//         break;
//       }
//     }

//     await showDialog(
//       context: context,
//       builder: (ctx) {
//         return AlertDialog(
//           backgroundColor: _panel,
//           title: Text(userName, style: const TextStyle(color: Colors.white)),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       'Records today: ${rows.length}',
//                       style: const TextStyle(color: Colors.white70),
//                     ),
//                   ),
//                   Expanded(
//                     child: Text(
//                       'Checked: $checked',
//                       style: const TextStyle(color: Colors.white70),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       'Pending: $pending',
//                       style: const TextStyle(color: Colors.white70),
//                     ),
//                   ),
//                   Expanded(
//                     child: Text(
//                       'Total: ${total.inHours}h ${total.inMinutes.remainder(60)}m',
//                       style: const TextStyle(color: Colors.white70),
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               if (center != null)
//                 SizedBox(
//                   height: 200,
//                   width: double.infinity,
//                   child: FlutterMap(
//                     mapController: MapController(),
//                     options: MapOptions(initialCenter: center, initialZoom: 15),
//                     children: [
//                       TileLayer(
//                         urlTemplate:
//                             'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//                         subdomains: const ['a', 'b', 'c'],
//                       ),
//                       MarkerLayer(
//                         markers: [
//                           Marker(
//                             point: center,
//                             width: 50,
//                             height: 50,
//                             child: const Icon(
//                               Icons.location_on,
//                               color: Colors.red,
//                               size: 36,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 )
//               else
//                 Text(
//                   'No location available for this user today',
//                   style: const TextStyle(color: Colors.white54),
//                 ),
//             ],
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.of(ctx).pop(),
//               child: const Text('Close'),
//             ),
//           ],
//         );
//       },
//     );

//     if (center != null) {
//       _mapController.move(center, 14);
//     }
//   }

//   // Absent today list: infer roster from unique users and mark ones without today's checkin.
//   List<String> _absentToday() {
//     final allUsers = _records
//         .map((r) => (r['userName'] ?? 'Unknown').toString())
//         .toSet();
//     final present = _todayRecords
//         .map((r) => (r['userName'] ?? 'Unknown').toString())
//         .toSet();
//     final absent = allUsers.difference(present).toList()..sort();
//     return absent;
//   }

//   // Monthly analytics simple aggregation (month -> count) for last 6 months
//   Map<String, int> _monthlyCounts(int monthsBack) {
//     final now = DateTime.now();
//     final out = <String, int>{};
//     for (int i = monthsBack - 1; i >= 0; i--) {
//       final m = DateTime(now.year, now.month - i, 1);
//       final key = DateFormat('MMM yyyy').format(m);
//       out[key] = 0;
//     }
//     for (var r in _records) {
//       final dt = _tryParse(r['checkInTime']?.toString());
//       final key = DateFormat('MMM yyyy').format(DateTime(dt.year, dt.month));
//       if (out.containsKey(key)) out[key] = (out[key]! + 1);
//     }
//     return out;
//   }

//   // =================== Build UI ===================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _bg,
//       appBar: AppBar(
//         title: const Text('Admin Dashboard v2'),
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [_accent, _accent.withOpacity(0.8)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         actions: [
//           IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchRecords),
//           IconButton(
//             icon: const Icon(Icons.download),
//             onPressed: () async => await _showExportOptions(),
//           ),
//         ],
//       ),
//       drawer: _buildDrawer(),
//       body: SafeArea(
//         child: _isLoading
//             ? const Center(
//                 child: CircularProgressIndicator(color: Colors.white),
//               )
//             : _isError
//             ? _errorView()
//             : RefreshIndicator(
//                 onRefresh: _fetchRecords,
//                 color: _accent,
//                 child: ListView(
//                   padding: const EdgeInsets.all(12),
//                   children: [
//                     _buildHeader(),
//                     const SizedBox(height: 12),
//                     _buildTopFilters(),
//                     const SizedBox(height: 12),
//                     _buildMetricsRow(),
//                     const SizedBox(height: 12),
//                     _buildMapCard(),
//                     const SizedBox(height: 12),
//                     _buildPendingAlert(),
//                     const SizedBox(height: 12),
//                     _buildRecentList(),
//                     const SizedBox(height: 12),
//                     _buildAbsentCard(),
//                     const SizedBox(height: 12),
//                     _buildMonthlyAnalytics(),
//                     const SizedBox(height: 30),
//                   ],
//                 ),
//               ),
//       ),
//       floatingActionButton: _isExporting
//           ? FloatingActionButton(
//               onPressed: () {},
//               child: const CircularProgressIndicator(color: Colors.white),
//               backgroundColor: Colors.grey,
//             )
//           : null,
//     );
//   }

//   Widget _errorView() {
//     return ListView(
//       children: [
//         const SizedBox(height: 60),
//         Center(
//           child: Text(
//             'Error loading dashboard\n$_errorMessage',
//             textAlign: TextAlign.center,
//             style: const TextStyle(color: Colors.white70),
//           ),
//         ),
//       ],
//     );
//   }

//   Drawer _buildDrawer() {
//     final appGrad = LinearGradient(
//       colors: [_accent, _accent.withOpacity(0.8)],
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//     );
//     return Drawer(
//       child: Container(
//         decoration: BoxDecoration(gradient: appGrad),
//         child: Column(
//           children: [
//             DrawerHeader(
//               decoration: const BoxDecoration(color: Colors.transparent),
//               child: Row(
//                 children: [
//                   const CircleAvatar(
//                     radius: 28,
//                     backgroundColor: Colors.white,
//                     child: Icon(
//                       Icons.admin_panel_settings,
//                       color: Color(0xFF6A11CB),
//                     ),
//                   ),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           name,
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           role,
//                           style: const TextStyle(color: Colors.white70),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           email,
//                           style: const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             ListTile(
//               leading: const Icon(Icons.people, color: Colors.white),
//               title: const Text(
//                 'User List',
//                 style: TextStyle(color: Colors.white),
//               ),
//               onTap: () => Navigator.pushNamed(context, '/adminList'),
//             ),
//             ListTile(
//               leading: const Icon(Icons.history, color: Colors.white),
//               title: const Text(
//                 'Attendance History',
//                 style: TextStyle(color: Colors.white),
//               ),
//               onTap: () =>
//                   Navigator.pushNamed(context, '/adminAttendanceHistory'),
//             ),
//             const Spacer(),
//             ListTile(
//               leading: const Icon(Icons.logout, color: Colors.white),
//               title: const Text(
//                 'Logout',
//                 style: TextStyle(color: Colors.white),
//               ),
//               onTap: () => LogoutDialog.show(context),
//             ),
//             const SizedBox(height: 12),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(colors: [_accent, _accent.withOpacity(0.8)]),
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           const CircleAvatar(
//             radius: 34,
//             backgroundColor: Colors.white,
//             child: Icon(
//               Icons.admin_panel_settings,
//               color: Color(0xFF6A11CB),
//               size: 34,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Welcome back,',
//                   style: TextStyle(color: Colors.white.withOpacity(0.85)),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   name,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '$role • $email',
//                   style: const TextStyle(color: Colors.white70, fontSize: 12),
//                 ),
//               ],
//             ),
//           ),
//           PopupMenuButton<String>(
//             color: _panel,
//             icon: const Icon(Icons.more_vert, color: Colors.white),
//             onSelected: (s) {
//               if (s == 'export_today_pdf') _exportFilteredPdf();
//               if (s == 'export_today_xlsx') _exportFilteredExcel();
//             },
//             itemBuilder: (_) => [
//               const PopupMenuItem(
//                 value: 'export_today_pdf',
//                 child: Text('Export Today PDF'),
//               ),
//               const PopupMenuItem(
//                 value: 'export_today_xlsx',
//                 child: Text('Export Today Excel'),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTopFilters() {
//     return Row(
//       children: [
//         Expanded(
//           flex: 3,
//           child: TextField(
//             style: const TextStyle(color: Colors.white),
//             decoration: InputDecoration(
//               prefixIcon: const Icon(Icons.search, color: Colors.white70),
//               hintText: 'Search name / dept / date',
//               hintStyle: const TextStyle(color: Colors.white60),
//               filled: true,
//               fillColor: const Color(0xFF1A1A1A),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide.none,
//               ),
//             ),
//             onChanged: (v) {
//               setState(() => _searchQuery = v);
//             },
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           flex: 2,
//           child: DropdownButtonFormField<String?>(
//             value: _filterUser,
//             isExpanded: true,
//             dropdownColor: _panel,
//             decoration: InputDecoration(
//               fillColor: const Color(0xFF1A1A1A),
//               filled: true,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide.none,
//               ),
//             ),
//             items: <DropdownMenuItem<String?>>[
//               const DropdownMenuItem<String?>(
//                 value: null,
//                 child: Text('All users'),
//               ),
//               ..._userList.map(
//                 (u) => DropdownMenuItem<String?>(value: u, child: Text(u)),
//               ),
//             ],
//             onChanged: (v) => setState(() => _filterUser = v),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           flex: 2,
//           child: DropdownButtonFormField<String?>(
//             value: _filterDept,
//             isExpanded: true,
//             dropdownColor: _panel,
//             decoration: InputDecoration(
//               fillColor: const Color(0xFF1A1A1A),
//               filled: true,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide.none,
//               ),
//             ),
//             items: <DropdownMenuItem<String?>>[
//               const DropdownMenuItem<String?>(
//                 value: null,
//                 child: Text('All depts'),
//               ),
//               ..._deptList.map(
//                 (d) => DropdownMenuItem<String?>(value: d, child: Text(d)),
//               ),
//             ],
//             onChanged: (v) => setState(() => _filterDept = v),
//           ),
//         ),
//         const SizedBox(width: 8),
//         ElevatedButton.icon(
//           style: ElevatedButton.styleFrom(backgroundColor: _accent),
//           icon: const Icon(Icons.filter_list),
//           label: const Text('Apply'),
//           onPressed: () {
//             setState(() {});
//           },
//         ),
//       ],
//     );
//   }

//   Widget _buildMetricsRow() {
//     final filtered = _applyUIFiltersToList(_todayRecords);
//     final checkInsToday = _todayCheckIns.length;
//     final checkOutsToday = _todayCheckedOut.length;
//     final pendingToday = _todayPending.length;

//     return Row(
//       children: [
//         _metricCard(
//           'Today Check-ins',
//           checkInsToday.toString(),
//           Icons.login,
//           Colors.greenAccent,
//         ),
//         const SizedBox(width: 8),
//         _metricCard(
//           'Today Check-outs',
//           checkOutsToday.toString(),
//           Icons.logout,
//           Colors.redAccent,
//         ),
//         const SizedBox(width: 8),
//         _metricCard(
//           'Pending Check-outs',
//           pendingToday.toString(),
//           Icons.pending_actions,
//           Colors.orangeAccent,
//         ),
//         const SizedBox(width: 8),
//         _metricCard(
//           'Filtered',
//           filtered.length.toString(),
//           Icons.filter_alt,
//           Colors.blueAccent,
//         ),
//       ],
//     );
//   }

//   Widget _metricCard(String label, String value, IconData icon, Color color) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: const Color(0xFF141417),
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: Colors.white10),
//         ),
//         child: Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: color.withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Icon(icon, color: color),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     label,
//                     style: const TextStyle(color: Colors.white70, fontSize: 12),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     value,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMapCard() {
//     final markers = <Marker>[];
//     final filtered = _applyUIFiltersToList(_todayRecords);

//     for (var r in filtered) {
//       final lat = _tryParseDouble(
//         r['lat'] ?? r['latitude'] ?? r['latLng']?['lat'],
//       );
//       final lng = _tryParseDouble(
//         r['lng'] ?? r['longitude'] ?? r['latLng']?['lng'],
//       );
//       if (lat == null || lng == null) continue;
//       final point = LatLng(lat, lng);
//       final username = (r['userName'] ?? '-').toString();
//       final when = _formatShort(r['checkInTime']);
//       final isPending = r['checkOutTime'] == null;
//       markers.add(
//         Marker(
//           point: point,
//           width: 42,
//           height: 42,
//           child: GestureDetector(
//             onTap: () => _showRecordDetails(r),
//             child: Icon(
//               isPending ? Icons.location_on : Icons.check_circle,
//               color: isPending ? Colors.orange : Colors.green,
//               size: 34,
//             ),
//           ),
//         ),
//       );
//     }

//     return Card(
//       color: const Color(0xFF101012),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: SizedBox(
//         height: 240,
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: FlutterMap(
//             mapController: _mapController,
//             options: MapOptions(
//               initialCenter: _initialMapCenter,
//               initialZoom: 5,
//               minZoom: 3,
//             ),
//             children: [
//               TileLayer(
//                 urlTemplate:
//                     'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//                 subdomains: const ['a', 'b', 'c'],
//               ),
//               if (markers.isNotEmpty) MarkerLayer(markers: markers),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showRecordDetails(Map<String, dynamic> r) {
//     final name = (r['userName'] ?? '-').toString();
//     final dept = (r['department'] ?? '-').toString();
//     final inTime = _formatShort(r['checkInTime']);
//     final outTime = r['checkOutTime'] != null
//         ? _formatShort(r['checkOutTime'])
//         : 'Pending';
//     final addr = (r['checkInAddress'] ?? '-').toString();
//     final lat = _tryParseDouble(
//       r['lat'] ?? r['latitude'] ?? r['latLng']?['lat'],
//     );
//     final lng = _tryParseDouble(
//       r['lng'] ?? r['longitude'] ?? r['latLng']?['lng'],
//     );

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: _panel,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//       ),
//       builder: (ctx) {
//         return SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         name,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     Text(dept, style: const TextStyle(color: Colors.white70)),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'In: $inTime',
//                   style: const TextStyle(color: Colors.white70),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Out: $outTime',
//                   style: const TextStyle(color: Colors.white70),
//                 ),
//                 const SizedBox(height: 8),
//                 Text(
//                   'Address: $addr',
//                   style: const TextStyle(color: Colors.white70),
//                 ),
//                 const SizedBox(height: 8),
//                 if (lat != null && lng != null)
//                   SizedBox(
//                     height: 180,
//                     child: FlutterMap(
//                       options: MapOptions(
//                         initialCenter: LatLng(lat, lng),
//                         initialZoom: 15,
//                       ),
//                       children: [
//                         TileLayer(
//                           urlTemplate:
//                               'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
//                           subdomains: const ['a', 'b', 'c'],
//                         ),
//                         MarkerLayer(
//                           markers: [
//                             Marker(
//                               point: LatLng(lat, lng),
//                               width: 40,
//                               height: 40,
//                               child: const Icon(
//                                 Icons.location_on,
//                                 color: Colors.red,
//                                 size: 36,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         icon: const Icon(Icons.map),
//                         label: const Text('Focus map'),
//                         onPressed: () {
//                           if (lat != null && lng != null) {
//                             _mapController.move(LatLng(lat, lng), 14);
//                             Navigator.of(ctx).pop();
//                           }
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         icon: const Icon(Icons.share),
//                         label: const Text('Share'),
//                         onPressed: () async {
//                           final txt =
//                               '$name\nIn: $inTime\nOut: $outTime\nAddr: $addr${lat != null && lng != null ? '\nLocation: $lat,$lng' : ''}';
//                           await Share.share(txt);
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildPendingAlert() {
//     if (_todayPending.isEmpty) return const SizedBox.shrink();
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.orange.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.warning, color: Colors.orange),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Text(
//               'There are ${_todayPending.length} pending check-outs today. Tap to view.',
//               style: const TextStyle(color: Colors.white70),
//             ),
//           ),
//           ElevatedButton(
//             child: const Text('View'),
//             onPressed: () => _showPendingList(),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _showPendingList() async {
//     final rows = _applyUIFiltersToList(_todayPending);
//     await showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: _panel,
//         title: const Text(
//           'Pending Check-outs (Today)',
//           style: TextStyle(color: Colors.white),
//         ),
//         content: SizedBox(
//           width: double.maxFinite,
//           child: ListView.separated(
//             shrinkWrap: true,
//             itemCount: rows.length,
//             separatorBuilder: (_, __) => const Divider(color: Colors.white12),
//             itemBuilder: (ctx2, i) {
//               final r = rows[i];
//               final user = (r['userName'] ?? '-').toString();
//               final inTime = _formatShort(r['checkInTime']);
//               return ListTile(
//                 tileColor: const Color(0xFF101012),
//                 leading: CircleAvatar(
//                   child: Text(user.isNotEmpty ? user[0].toUpperCase() : '?'),
//                 ),
//                 title: Text(user, style: const TextStyle(color: Colors.white)),
//                 subtitle: Text(
//                   'In: $inTime',
//                   style: const TextStyle(color: Colors.white70),
//                 ),
//                 trailing: ElevatedButton(
//                   child: const Text('Details'),
//                   onPressed: () => _showRecordDetails(r),
//                 ),
//               );
//             },
//           ),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(),
//             child: const Text('Close'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildRecentList() {
//     final filtered = _applyUIFiltersToList(_todayRecords);
//     if (filtered.isEmpty) {
//       return Card(
//         color: const Color(0xFF101012),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Text(
//             'No check-ins found for today',
//             style: const TextStyle(color: Colors.white70),
//           ),
//         ),
//       );
//     }
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Today\'s Check-ins',
//           style: TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Column(
//           children: filtered.map((r) {
//             final user = (r['userName'] ?? '-').toString();
//             final dept = (r['department'] ?? '-').toString();
//             final inStr = _formatShort(r['checkInTime']);
//             final outStr = r['checkOutTime'] != null
//                 ? _formatShort(r['checkOutTime'])
//                 : 'Pending';
//             final pending = r['checkOutTime'] == null;
//             return Padding(
//               padding: const EdgeInsets.only(bottom: 8),
//               child: _ActivityTileSimple(
//                 name: user,
//                 department: dept,
//                 inTime: inStr,
//                 outTime: outStr,
//                 pending: pending,
//                 onTap: () => _showRecordDetails(r),
//                 onSummaryTap: () => _showUserSummary(user),
//               ),
//             );
//           }).toList(),
//         ),
//       ],
//     );
//   }

//   Widget _buildAbsentCard() {
//     final absent = _absentToday();
//     if (absent.isEmpty) return const SizedBox.shrink();
//     return Card(
//       color: const Color(0xFF101012),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Absent Today',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 8),
//             SizedBox(
//               height: 60,
//               child: ListView.separated(
//                 scrollDirection: Axis.horizontal,
//                 itemBuilder: (_, i) => Chip(
//                   label: Text(absent[i]),
//                   backgroundColor: const Color(0xFF1A1A1A),
//                 ),
//                 separatorBuilder: (_, __) => const SizedBox(width: 8),
//                 itemCount: absent.length,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMonthlyAnalytics() {
//     final data = _monthlyCounts(6);
//     final labels = data.keys.toList();
//     final values = data.values.toList();
//     final max = values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b);
//     return Card(
//       color: const Color(0xFF101012),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(12),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Monthly Check-ins (last 6 months)',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             const SizedBox(height: 12),
//             SizedBox(
//               height: 120,
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.end,
//                 children: [
//                   for (int i = 0; i < labels.length; i++)
//                     Expanded(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.end,
//                         children: [
//                           AnimatedContainer(
//                             duration: const Duration(milliseconds: 500),
//                             height: (values[i] / (max == 0 ? 1 : max)) * 80 + 8,
//                             width: 22,
//                             decoration: BoxDecoration(
//                               color: _accent,
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             labels[i],
//                             style: const TextStyle(
//                               color: Colors.white70,
//                               fontSize: 10,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             values[i].toString(),
//                             style: const TextStyle(
//                               color: Colors.white70,
//                               fontSize: 11,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Export options quick sheet
//   Future<void> _showExportOptions() async {
//     final rows = _applyUIFiltersToList(_todayRecords);
//     await showModalBottomSheet(
//       context: context,
//       backgroundColor: _panel,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
//       ),
//       builder: (ctx) {
//         return SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   'Export ${rows.length} records (today)',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 12),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: _accent,
//                         ),
//                         icon: const Icon(Icons.picture_as_pdf),
//                         label: const Text('Export PDF'),
//                         onPressed: () {
//                           Navigator.of(ctx).pop();
//                           _exportFilteredPdf();
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: ElevatedButton.icon(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.green,
//                         ),
//                         icon: const Icon(Icons.table_view),
//                         label: const Text('Export Excel'),
//                         onPressed: () {
//                           Navigator.of(ctx).pop();
//                           _exportFilteredExcel();
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         icon: const Icon(Icons.share),
//                         label: const Text('Share PDF'),
//                         onPressed: () {
//                           Navigator.of(ctx).pop();
//                           _shareFilteredPdf();
//                         },
//                       ),
//                     ),
//                     const SizedBox(width: 8),
//                     Expanded(
//                       child: OutlinedButton.icon(
//                         icon: const Icon(Icons.share_outlined),
//                         label: const Text('Share Excel'),
//                         onPressed: () {
//                           Navigator.of(ctx).pop();
//                           _shareFilteredExcel();
//                         },
//                       ),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }

//   String _formatShort(dynamic raw) {
//     if (raw == null) return 'N/A';
//     try {
//       final dt = DateTime.parse(raw.toString());
//       return DateFormat('dd MMM, hh:mm a').format(dt);
//     } catch (_) {
//       return raw.toString();
//     }
//   }
// }

// // small activity tile used in recent list (compact)
// class _ActivityTileSimple extends StatelessWidget {
//   final String name;
//   final String department;
//   final String inTime;
//   final String outTime;
//   final bool pending;
//   final VoidCallback? onTap;
//   final VoidCallback? onSummaryTap;

//   const _ActivityTileSimple({
//     required this.name,
//     required this.department,
//     required this.inTime,
//     required this.outTime,
//     this.pending = false,
//     this.onTap,
//     this.onSummaryTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: const Color(0xFF141416),
//       borderRadius: BorderRadius.circular(10),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(10),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//           child: Row(
//             children: [
//               CircleAvatar(
//                 radius: 24,
//                 backgroundColor: Colors.white12,
//                 child: Text(
//                   name.isNotEmpty ? name[0].toUpperCase() : '?',
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             name,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         GestureDetector(
//                           onTap: onSummaryTap,
//                           child: const Icon(
//                             Icons.info_outline,
//                             color: Colors.white70,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 6),
//                     Text(
//                       department,
//                       style: const TextStyle(
//                         color: Colors.white70,
//                         fontSize: 12,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         const Icon(
//                           Icons.login,
//                           size: 14,
//                           color: Colors.greenAccent,
//                         ),
//                         const SizedBox(width: 6),
//                         Text(
//                           'In: $inTime',
//                           style: const TextStyle(color: Colors.white60),
//                         ),
//                         const SizedBox(width: 12),
//                         const Icon(
//                           Icons.logout,
//                           size: 14,
//                           color: Colors.redAccent,
//                         ),
//                         const SizedBox(width: 6),
//                         Text(
//                           'Out: $outTime',
//                           style: const TextStyle(color: Colors.white60),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 8),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: pending ? Colors.orange : Colors.green,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   pending ? 'Pending' : 'Checked',
//                   style: const TextStyle(color: Colors.black87),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // admin_dashboard_v2.dart
// import 'dart:convert';
// import 'dart:io';
// import 'package:excel/excel.dart' hide Border;
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:share_plus/share_plus.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:mobile_attendance_application/presentation/widgets/logout_dialog.dart';

// class AdminDashboardScreen extends StatefulWidget {
//   const AdminDashboardScreen({super.key});

//   @override
//   State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
// }

// class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
//   // state
//   bool _isLoading = true;
//   bool _isError = false;
//   String _errorMessage = '';

//   // data
//   List<Map<String, dynamic>> _records = [];
//   List<Map<String, dynamic>> _todayRecords = [];

//   // admin profile
//   String name = '';
//   String email = '';
//   String role = '';

//   // export
//   bool _isExporting = false;

//   // theme
//   final Color _bg = const Color(0xFF0E0E10);
//   final Color _panel = const Color(0xFF151516);
//   final Color _accent = const Color(0xFF4A148C);

//   // filters
//   String _searchQuery = '';
//   String? _filterUser;
//   String? _filterDept;

//   // lists for dropdowns
//   List<String> _userList = [];
//   List<String> _deptList = [];

//   // computed lists
//   List<Map<String, dynamic>> get _activeRecords =>
//       _viewMode == 'today' ? _applyUIFiltersToList(_todayRecords) : _applyUIFiltersToList(_records);

//   List<Map<String, dynamic>> get _activePending =>
//       _activeRecords.where((r) => r['checkOutTime'] == null).toList();

//   // view mode: 'today' or 'all'
//   String _viewMode = 'today';

//   // map
//   final MapController _mapController = MapController();
//   LatLng _initialMapCenter = LatLng(20.5937, 78.9629); // India fallback

//   @override
//   void initState() {
//     super.initState();
//     _init();
//   }

//   Future<void> _init() async {
//     await _loadAdminInfo();
//     await _fetchRecords();
//   }

//   Future<void> _loadAdminInfo() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       if (!mounted) return;
//       setState(() {
//         name = prefs.getString('name') ?? 'Admin';
//         email = prefs.getString('email') ?? '';
//         role = prefs.getString('role') ?? 'Admin';
//       });
//     } catch (_) {
//       // ignore
//     }
//   }

//   Future<void> _fetchRecords() async {
//     if (mounted) {
//       setState(() {
//         _isLoading = true;
//         _isError = false;
//         _errorMessage = '';
//       });
//     }

//     try {
//       final uri = Uri.parse('https://trainerattendence-backed.onrender.com/api/attendance/all');
//       final res = await http.get(uri).timeout(const Duration(seconds: 20));

//       if (res.statusCode != 200) {
//         throw Exception('Server returned ${res.statusCode}');
//       }

//       final list = jsonDecode(res.body) as List<dynamic>;
//       final records = list.map((e) => Map<String, dynamic>.from(e as Map)).toList();

//       // helper lists
//       final users = records.map((r) => (r['userName'] ?? 'Unknown').toString()).toSet().toList();
//       final depts = records.map((r) => (r['department'] ?? 'Unknown').toString()).toSet().toList();
//       users.sort();
//       depts.sort();

//       // compute today's records (local device date)
//       final now = DateTime.now();
//       final todayStart = DateTime(now.year, now.month, now.day);
//       final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

//       final todays = records.where((r) {
//         final raw = r['checkInTime'];
//         if (raw == null) return false;
//         try {
//           final dt = DateTime.parse(raw.toString());
//           return (dt.isAfter(todayStart) || dt.isAtSameMomentAs(todayStart)) &&
//               (dt.isBefore(todayEnd) || dt.isAtSameMomentAs(todayEnd));
//         } catch (_) {
//           // try fallback parse removing Z
//           try {
//             final dt = DateTime.parse(raw.toString().replaceAll('Z', ''));
//             return (dt.isAfter(todayStart) || dt.isAtSameMomentAs(todayStart)) &&
//                 (dt.isBefore(todayEnd) || dt.isAtSameMomentAs(todayEnd));
//           } catch (_) {
//             return false;
//           }
//         }
//       }).toList();

//       // choose initial map center from first available lat/lng
//       LatLng? center;
//       for (var r in todays.isNotEmpty ? todays : records) {
//         final lat = _tryParseDouble(r['lat'] ?? r['latitude'] ?? r['latLng']?['lat']);
//         final lng = _tryParseDouble(r['lng'] ?? r['longitude'] ?? r['latLng']?['lng']);
//         if (lat != null && lng != null) {
//           center = LatLng(lat, lng);
//           break;
//         }
//       }

//       if (mounted) {
//         setState(() {
//           _records = records;
//           _userList = users;
//           _deptList = depts;
//           _todayRecords = todays;
//           if (center != null) _initialMapCenter = center;
//           _isLoading = false;
//         });
//       }

//       // Move map after first frame rendered (safe)
//       if (center != null) {
//         WidgetsBinding.instance.addPostFrameCallback((_) {
//           try {
//             _mapController.move(center!, 13);
//           } catch (_) {}
//         });
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//           _isError = true;
//           _errorMessage = e.toString();
//           _records = [];
//           _todayRecords = [];
//         });
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load: $e')));
//       }
//     }
//   }

//   // parsing helpers
//   double? _tryParseDouble(dynamic v) {
//     if (v == null) return null;
//     try {
//       if (v is double) return v;
//       if (v is int) return v.toDouble();
//       return double.tryParse(v.toString());
//     } catch (_) {
//       return null;
//     }
//   }

//   DateTime _tryParse(String? raw) {
//     if (raw == null) return DateTime.fromMillisecondsSinceEpoch(0);
//     try {
//       return DateTime.parse(raw);
//     } catch (_) {
//       try {
//         return DateTime.parse(raw.replaceAll('Z', ''));
//       } catch (_) {
//         return DateTime.fromMillisecondsSinceEpoch(0);
//       }
//     }
//   }

//   Duration _computeDuration(Map<String, dynamic> r) {
//     final inRaw = r['checkInTime'];
//     final outRaw = r['checkOutTime'];
//     if (inRaw == null) return Duration.zero;
//     final inDt = _tryParse(inRaw.toString());
//     if (outRaw == null) return Duration.zero;
//     final outDt = _tryParse(outRaw.toString());
//     if (outDt.isBefore(inDt)) return Duration.zero;
//     return outDt.difference(inDt);
//   }

//   // export helpers
//   Future<Directory> _getDownloadDir() async {
//     if (Platform.isAndroid) {
//       final candidate = Directory('/storage/emulated/0/Download');
//       if (await candidate.exists()) return candidate;
//       final ext = await getExternalStorageDirectory();
//       if (ext != null) return ext;
//     }
//     return await getApplicationDocumentsDirectory();
//   }

//   List<Map<String, dynamic>> _applyUIFiltersToList(List<Map<String, dynamic>> src) {
//     var list = List<Map<String, dynamic>>.from(src);
//     final q = _searchQuery.trim().toLowerCase();
//     if (q.isNotEmpty) {
//       list = list.where((r) {
//         final name = (r['userName'] ?? '').toString().toLowerCase();
//         final dept = (r['department'] ?? '').toString().toLowerCase();
//         final date = (r['checkInTime'] ?? '').toString().toLowerCase();
//         return name.contains(q) || dept.contains(q) || date.contains(q);
//       }).toList();
//     }
//     if (_filterUser != null && _filterUser!.isNotEmpty) {
//       list = list.where((r) => (r['userName'] ?? '').toString() == _filterUser).toList();
//     }
//     if (_filterDept != null && _filterDept!.isNotEmpty) {
//       list = list.where((r) => (r['department'] ?? '').toString() == _filterDept).toList();
//     }
//     // newest-first
//     list.sort((a, b) => _tryParse(b['checkInTime']?.toString()).compareTo(_tryParse(a['checkInTime']?.toString())));
//     return list;
//   }

//   Future<File?> _exportExcel(List<Map<String, dynamic>> rows) async {
//     if (rows.isEmpty) {
//       if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No records to export')));
//       return null;
//     }

//     final excel = Excel.createExcel();
//     final sheet = excel['Sheet1'];

//     sheet.appendRow([
//       TextCellValue('Name'),
//       TextCellValue('Dept'),
//       TextCellValue('Date'),
//       TextCellValue('Check-In'),
//       TextCellValue('Check-Out'),
//       TextCellValue('Duration'),
//       TextCellValue('In Address'),
//       TextCellValue('Out Address'),
//       TextCellValue('Mode In'),
//       TextCellValue('Mode Out'),
//       TextCellValue('Lat'),
//       TextCellValue('Lng'),
//     ]);

//     for (var r in rows) {
//       final dtIn = _tryParse(r['checkInTime']?.toString());
//       final dtOut = r['checkOutTime'] != null ? _tryParse(r['checkOutTime'].toString()) : null;
//       final dateStr = dtIn.millisecondsSinceEpoch == 0 ? '-' : DateFormat('dd MMM yyyy').format(dtIn);
//       final inStr = dtIn.millisecondsSinceEpoch == 0 ? '-' : DateFormat('hh:mm a').format(dtIn);
//       final outStr = (dtOut == null || dtOut.millisecondsSinceEpoch == 0) ? '-' : DateFormat('hh:mm a').format(dtOut);
//       final dur = _computeDuration(r);
//       final durStr = dur == Duration.zero ? '-' : '${dur.inHours}h ${dur.inMinutes.remainder(60)}m';
//       final inAddr = (r['checkInAddress'] ?? '-').toString().replaceAll('\n', ' ');
//       final outAddr = (r['checkOutAddress'] ?? '-').toString().replaceAll('\n', ' ');
//       final inMode = r['checkInMode'] == true ? 'Online' : 'Offline';
//       final outMode = r['checkOutMode'] == true ? 'Online' : 'Offline';
//       final lat = r['lat'] ?? r['latitude'] ?? r['latLng']?['lat'] ?? '-';
//       final lng = r['lng'] ?? r['longitude'] ?? r['latLng']?['lng'] ?? '-';

//       sheet.appendRow([
//         TextCellValue(r['userName'] ?? '-'),
//         TextCellValue(r['department'] ?? '-'),
//         TextCellValue(dateStr),
//         TextCellValue(inStr),
//         TextCellValue(outStr),
//         TextCellValue(durStr),
//         TextCellValue(inAddr),
//         TextCellValue(outAddr),
//         TextCellValue(inMode),
//         TextCellValue(outMode),
//         TextCellValue(lat.toString()),
//         TextCellValue(lng.toString()),
//       ]);
//     }

//     final bytes = excel.encode();
//     if (bytes == null) return null;
//     final fileName = 'attendance_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';
//     final dir = await _getDownloadDir();
//     final file = File('${dir.path}/$fileName');
//     await file.writeAsBytes(bytes, flush: true);
//     return file;
//   }

//   Future<File?> _exportPdf(List<Map<String, dynamic>> rows, {String period = 'Today'}) async {
//     if (rows.isEmpty) {
//       if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No records to export')));
//       return null;
//     }

//     final pdf = pw.Document();
//     Duration total = Duration.zero;
//     for (var r in rows) total += _computeDuration(r);

//     String formatTotal(Duration d) => "${d.inHours}h ${d.inMinutes.remainder(60)}m";

//     final tableHeaders = ['Date', 'In', 'Out', 'Duration', 'In Addr', 'Out Addr', 'In Mode', 'Out Mode'];

//     final tableData = rows.map((r) {
//       final dtIn = _tryParse(r['checkInTime']?.toString());
//       final dtOut = r['checkOutTime'] != null ? _tryParse(r['checkOutTime'].toString()) : null;
//       final dateStr = dtIn.millisecondsSinceEpoch == 0 ? '-' : DateFormat('yyyy-MM-dd').format(dtIn);
//       final inStr = dtIn.millisecondsSinceEpoch == 0 ? '-' : DateFormat('HH:mm').format(dtIn);
//       final outStr = (dtOut == null || dtOut.millisecondsSinceEpoch == 0) ? '-' : DateFormat('HH:mm').format(dtOut);
//       final dur = _computeDuration(r);
//       final durStr = dur == Duration.zero ? '-' : '${dur.inHours}h ${dur.inMinutes.remainder(60)}m';
//       final inAddr = (r['checkInAddress'] ?? '-').toString().replaceAll('\n', ' ');
//       final outAddr = (r['checkOutAddress'] ?? '-').toString().replaceAll('\n', ' ');
//       return [dateStr, inStr, outStr, durStr, inAddr, outAddr, r['checkInMode'] == true ? 'Online' : 'Offline', r['checkOutMode'] == true ? 'Online' : 'Offline'];
//     }).toList();

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         margin: const pw.EdgeInsets.all(20),
//         footer: (context) => pw.Align(alignment: pw.Alignment.centerRight, child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', style: const pw.TextStyle(fontSize: 10))),
//         build: (context) => [
//           pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
//             pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
//               pw.Text('ATTENDANCE REPORT', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple)),
//               pw.SizedBox(height: 6),
//               pw.Text(name.isNotEmpty ? name : 'Admin', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
//             ]),
//             pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.end, children: [
//               pw.Text(period, style: const pw.TextStyle(fontSize: 11)),
//               pw.SizedBox(height: 6),
//               pw.Text('Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}', style: const pw.TextStyle(fontSize: 10)),
//             ]),
//           ]),
//           pw.SizedBox(height: 12),
//           pw.Container(padding: const pw.EdgeInsets.all(10), decoration: pw.BoxDecoration(color: PdfColors.deepPurple50, border: pw.Border.all(color: PdfColors.deepPurple, width: 1), borderRadius: pw.BorderRadius.circular(6)), child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
//             pw.Text('Total Records: ${rows.length}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
//             pw.Text('Total Hours: ${formatTotal(total)}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.deepPurple)),
//           ])),
//           pw.SizedBox(height: 12),
//           pw.Table.fromTextArray(headers: tableHeaders, data: tableData, cellAlignment: pw.Alignment.centerLeft, headerStyle: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold), cellStyle: const pw.TextStyle(fontSize: 8), columnWidths: {
//             0: pw.FlexColumnWidth(1.2),
//             1: pw.FlexColumnWidth(1),
//             2: pw.FlexColumnWidth(1),
//             3: pw.FlexColumnWidth(1),
//             4: pw.FlexColumnWidth(2.5),
//             5: pw.FlexColumnWidth(2.5),
//             6: pw.FlexColumnWidth(1),
//             7: pw.FlexColumnWidth(1),
//           }, border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5)),
//         ],
//       ),
//     );

//     final bytes = await pdf.save();
//     final fileName = 'attendance_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';
//     final dir = await _getDownloadDir();
//     final file = File('${dir.path}/$fileName');
//     await file.writeAsBytes(bytes, flush: true);
//     return file;
//   }

//   // UI actions (export/share)
//   Future<void> _exportFilteredExcel() async {
//     final rows = _activeRecords;
//     setState(() => _isExporting = true);
//     try {
//       final f = await _exportExcel(rows);
//       if (f != null) {
//         await OpenFilex.open(f.path);
//         if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Excel exported: ${f.path.split('/').last}')));
//       }
//     } catch (e) {
//       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Excel export failed: $e')));
//     } finally {
//       if (mounted) setState(() => _isExporting = false);
//     }
//   }

//   Future<void> _exportFilteredPdf() async {
//     final rows = _activeRecords;
//     setState(() => _isExporting = true);
//     try {
//       final f = await _exportPdf(rows, period: _viewMode == 'today' ? 'Today' : 'All records');
//       if (f != null) {
//         await OpenFilex.open(f.path);
//         if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF exported: ${f.path.split('/').last}')));
//       }
//     } catch (e) {
//       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('PDF export failed: $e')));
//     } finally {
//       if (mounted) setState(() => _isExporting = false);
//     }
//   }

//   Future<void> _shareFilteredExcel() async {
//     final rows = _activeRecords;
//     setState(() => _isExporting = true);
//     try {
//       final f = await _exportExcel(rows);
//       if (f != null) {
//         await Share.shareXFiles([XFile(f.path)], text: 'Attendance (Excel)');
//       }
//     } catch (e) {
//       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Share failed: $e')));
//     } finally {
//       if (mounted) setState(() => _isExporting = false);
//     }
//   }

//   Future<void> _shareFilteredPdf() async {
//     final rows = _activeRecords;
//     setState(() => _isExporting = true);
//     try {
//       final f = await _exportPdf(rows, period: _viewMode == 'today' ? 'Today' : 'All records');
//       if (f != null) {
//         await Share.shareXFiles([XFile(f.path)], text: 'Attendance (PDF)');
//       }
//     } catch (e) {
//       if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Share failed: $e')));
//     } finally {
//       if (mounted) setState(() => _isExporting = false);
//     }
//   }

//   // user summary & map focus
//   Future<void> _showUserSummary(String userName) async {
//     final rows = (_viewMode == 'today' ? _todayRecords : _records).where((r) => (r['userName'] ?? '') == userName).toList();
//     final total = rows.fold<Duration>(Duration.zero, (p, e) => p + _computeDuration(e));
//     final checked = rows.where((r) => r['checkOutTime'] != null).length;
//     final pending = rows.where((r) => r['checkOutTime'] == null).length;

//     // find lat/lng
//     LatLng? center;
//     for (var r in rows) {
//       final lat = _tryParseDouble(r['lat'] ?? r['latitude'] ?? r['latLng']?['lat']);
//       final lng = _tryParseDouble(r['lng'] ?? r['longitude'] ?? r['latLng']?['lng']);
//       if (lat != null && lng != null) {
//         center = LatLng(lat, lng);
//         break;
//       }
//     }

//     await showDialog(
//       context: context,
//       builder: (ctx) {
//         return AlertDialog(
//           backgroundColor: _panel,
//           title: Text(userName, style: const TextStyle(color: Colors.white)),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Row(children: [Expanded(child: Text('Records: ${rows.length}', style: const TextStyle(color: Colors.white70))), Expanded(child: Text('Checked: $checked', style: const TextStyle(color: Colors.white70)))]),
//               const SizedBox(height: 8),
//               Row(children: [Expanded(child: Text('Pending: $pending', style: const TextStyle(color: Colors.white70))), Expanded(child: Text('Total: ${total.inHours}h ${total.inMinutes.remainder(60)}m', style: const TextStyle(color: Colors.white70)))]),
//               const SizedBox(height: 12),
//               if (center != null)
//                 SizedBox(
//                   height: 200,
//                   width: double.infinity,
//                   child: FlutterMap(
//                     options: MapOptions(initialCenter: center, initialZoom: 15),
//                     children: [
//                       TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', subdomains: const ['a', 'b', 'c']),
//                       MarkerLayer(markers: [Marker(point: center, width: 48, height: 48, child:  const Icon(Icons.location_on, color: Colors.red, size: 36))]),
//                     ],
//                   ),
//                 )
//               else
//                 const Text('No location available for this user', style: TextStyle(color: Colors.white54)),
//             ],
//           ),
//           actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close'))],
//         );
//       },
//     );

//     if (center != null) {
//       try {
//         _mapController.move(center, 14);
//       } catch (_) {}
//     }
//   }

//   // absent & analytics
//   List<String> _absentToday() {
//     final allUsers = _records.map((r) => (r['userName'] ?? 'Unknown').toString()).toSet();
//     final present = _todayRecords.map((r) => (r['userName'] ?? 'Unknown').toString()).toSet();
//     final absent = allUsers.difference(present).toList()..sort();
//     return absent;
//   }

//   Map<String, int> _monthlyCounts(int monthsBack) {
//     final now = DateTime.now();
//     final out = <String, int>{};
//     for (int i = monthsBack - 1; i >= 0; i--) {
//       final m = DateTime(now.year, now.month - i, 1);
//       final key = DateFormat('MMM yyyy').format(m);
//       out[key] = 0;
//     }
//     for (var r in _records) {
//       final dt = _tryParse(r['checkInTime']?.toString());
//       final key = DateFormat('MMM yyyy').format(DateTime(dt.year, dt.month));
//       if (out.containsKey(key)) out[key] = (out[key]! + 1);
//     }
//     return out;
//   }

//   // ================== BUILD UI ==================
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _bg,
//       appBar: AppBar(
//         title: const Text('Admin Dashboard v2'),
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         flexibleSpace: Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [_accent, _accent.withOpacity(0.85)], begin: Alignment.topLeft, end: Alignment.bottomRight))),
//         actions: [
//           IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchRecords),
//           IconButton(icon: const Icon(Icons.download), onPressed: () async => await _showExportOptions()),
//         ],
//       ),
//       drawer: _buildDrawer(),
//       body: SafeArea(
//         child: _isLoading
//             ? const Center(child: CircularProgressIndicator(color: Colors.white))
//             : _isError
//                 ? _errorView()
//                 : RefreshIndicator(
//                     onRefresh: _fetchRecords,
//                     color: _accent,
//                     child: ListView(
//                       padding: const EdgeInsets.all(12),
//                       children: [
//                         _buildHeader(),
//                         const SizedBox(height: 12),
//                         _buildTopFilters(),
//                         const SizedBox(height: 12),
//                         _buildViewToggle(),
//                         const SizedBox(height: 12),
//                         _buildMetricsRow(),
//                         const SizedBox(height: 12),
//                         _buildMapCard(),
//                         const SizedBox(height: 12),
//                         _buildPendingAlert(),
//                         const SizedBox(height: 12),
//                         _buildRecentList(),
//                         const SizedBox(height: 12),
//                         _buildAbsentCard(),
//                         const SizedBox(height: 12),
//                         _buildMonthlyAnalytics(),
//                         const SizedBox(height: 30),
//                       ],
//                     ),
//                   ),
//       ),
//       floatingActionButton: _isExporting ? FloatingActionButton(onPressed: () {}, child: const CircularProgressIndicator(color: Colors.white), backgroundColor: Colors.grey) : null,
//     );
//   }

//   Widget _errorView() {
//     return ListView(children: [const SizedBox(height: 60), Center(child: Text('Error loading dashboard\n$_errorMessage', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)))]);
//   }

//   Drawer _buildDrawer() {
//     final appGrad = LinearGradient(colors: [_accent, _accent.withOpacity(0.8)], begin: Alignment.topLeft, end: Alignment.bottomRight);
//     return Drawer(
//       child: Container(
//         decoration: BoxDecoration(gradient: appGrad),
//         child: Column(
//           children: [
//             DrawerHeader(
//               decoration: const BoxDecoration(color: Colors.transparent),
//               child: Row(
//                 children: [
//                   const CircleAvatar(radius: 28, backgroundColor: Colors.white, child: Icon(Icons.admin_panel_settings, color: Color(0xFF6A11CB))),
//                   const SizedBox(width: 12),
//                   Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)), const SizedBox(height: 4), Text(role, style: const TextStyle(color: Colors.white70)), const SizedBox(height: 2), Text(email, style: const TextStyle(color: Colors.white70, fontSize: 12))])),
//                 ],
//               ),
//             ),
//             ListTile(leading: const Icon(Icons.people, color: Colors.white), title: const Text('User List', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pushNamed(context, '/adminList')),
//             ListTile(leading: const Icon(Icons.history, color: Colors.white), title: const Text('Attendance History', style: TextStyle(color: Colors.white)), onTap: () => Navigator.pushNamed(context, '/adminAttendanceHistory')),
//             const Spacer(),
//             ListTile(leading: const Icon(Icons.logout, color: Colors.white), title: const Text('Logout', style: TextStyle(color: Colors.white)), onTap: () => LogoutDialog.show(context)),
//             const SizedBox(height: 12),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(gradient: LinearGradient(colors: [_accent, _accent.withOpacity(0.85)]), borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]),
//       child: Row(
//         children: [
//           const CircleAvatar(radius: 34, backgroundColor: Colors.white, child: Icon(Icons.admin_panel_settings, color: Color(0xFF6A11CB), size: 34)),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Welcome back,', style: TextStyle(color: Colors.white.withOpacity(0.85))), const SizedBox(height: 6), Text(name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 4), Text('$role • $email', style: const TextStyle(color: Colors.white70, fontSize: 12))]),
//           ),
//           PopupMenuButton<String>(
//             color: _panel,
//             icon: const Icon(Icons.more_vert, color: Colors.white),
//             onSelected: (s) {
//               if (s == 'export_today_pdf') _exportFilteredPdf();
//               if (s == 'export_today_xlsx') _exportFilteredExcel();
//             },
//             itemBuilder: (_) => const [PopupMenuItem(value: 'export_today_pdf', child: Text('Export Today PDF')), PopupMenuItem(value: 'export_today_xlsx', child: Text('Export Today Excel'))],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTopFilters() {
//     return Row(children: [
//       Expanded(
//         flex: 3,
//         child: TextField(
//           style: const TextStyle(color: Colors.white),
//           decoration: InputDecoration(prefixIcon: const Icon(Icons.search, color: Colors.white70), hintText: 'Search name / dept / date', hintStyle: const TextStyle(color: Colors.white60), filled: true, fillColor: const Color(0xFF1A1A1A), border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
//           onChanged: (v) => setState(() => _searchQuery = v),
//         ),
//       ),
//       const SizedBox(width: 8),
//       Expanded(
//         flex: 2,
//         child: DropdownButtonFormField<String?>(
//           value: _filterUser,
//           isExpanded: true,
//           dropdownColor: _panel,
//           decoration: InputDecoration(fillColor: const Color(0xFF1A1A1A), filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
//           items: <DropdownMenuItem<String?>>[
//             const DropdownMenuItem<String?>(value: null, child: Text('All users')),
//             ..._userList.map((u) => DropdownMenuItem<String?>(value: u, child: Text(u))).toList(),
//           ],
//           onChanged: (v) => setState(() => _filterUser = v),
//         ),
//       ),
//       const SizedBox(width: 8),
//       Expanded(
//         flex: 2,
//         child: DropdownButtonFormField<String?>(
//           value: _filterDept,
//           isExpanded: true,
//           dropdownColor: _panel,
//           decoration: InputDecoration(fillColor: const Color(0xFF1A1A1A), filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none)),
//           items: <DropdownMenuItem<String?>>[
//             const DropdownMenuItem<String?>(value: null, child: Text('All depts')),
//             ..._deptList.map((d) => DropdownMenuItem<String?>(value: d, child: Text(d))).toList(),
//           ],
//           onChanged: (v) => setState(() => _filterDept = v),
//         ),
//       ),
//       const SizedBox(width: 8),
//       ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: _accent), icon: const Icon(Icons.filter_list), label: const Text('Apply'), onPressed: () => setState(() {})),
//     ]);
//   }

//   Widget _buildViewToggle() {
//     return Row(children: [
//       const Text('View: ', style: TextStyle(color: Colors.white70)),
//       const SizedBox(width: 8),
//       ToggleButtons(
//         isSelected: [_viewMode == 'today', _viewMode == 'all'],
//         onPressed: (i) {
//           setState(() {
//             _viewMode = i == 0 ? 'today' : 'all';
//           });
//         },
//         borderRadius: BorderRadius.circular(6),
//         selectedColor: Colors.white,
//         fillColor: _accent,
//         color: Colors.white70,
//         children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('Today')), Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text('All'))],
//       )
//     ]);
//   }

//   Widget _buildMetricsRow() {
//     final filtered = _activeRecords;
//     final checkInsToday = _todayRecords.length;
//     final checkOutsToday = _todayRecords.where((r) => r['checkOutTime'] != null).length;
//     final pendingToday = _todayRecords.where((r) => r['checkOutTime'] == null).length;

//     final checkInsAll = _records.length;
//     final checkOutsAll = _records.where((r) => r['checkOutTime'] != null).length;
//     final pendingAll = _records.where((r) => r['checkOutTime'] == null).length;

//     final metrics = _viewMode == 'today'
//         ? {'Check-ins': checkInsToday, 'Check-outs': checkOutsToday, 'Pending': pendingToday, 'Filtered': filtered.length}
//         : {'Check-ins': checkInsAll, 'Check-outs': checkOutsAll, 'Pending': pendingAll, 'Filtered': filtered.length};

//     return Row(children: [
//       _metricCard('Check-ins', metrics['Check-ins']!.toString(), Icons.login, Colors.greenAccent),
//       const SizedBox(width: 8),
//       _metricCard('Check-outs', metrics['Check-outs']!.toString(), Icons.logout, Colors.redAccent),
//       const SizedBox(width: 8),
//       _metricCard('Pending', metrics['Pending']!.toString(), Icons.pending_actions, Colors.orangeAccent),
//       const SizedBox(width: 8),
//       _metricCard('Filtered', metrics['Filtered']!.toString(), Icons.filter_alt, Colors.blueAccent),
//     ]);
//   }

//   Widget _metricCard(String label, String value, IconData icon, Color color) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(color: const Color(0xFF141417), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white10)),
//         child: Row(children: [
//           Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color)),
//           const SizedBox(width: 12),
//           Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)), const SizedBox(height: 6), Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))]))
//         ]),
//       ),
//     );
//   }

//   // Build map card (fixed builder API)
//   Widget _buildMapCard() {
//     final markers = <Marker>[];
//     final filtered = _activeRecords;

//     for (var r in filtered) {
//       final lat = _tryParseDouble(r['lat'] ?? r['latitude'] ?? r['latLng']?['lat']);
//       final lng = _tryParseDouble(r['lng'] ?? r['longitude'] ?? r['latLng']?['lng']);
//       if (lat == null || lng == null) continue;
//       final point = LatLng(lat, lng);
//       final isPending = r['checkOutTime'] == null;
//       markers.add(Marker(
//         point: point,
//         width: 42,
//         height: 42,
//       child:   GestureDetector(
//           onTap: () => _showRecordDetails(r),
//           child: Icon(isPending ? Icons.location_on : Icons.check_circle, color: isPending ? Colors.orange : Colors.green, size: 34),
//         ),
//       ));
//     }

//     return Card(
//       color: const Color(0xFF101012),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: SizedBox(
//         height: 260,
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: FlutterMap(
//             mapController: _mapController,
//             options: MapOptions(initialCenter: _initialMapCenter, initialZoom: 5, minZoom: 3),
//             children: [
//               TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', subdomains: const ['a', 'b', 'c']),
//               if (markers.isNotEmpty) MarkerLayer(markers: markers),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   void _showRecordDetails(Map<String, dynamic> r) {
//     final name = (r['userName'] ?? '-').toString();
//     final dept = (r['department'] ?? '-').toString();
//     final inTime = _formatShort(r['checkInTime']);
//     final outTime = r['checkOutTime'] != null ? _formatShort(r['checkOutTime']) : 'Pending';
//     final addr = (r['checkInAddress'] ?? '-').toString();
//     final lat = _tryParseDouble(r['lat'] ?? r['latitude'] ?? r['latLng']?['lat']);
//     final lng = _tryParseDouble(r['lng'] ?? r['longitude'] ?? r['latLng']?['lng']);

//     showModalBottomSheet(
//       context: context,
//       backgroundColor: _panel,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
//       builder: (ctx) {
//         return SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
//               Row(children: [Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), Text(dept, style: const TextStyle(color: Colors.white70))]),
//               const SizedBox(height: 8),
//               Text('In: $inTime', style: const TextStyle(color: Colors.white70)),
//               const SizedBox(height: 4),
//               Text('Out: $outTime', style: const TextStyle(color: Colors.white70)),
//               const SizedBox(height: 8),
//               Text('Address: $addr', style: const TextStyle(color: Colors.white70)),
//               const SizedBox(height: 8),
//               if (lat != null && lng != null)
//                 SizedBox(
//                   height: 180,
//                   child: FlutterMap(
//                     options: MapOptions(initialCenter: LatLng(lat, lng), initialZoom: 15),
//                     children: [
//                       TileLayer(urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', subdomains: const ['a', 'b', 'c']),
//                       MarkerLayer(markers: [Marker(point: LatLng(lat, lng), width: 40, height: 40, child:  const Icon(Icons.location_on, color: Colors.red, size: 36))]),
//                     ],
//                   ),
//                 ),
//               const SizedBox(height: 12),
//               Row(children: [
//                 Expanded(child: ElevatedButton.icon(icon: const Icon(Icons.map), label: const Text('Focus map'), onPressed: () {
//                   if (lat != null && lng != null) {
//                     try {
//                       _mapController.move(LatLng(lat, lng), 14);
//                     } catch (_) {}
//                     Navigator.of(ctx).pop();
//                   }
//                 })),
//                 const SizedBox(width: 8),
//                 Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.share), label: const Text('Share'), onPressed: () async {
//                   final txt = '$name\nIn: $inTime\nOut: $outTime\nAddr: $addr${lat != null && lng != null ? '\nLocation: $lat,$lng' : ''}';
//                   await Share.share(txt);
//                 })),
//               ]),
//             ]),
//           ),
//         );
//       },
//     );
//   }

//   Widget _buildPendingAlert() {
//     if (_activePending.isEmpty) return const SizedBox.shrink();
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(color: Colors.orange.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
//       child: Row(children: [
//         const Icon(Icons.warning, color: Colors.orange),
//         const SizedBox(width: 12),
//         Expanded(child: Text('There are ${_activePending.length} pending check-outs. Tap to view.', style: const TextStyle(color: Colors.white70))),
//         ElevatedButton(child: const Text('View'), onPressed: () => _showPendingList()),
//       ]),
//     );
//   }

//   Future<void> _showPendingList() async {
//     final rows = _activePending;
//     await showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: _panel,
//         title: Text('Pending Check-outs (${_viewMode == 'today' ? 'Today' : 'All'})', style: const TextStyle(color: Colors.white)),
//         content: SizedBox(
//           width: double.maxFinite,
//           child: ListView.separated(
//             shrinkWrap: true,
//             itemCount: rows.length,
//             separatorBuilder: (_, __) => const Divider(color: Colors.white12),
//             itemBuilder: (ctx2, i) {
//               final r = rows[i];
//               final user = (r['userName'] ?? '-').toString();
//               final inTime = _formatShort(r['checkInTime']);
//               return ListTile(
//                 tileColor: const Color(0xFF101012),
//                 leading: CircleAvatar(child: Text(user.isNotEmpty ? user[0].toUpperCase() : '?')),
//                 title: Text(user, style: const TextStyle(color: Colors.white)),
//                 subtitle: Text('In: $inTime', style: const TextStyle(color: Colors.white70)),
//                 trailing: ElevatedButton(child: const Text('Details'), onPressed: () => _showRecordDetails(r)),
//               );
//             },
//           ),
//         ),
//         actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close'))],
//       ),
//     );
//   }

//   Widget _buildRecentList() {
//     final filtered = _activeRecords;
//     if (filtered.isEmpty) {
//       return Card(color: const Color(0xFF101012), child: Padding(padding: const EdgeInsets.all(16), child: Text(_viewMode == 'today' ? 'No check-ins found for today' : 'No records found', style: const TextStyle(color: Colors.white70))));
//     }
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Text(_viewMode == 'today' ? 'Today\'s Check-ins' : 'Recent Check-ins', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
//       const SizedBox(height: 8),
//       Column(children: filtered.map((r) {
//         final user = (r['userName'] ?? '-').toString();
//         final dept = (r['department'] ?? '-').toString();
//         final inStr = _formatShort(r['checkInTime']);
//         final outStr = r['checkOutTime'] != null ? _formatShort(r['checkOutTime']) : 'Pending';
//         final pending = r['checkOutTime'] == null;
//         return Padding(padding: const EdgeInsets.only(bottom: 8), child: _ActivityTileSimple(name: user, department: dept, inTime: inStr, outTime: outStr, pending: pending, onTap: () => _showRecordDetails(r), onSummaryTap: () => _showUserSummary(user)));
//       }).toList())
//     ]);
//   }

//   Widget _buildAbsentCard() {
//     final absent = _absentToday();
//     if (absent.isEmpty) return const SizedBox.shrink();
//     return Card(
//       color: const Color(0xFF101012),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//       child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         const Text('Absent Today', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 8),
//         SizedBox(height: 60, child: ListView.separated(scrollDirection: Axis.horizontal, itemBuilder: (_, i) => Chip(label: Text(absent[i]), backgroundColor: const Color(0xFF1A1A1A)), separatorBuilder: (_, __) => const SizedBox(width: 8), itemCount: absent.length))
//       ])),
//     );
//   }

//   Widget _buildMonthlyAnalytics() {
//     final data = _monthlyCounts(6);
//     final labels = data.keys.toList();
//     final values = data.values.toList();
//     final max = values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b);
//     return Card(
//       color: const Color(0xFF101012),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         const Text('Monthly Check-ins (last 6 months)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 12),
//         SizedBox(height: 120, child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
//           for (int i = 0; i < labels.length; i++)
//             Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
//               AnimatedContainer(duration: const Duration(milliseconds: 500), height: (values[i] / (max == 0 ? 1 : max)) * 80 + 8, width: 22, decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(6))),
//               const SizedBox(height: 6),
//               Text(labels[i], style: const TextStyle(color: Colors.white70, fontSize: 10), textAlign: TextAlign.center),
//               const SizedBox(height: 6),
//               Text(values[i].toString(), style: const TextStyle(color: Colors.white70, fontSize: 11)),
//             ]))
//         ]))
//       ])),
//     );
//   }

//   Future<void> _showExportOptions() async {
//     final rows = _activeRecords;
//     await showModalBottomSheet(
//       context: context,
//       backgroundColor: _panel,
//       shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
//       builder: (ctx) {
//         return SafeArea(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(mainAxisSize: MainAxisSize.min, children: [
//               Text('Export ${rows.length} records (${_viewMode == 'today' ? 'today' : 'all'})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
//               const SizedBox(height: 12),
//               Row(children: [
//                 Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: _accent), icon: const Icon(Icons.picture_as_pdf), label: const Text('Export PDF'), onPressed: () {
//                   Navigator.of(ctx).pop();
//                   _exportFilteredPdf();
//                 })),
//                 const SizedBox(width: 8),
//                 Expanded(child: ElevatedButton.icon(style: ElevatedButton.styleFrom(backgroundColor: Colors.green), icon: const Icon(Icons.table_view), label: const Text('Export Excel'), onPressed: () {
//                   Navigator.of(ctx).pop();
//                   _exportFilteredExcel();
//                 })),
//               ]),
//               const SizedBox(height: 8),
//               Row(children: [
//                 Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.share), label: const Text('Share PDF'), onPressed: () {
//                   Navigator.of(ctx).pop();
//                   _shareFilteredPdf();
//                 })),
//                 const SizedBox(width: 8),
//                 Expanded(child: OutlinedButton.icon(icon: const Icon(Icons.share_outlined), label: const Text('Share Excel'), onPressed: () {
//                   Navigator.of(ctx).pop();
//                   _shareFilteredExcel();
//                 })),
//               ]),
//             ]),
//           ),
//         );
//       },
//     );
//   }

//   String _formatShort(dynamic raw) {
//     if (raw == null) return 'N/A';
//     try {
//       final dt = DateTime.parse(raw.toString());
//       return DateFormat('dd MMM, hh:mm a').format(dt);
//     } catch (_) {
//       try {
//         final dt = DateTime.parse(raw.toString().replaceAll('Z', ''));
//         return DateFormat('dd MMM, hh:mm a').format(dt);
//       } catch (_) {
//         return raw.toString();
//       }
//     }
//   }
// }

// // compact activity tile
// class _ActivityTileSimple extends StatelessWidget {
//   final String name;
//   final String department;
//   final String inTime;
//   final String outTime;
//   final bool pending;
//   final VoidCallback? onTap;
//   final VoidCallback? onSummaryTap;

//   const _ActivityTileSimple({required this.name, required this.department, required this.inTime, required this.outTime, this.pending = false, this.onTap, this.onSummaryTap});

//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: const Color(0xFF141416),
//       borderRadius: BorderRadius.circular(10),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(10),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
//           child: Row(children: [
//             CircleAvatar(radius: 24, backgroundColor: Colors.white12, child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white))),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//                 Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Expanded(child: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))), GestureDetector(onTap: onSummaryTap, child: const Icon(Icons.info_outline, color: Colors.white70))]),
//                 const SizedBox(height: 6),
//                 Text(department, style: const TextStyle(color: Colors.white70, fontSize: 12)),
//                 const SizedBox(height: 8),
//                 Row(children: [const Icon(Icons.login, size: 14, color: Colors.greenAccent), const SizedBox(width: 6), Text('In: $inTime', style: const TextStyle(color: Colors.white60)), const SizedBox(width: 12), const Icon(Icons.logout, size: 14, color: Colors.redAccent), const SizedBox(width: 6), Text('Out: $outTime', style: const TextStyle(color: Colors.white60))]),
//               ]),
//             ),
//             const SizedBox(width: 8),
//             Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6), decoration: BoxDecoration(color: pending ? Colors.orange : Colors.green, borderRadius: BorderRadius.circular(8)), child: Text(pending ? 'Pending' : 'Checked', style: const TextStyle(color: Colors.black87))),
//           ]),
//         ),
//       ),
//     );
//   }
// }

// admin_dashboard_screen.dart
import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart' hide Border;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_attendance_application/presentation/widgets/logout_dialog.dart';

/// Admin Dashboard (Today + All toggle) - Updated
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

enum ViewMode { today, all }

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  // loading / state
  bool _isLoading = true;
  bool _isError = false;
  String _errorMessage = '';

  // Raw records from API
  List<Map<String, dynamic>> _records = [];

  // Admin profile
  String name = '';
  String email = '';
  String role = '';

  // Export busy
  bool _isExporting = false;

  // UI theme
  final Color _bg = const Color(0xFF0E0E10);
  final Color _panel = const Color(0xFF151516);
  final Color _accent = const Color(0xFF4A148C);

  // UI filters
  String _searchQuery = '';
  String? _filterUser;
  String? _filterDept;

  // Today-only computed lists
  List<Map<String, dynamic>> _todayRecords = [];
  List<Map<String, dynamic>> _todayPending = [];
  List<Map<String, dynamic>> _todayCheckedOut = [];

  // Helper lists for dropdowns
  List<String> _userList = [];
  List<String> _deptList = [];

  // Map state
  final MapController _mapController = MapController();
  LatLng _initialMapCenter = LatLng(20.5937, 78.9629); // India fallback

  // View mode: today (default) or all
  ViewMode _viewMode = ViewMode.today;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadAdminInfo();
    await _fetchRecords();
  }

  Future<void> _loadAdminInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      setState(() {
        name = prefs.getString('name') ?? 'Admin';
        email = prefs.getString('email') ?? '';
        role = prefs.getString('role') ?? 'Admin';
      });
    } catch (_) {}
  }

  Future<void> _fetchRecords() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _isError = false;
        _errorMessage = '';
      });
    }

    try {
      final uri = Uri.parse(
        'https://trainerattendence-backed.onrender.com/api/attendance/all',
      );
      final res = await http.get(uri).timeout(const Duration(seconds: 20));

      if (res.statusCode != 200) {
        throw Exception('Server returned ${res.statusCode}');
      }

      final List<dynamic> list = jsonDecode(res.body) as List<dynamic>;
      final records = list
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();

      // build helper lists
      final u = records
          .map((r) => (r['userName'] ?? 'Unknown').toString())
          .toSet()
          .toList();
      final d = records
          .map((r) => (r['department'] ?? 'Unknown').toString())
          .toSet()
          .toList();
      u.sort();
      d.sort();

      // apply today filter (local device date)
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final todays = records.where((r) {
        final raw = r['checkInTime'];
        if (raw == null) return false;
        try {
          final dt = DateTime.parse(raw.toString());
          return (dt.isAfter(todayStart) || dt.isAtSameMomentAs(todayStart)) &&
              (dt.isBefore(todayEnd) || dt.isAtSameMomentAs(todayEnd));
        } catch (_) {
          return false;
        }
      }).toList();

      // classify
      final pending = todays.where((r) => r['checkOutTime'] == null).toList();
      final checkedOut = todays
          .where((r) => r['checkOutTime'] != null)
          .toList();

      // set default map center to first today's marker if available
      LatLng? center;
      for (var r in todays) {
        final lat = _tryParseDouble(
          r['lat'] ?? r['latitude'] ?? r['latLng']?['lat'],
        );
        final lng = _tryParseDouble(
          r['lng'] ?? r['longitude'] ?? r['latLng']?['lng'],
        );
        if (lat != null && lng != null) {
          center = LatLng(lat, lng);
          break;
        }
      }

      if (mounted) {
        setState(() {
          _records = records;
          _userList = u;
          _deptList = d;
          _todayRecords = todays;
          _todayPending = pending;
          _todayCheckedOut = checkedOut;
          if (center != null) _initialMapCenter = center;
          _isLoading = false;
        });
      }

      // move map to center once ready
      if (center != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            _mapController.move(center!, 13);
          } catch (_) {}
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isError = true;
          _errorMessage = e.toString();
          _records = [];
          _todayRecords = [];
          _todayPending = [];
          _todayCheckedOut = [];
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load: $e')));
      }
    }
  }

  // ---------- Utilities ----------
  double? _tryParseDouble(dynamic v) {
    if (v == null) return null;
    try {
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString());
    } catch (_) {
      return null;
    }
  }

  DateTime _tryParse(String? raw) {
    if (raw == null) return DateTime.fromMillisecondsSinceEpoch(0);
    try {
      return DateTime.parse(raw);
    } catch (_) {
      try {
        return DateTime.parse(raw.replaceAll('Z', ''));
      } catch (_) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
    }
  }

  Duration _computeDuration(Map<String, dynamic> r) {
    final inRaw = r['checkInTime'];
    final outRaw = r['checkOutTime'];
    if (inRaw == null) return Duration.zero;
    final inDt = _tryParse(inRaw.toString());
    if (outRaw == null) return Duration.zero;
    final outDt = _tryParse(outRaw.toString());
    if (outDt.isBefore(inDt)) return Duration.zero;
    return outDt.difference(inDt);
  }

  // --------- View / Filtering ----------
  /// Returns the list currently shown in the UI depending on view mode and filters.
  List<Map<String, dynamic>> get _displayedRecords {
    final base = (_viewMode == ViewMode.today) ? _todayRecords : _records;
    return _applyUIFiltersToList(base);
  }

  List<Map<String, dynamic>> _applyUIFiltersToList(
    List<Map<String, dynamic>> src,
  ) {
    var list = List<Map<String, dynamic>>.from(src);
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((r) {
        final name = (r['userName'] ?? '').toString().toLowerCase();
        final dept = (r['department'] ?? '').toString().toLowerCase();
        final date = (r['checkInTime'] ?? '').toString().toLowerCase();
        return name.contains(q) || dept.contains(q) || date.contains(q);
      }).toList();
    }
    if (_filterUser != null && _filterUser!.isNotEmpty) {
      list = list
          .where((r) => (r['userName'] ?? '').toString() == _filterUser)
          .toList();
    }
    if (_filterDept != null && _filterDept!.isNotEmpty) {
      list = list
          .where((r) => (r['department'] ?? '').toString() == _filterDept)
          .toList();
    }
    // Sort newest first by check-in time
    list.sort(
      (a, b) => _tryParse(
        b['checkInTime']?.toString(),
      ).compareTo(_tryParse(a['checkInTime']?.toString())),
    );
    return list;
  }

  // ---------- Exports (reuse your earlier logic) ----------
  Future<Directory> _getDownloadDir() async {
    if (Platform.isAndroid) {
      final candidate = Directory('/storage/emulated/0/Download');
      if (await candidate.exists()) return candidate;
      final ext = await getExternalStorageDirectory();
      if (ext != null) return ext;
    }
    return await getApplicationDocumentsDirectory();
  }

  Future<File?> _exportExcel(List<Map<String, dynamic>> rows) async {
    if (rows.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No records to export')));
      }
      return null;
    }

    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    sheet.appendRow([
      TextCellValue('Name'),
      TextCellValue('Dept'),
      TextCellValue('Date'),
      TextCellValue('Check-In'),
      TextCellValue('Check-Out'),
      TextCellValue('Duration'),
      TextCellValue('In Address'),
      TextCellValue('Out Address'),
      TextCellValue('Mode In'),
      TextCellValue('Mode Out'),
      TextCellValue('Lat'),
      TextCellValue('Lng'),
    ]);

    for (var r in rows) {
      final dtIn = _tryParse(r['checkInTime']?.toString());
      final dtOut = r['checkOutTime'] != null
          ? _tryParse(r['checkOutTime'].toString())
          : null;
      final dateStr = dtIn.millisecondsSinceEpoch == 0
          ? '-'
          : DateFormat('dd MMM yyyy').format(dtIn);
      final inStr = dtIn.millisecondsSinceEpoch == 0
          ? '-'
          : DateFormat('hh:mm a').format(dtIn);
      final outStr = (dtOut == null || dtOut.millisecondsSinceEpoch == 0)
          ? '-'
          : DateFormat('hh:mm a').format(dtOut);
      final dur = _computeDuration(r);
      final durStr = dur == Duration.zero
          ? '-'
          : '${dur.inHours}h ${dur.inMinutes.remainder(60)}m';
      final inAddr = (r['checkInAddress'] ?? '-').toString().replaceAll(
        '\n',
        ' ',
      );
      final outAddr = (r['checkOutAddress'] ?? '-').toString().replaceAll(
        '\n',
        ' ',
      );
      final inMode = r['checkInMode'] == true ? 'Online' : 'Offline';
      final outMode = r['checkOutMode'] == true ? 'Online' : 'Offline';
      final lat = r['lat'] ?? r['latitude'] ?? r['latLng']?['lat'] ?? '-';
      final lng = r['lng'] ?? r['longitude'] ?? r['latLng']?['lng'] ?? '-';

      sheet.appendRow([
        TextCellValue(r['userName'] ?? '-'),
        TextCellValue(r['department'] ?? '-'),
        TextCellValue(dateStr),
        TextCellValue(inStr),
        TextCellValue(outStr),
        TextCellValue(durStr),
        TextCellValue(inAddr),
        TextCellValue(outAddr),
        TextCellValue(inMode),
        TextCellValue(outMode),
        TextCellValue(lat.toString()),
        TextCellValue(lng.toString()),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) return null;
    final fileName =
        'attendance_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';
    final dir = await _getDownloadDir();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  Future<File?> _exportPdf(
    List<Map<String, dynamic>> rows, {
    String period = 'Today',
  }) async {
    if (rows.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No records to export')));
      }
      return null;
    }
    final pdf = pw.Document();

    // totals
    Duration total = Duration.zero;
    for (var r in rows) {
      total += _computeDuration(r);
    }

    String formatTotal(Duration d) =>
        "${d.inHours}h ${d.inMinutes.remainder(60)}m";

    final tableHeaders = [
      'Date',
      'In',
      'Out',
      'Duration',
      'In Addr',
      'Out Addr',
      'In Mode',
      'Out Mode',
    ];

    final tableData = rows.map((r) {
      final dtIn = _tryParse(r['checkInTime']?.toString());
      final dtOut = r['checkOutTime'] != null
          ? _tryParse(r['checkOutTime'].toString())
          : null;
      final dateStr = dtIn.millisecondsSinceEpoch == 0
          ? '-'
          : DateFormat('yyyy-MM-dd').format(dtIn);
      final inStr = dtIn.millisecondsSinceEpoch == 0
          ? '-'
          : DateFormat('HH:mm').format(dtIn);
      final outStr = (dtOut == null || dtOut.millisecondsSinceEpoch == 0)
          ? '-'
          : DateFormat('HH:mm').format(dtOut);
      final dur = _computeDuration(r);
      final durStr = dur == Duration.zero
          ? '-'
          : '${dur.inHours}h ${dur.inMinutes.remainder(60)}m';
      final inAddr = (r['checkInAddress'] ?? '-').toString().replaceAll(
        '\n',
        ' ',
      );
      final outAddr = (r['checkOutAddress'] ?? '-').toString().replaceAll(
        '\n',
        ' ',
      );
      return [
        dateStr,
        inStr,
        outStr,
        durStr,
        inAddr,
        outAddr,
        r['checkInMode'] == true ? 'Online' : 'Offline',
        r['checkOutMode'] == true ? 'Online' : 'Offline',
      ];
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
        build: (context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'ATTENDANCE REPORT',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.deepPurple,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    name.isNotEmpty ? name : 'Admin',
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(period, style: const pw.TextStyle(fontSize: 11)),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              color: PdfColors.deepPurple50,
              border: pw.Border.all(color: PdfColors.deepPurple, width: 1),
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Total Records: ${rows.length}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  'Total Hours: ${formatTotal(total)}',
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.deepPurple,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: tableHeaders,
            data: tableData,
            cellAlignment: pw.Alignment.centerLeft,
            headerStyle: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: const pw.TextStyle(fontSize: 8),
            columnWidths: {
              0: pw.FlexColumnWidth(1.2),
              1: pw.FlexColumnWidth(1),
              2: pw.FlexColumnWidth(1),
              3: pw.FlexColumnWidth(1),
              4: pw.FlexColumnWidth(2.5),
              5: pw.FlexColumnWidth(2.5),
              6: pw.FlexColumnWidth(1),
              7: pw.FlexColumnWidth(1),
            },
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();
    final fileName =
        'attendance_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';
    final dir = await _getDownloadDir();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  // ---------- UI Actions ----------
  Future<void> _exportDisplayedExcel() async {
    final rows = _displayedRecords;
    setState(() => _isExporting = true);
    try {
      final f = await _exportExcel(rows);
      if (f != null) {
        await OpenFilex.open(f.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Excel exported: ${f.path.split('/').last}'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Excel export failed: $e')));
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportDisplayedPdf() async {
    final rows = _displayedRecords;
    setState(() => _isExporting = true);
    try {
      final f = await _exportPdf(
        rows,
        period: _viewMode == ViewMode.today ? 'Today' : 'All Records',
      );
      if (f != null) {
        await OpenFilex.open(f.path);
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF exported: ${f.path.split('/').last}')),
          );
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('PDF export failed: $e')));
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _shareDisplayedExcel() async {
    final rows = _displayedRecords;
    setState(() => _isExporting = true);
    try {
      final f = await _exportExcel(rows);
      if (f != null) {
        await Share.shareXFiles([XFile(f.path)], text: 'Attendance (Excel)');
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _shareDisplayedPdf() async {
    final rows = _displayedRecords;
    setState(() => _isExporting = true);
    try {
      final f = await _exportPdf(
        rows,
        period: _viewMode == ViewMode.today ? 'Today' : 'All Records',
      );
      if (f != null) {
        await Share.shareXFiles([XFile(f.path)], text: 'Attendance (PDF)');
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  // Show user summary and focus map
  Future<void> _showUserSummary(String userName) async {
    final rows = (_viewMode == ViewMode.today ? _todayRecords : _records)
        .where((r) => (r['userName'] ?? '') == userName)
        .toList();
    final total = rows.fold<Duration>(
      Duration.zero,
      (p, e) => p + _computeDuration(e),
    );
    final checked = rows.where((r) => r['checkOutTime'] != null).length;
    final pending = rows.where((r) => r['checkOutTime'] == null).length;

    LatLng? center;
    for (var r in rows) {
      final lat = _tryParseDouble(
        r['lat'] ?? r['latitude'] ?? r['latLng']?['lat'],
      );
      final lng = _tryParseDouble(
        r['lng'] ?? r['longitude'] ?? r['latLng']?['lng'],
      );
      if (lat != null && lng != null) {
        center = LatLng(lat, lng);
        break;
      }
    }

    await showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: _panel,
          title: Text(userName, style: const TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Records: ${rows.length}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Checked: $checked',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Pending: $pending',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Total: ${total.inHours}h ${total.inMinutes.remainder(60)}m',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (center != null)
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: FlutterMap(
                    options: MapOptions(initialCenter: center, initialZoom: 15),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: center,
                            width: 48,
                            height: 48,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              else
                Text(
                  'No location available',
                  style: const TextStyle(color: Colors.white54),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );

    if (center != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          _mapController.move(center!, 14);
        } catch (_) {}
      });
    }
  }

  // Absent today
  List<String> _absentToday() {
    final allUsers = _records
        .map((r) => (r['userName'] ?? 'Unknown').toString())
        .toSet();
    final present = _todayRecords
        .map((r) => (r['userName'] ?? 'Unknown').toString())
        .toSet();
    final absent = allUsers.difference(present).toList()..sort();
    return absent;
  }

  // Monthly analytics (last n months)
  Map<String, int> _monthlyCounts(int monthsBack) {
    final now = DateTime.now();
    final out = <String, int>{};
    for (int i = monthsBack - 1; i >= 0; i--) {
      final m = DateTime(now.year, now.month - i, 1);
      final key = DateFormat('MMM yyyy').format(m);
      out[key] = 0;
    }
    for (var r in _records) {
      final dt = _tryParse(r['checkInTime']?.toString());
      if (dt.millisecondsSinceEpoch == 0) continue;
      final key = DateFormat('MMM yyyy').format(DateTime(dt.year, dt.month));
      if (out.containsKey(key)) out[key] = (out[key]! + 1);
    }
    return out;
  }

  // ---------- Build UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_accent, _accent.withOpacity(0.85)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchRecords),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => _showExportOptionsQuick(),
          ),
        ],
      ),
      drawer: _buildDrawer(),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : _isError
            ? _errorView()
            : RefreshIndicator(
                onRefresh: _fetchRecords,
                color: _accent,
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 12),
                    _buildTopFilters(),
                    const SizedBox(height: 12),
                    _buildViewToggle(),
                    const SizedBox(height: 12),
                    _buildMetricsRow(),
                    const SizedBox(height: 12),
                    _buildMapCard(),
                    const SizedBox(height: 12),
                    _buildPendingAlert(),
                    const SizedBox(height: 12),
                    _buildRecentList(),
                    const SizedBox(height: 12),
                    _buildAbsentCard(),
                    const SizedBox(height: 12),
                    _buildMonthlyAnalytics(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
      floatingActionButton: _isExporting
          ? FloatingActionButton(
              onPressed: () {},
              child: const CircularProgressIndicator(color: Colors.white),
              backgroundColor: Colors.grey,
            )
          : null,
    );
  }

  Widget _errorView() {
    return ListView(
      children: [
        const SizedBox(height: 60),
        Center(
          child: Text(
            'Error loading dashboard\n$_errorMessage',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }

  Drawer _buildDrawer() {
    final appGrad = LinearGradient(
      colors: [_accent, _accent.withOpacity(0.85)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Drawer(
      child: Container(
        decoration: BoxDecoration(gradient: appGrad),
        child: Column(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.transparent),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: Color(0xFF6A11CB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          role,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Colors.white),
              title: const Text(
                'User List',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => Navigator.pushNamed(context, '/adminList'),
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Colors.white),
              title: const Text(
                'Attendance History',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () =>
                  Navigator.pushNamed(context, '/adminAttendanceHistory'),
            ),
            const Spacer(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.white),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () => LogoutDialog.show(context),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [_accent, _accent.withOpacity(0.85)]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 34,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.admin_panel_settings,
              color: Color(0xFF6A11CB),
              size: 34,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back,',
                  style: TextStyle(color: Colors.white.withOpacity(0.85)),
                ),
                const SizedBox(height: 6),
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
                  '$role • $email',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            color: _panel,
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (s) {
              if (s == 'export_pdf') _exportDisplayedPdf();
              if (s == 'export_xlsx') _exportDisplayedExcel();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'export_pdf',
                child: Text(
                  'Export (PDF)',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const PopupMenuItem(
                value: 'export_xlsx',
                child: Text(
                  'Export (Excel)',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopFilters() {
    final textStyle = const TextStyle(color: Colors.white);
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                style: textStyle,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, color: Colors.white70),
                  hintText: 'Search name / dept / date',
                  hintStyle: const TextStyle(color: Colors.white60),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => setState(() => _searchQuery = v),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String?>(
                value: _filterUser,
                isExpanded: true,
                dropdownColor: _panel,
                decoration: InputDecoration(
                  fillColor: const Color(0xFF1A1A1A),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: textStyle,
                iconEnabledColor: Colors.white70,
                items: <DropdownMenuItem<String?>>[
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All users'),
                  ),
                  ..._userList.map(
                    (u) => DropdownMenuItem<String?>(value: u, child: Text(u)),
                  ),
                ],
                onChanged: (v) => setState(() => _filterUser = v),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String?>(
                value: _filterDept,
                isExpanded: true,
                dropdownColor: _panel,
                decoration: InputDecoration(
                  fillColor: const Color(0xFF1A1A1A),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: textStyle,
                iconEnabledColor: Colors.white70,
                items: <DropdownMenuItem<String?>>[
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All depts'),
                  ),
                  ..._deptList.map(
                    (d) => DropdownMenuItem<String?>(value: d, child: Text(d)),
                  ),
                ],
                onChanged: (v) => setState(() => _filterDept = v),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: _accent),
              icon: const Icon(Icons.filter_list),
              label: const Text('Apply'),
              onPressed: () => setState(() {}),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildViewToggle() {
    return Row(
      children: [
        const Text('View:', style: TextStyle(color: Colors.white70)),
        const SizedBox(width: 8),
        ToggleButtons(
          isSelected: [_viewMode == ViewMode.today, _viewMode == ViewMode.all],
          borderRadius: BorderRadius.circular(8),
          color: Colors.white70,
          selectedColor: Colors.white,
          fillColor: _accent,
          constraints: const BoxConstraints(minHeight: 36, minWidth: 80),
          onPressed: (i) {
            setState(() {
              _viewMode = (i == 0) ? ViewMode.today : ViewMode.all;
            });
          },
          children: const [Text('Today'), Text('All')],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _viewMode == ViewMode.today
                ? 'Showing today\'s records'
                : 'Showing all records',
            style: const TextStyle(color: Colors.white54),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsRow() {
    final displayed = _displayedRecords;
    final checkInsToday = _todayRecords.length;
    final checkOutsToday = _todayCheckedOut.length;
    final pendingToday = _todayPending.length;

    final totalUsers = _records
        .map((r) => (r['userName'] ?? 'Unknown').toString())
        .toSet()
        .length;
    final totalCheckIns = _records
        .where((r) => r['checkInTime'] != null)
        .length;
    final totalPending = _records
        .where((r) => r['checkOutTime'] == null)
        .length;

    return Row(
      children: [
        _metricCard(
          _viewMode == ViewMode.today ? 'Today Check-ins' : 'Total Check-ins',
          _viewMode == ViewMode.today
              ? checkInsToday.toString()
              : totalCheckIns.toString(),
          Icons.login,
          Colors.greenAccent,
        ),
        const SizedBox(width: 8),
        _metricCard(
          _viewMode == ViewMode.today ? 'Today Check-outs' : 'Total Users',
          _viewMode == ViewMode.today
              ? checkOutsToday.toString()
              : totalUsers.toString(),
          Icons.logout,
          Colors.redAccent,
        ),
        const SizedBox(width: 8),
        _metricCard(
          _viewMode == ViewMode.today ? 'Pending Check-outs' : 'Pending',
          _viewMode == ViewMode.today
              ? pendingToday.toString()
              : totalPending.toString(),
          Icons.pending_actions,
          Colors.orangeAccent,
        ),
        const SizedBox(width: 8),
        _metricCard(
          'Filtered',
          displayed.length.toString(),
          Icons.filter_alt,
          Colors.blueAccent,
        ),
      ],
    );
  }

  Widget _metricCard(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF141417),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapCard() {
    final markers = <Marker>[];
    final filtered = _displayedRecords;

    for (var r in filtered) {
      final lat = _tryParseDouble(
        r['lat'] ?? r['latitude'] ?? r['latLng']?['lat'],
      );
      final lng = _tryParseDouble(
        r['lng'] ?? r['longitude'] ?? r['latLng']?['lng'],
      );
      if (lat == null || lng == null) continue;
      final point = LatLng(lat, lng);
      final isPending = r['checkOutTime'] == null;
      markers.add(
        Marker(
          point: point,
          width: 42,
          height: 42,
          child: GestureDetector(
            onTap: () => _showRecordDetails(r),
            child: Icon(
              isPending ? Icons.location_on : Icons.check_circle,
              color: isPending ? Colors.orange : Colors.green,
              size: 34,
            ),
          ),
        ),
      );
    }

    // If no markers for selected mode, show fallback center with info
    final showMap = true; // keep true; tile layer will render

    return Card(
      color: const Color(0xFF101012),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SizedBox(
        height: 240,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialMapCenter,
              initialZoom: 5,
              minZoom: 3,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                // userAgentPackageName: kIsWeb ? null : 'com.example.app',
              ),
              if (markers.isNotEmpty) MarkerLayer(markers: markers),
              if (markers.isEmpty)
                // small overlay to inform there are no markers in current view
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _initialMapCenter,
                      width: 0,
                      height: 0,
                      child: const SizedBox.shrink(),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecordDetails(Map<String, dynamic> r) {
    final nameStr = (r['userName'] ?? '-').toString();
    final dept = (r['department'] ?? '-').toString();
    final inTime = _formatShort(r['checkInTime']);
    final outTime = r['checkOutTime'] != null
        ? _formatShort(r['checkOutTime'])
        : 'Pending';
    final addr = (r['checkInAddress'] ?? '-').toString();
    final lat = _tryParseDouble(
      r['lat'] ?? r['latitude'] ?? r['latLng']?['lat'],
    );
    final lng = _tryParseDouble(
      r['lng'] ?? r['longitude'] ?? r['latLng']?['lng'],
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        nameStr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(dept, style: const TextStyle(color: Colors.white70)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'In: $inTime',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 4),
                Text(
                  'Out: $outTime',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  'Address: $addr',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                if (lat != null && lng != null)
                  SizedBox(
                    height: 180,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(lat, lng),
                        initialZoom: 15,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(lat, lng),
                              width: 40,
                              height: 40,
                              child: Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 36,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.map),
                        label: const Text('Focus map'),
                        onPressed: () {
                          if (lat != null && lng != null) {
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              _mapController.move(LatLng(lat, lng), 14);
                            });
                            Navigator.of(ctx).pop();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                        onPressed: () async {
                          final txt =
                              '$nameStr\nIn: $inTime\nOut: $outTime\nAddr: $addr${lat != null && lng != null ? '\nLocation: $lat,$lng' : ''}';
                          await Share.share(txt);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPendingAlert() {
    // pending should reflect according to view - for "today" we show today's pending; for "all" show count in all records
    final pendingCount = (_viewMode == ViewMode.today)
        ? _todayPending.length
        : _records.where((r) => r['checkOutTime'] == null).length;
    if (pendingCount == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'There are $pendingCount pending check-outs. Tap to view.',
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          ElevatedButton(
            child: const Text('View'),
            onPressed: () => _showPendingList(),
          ),
        ],
      ),
    );
  }

  Future<void> _showPendingList() async {
    final rowsSource = (_viewMode == ViewMode.today)
        ? _todayPending
        : _records.where((r) => r['checkOutTime'] == null).toList();
    final rows = _applyUIFiltersToList(rowsSource);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: _panel,
        title: const Text(
          'Pending Check-outs',
          style: TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: rows.length,
            separatorBuilder: (_, __) => const Divider(color: Colors.white12),
            itemBuilder: (ctx2, i) {
              final r = rows[i];
              final user = (r['userName'] ?? '-').toString();
              final inTime = _formatShort(r['checkInTime']);
              return ListTile(
                tileColor: const Color(0xFF101012),
                leading: CircleAvatar(
                  child: Text(user.isNotEmpty ? user[0].toUpperCase() : '?'),
                ),
                title: Text(user, style: const TextStyle(color: Colors.white)),
                subtitle: Text(
                  'In: $inTime',
                  style: const TextStyle(color: Colors.white70),
                ),
                trailing: ElevatedButton(
                  child: const Text('Details'),
                  onPressed: () => _showRecordDetails(r),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentList() {
    final filtered = _displayedRecords;
    if (filtered.isEmpty) {
      return Card(
        color: const Color(0xFF101012),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _viewMode == ViewMode.today
                ? 'No check-ins found for today'
                : 'No records found',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _viewMode == ViewMode.today ? 'Today\'s Check-ins' : 'Recent Records',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Column(
          children: filtered.map((r) {
            final user = (r['userName'] ?? '-').toString();
            final dept = (r['department'] ?? '-').toString();
            final inStr = _formatShort(r['checkInTime']);
            final outStr = r['checkOutTime'] != null
                ? _formatShort(r['checkOutTime'])
                : 'Pending';
            final pending = r['checkOutTime'] == null;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _ActivityTileSimple(
                name: user,
                department: dept,
                inTime: inStr,
                outTime: outStr,
                pending: pending,
                onTap: () => _showRecordDetails(r),
                onSummaryTap: () => _showUserSummary(user),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildAbsentCard() {
    final absent = _absentToday();
    if (absent.isEmpty) return const SizedBox.shrink();
    return Card(
      color: const Color(0xFF101012),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Absent Today',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemBuilder: (_, i) => Chip(
                  label: Text(absent[i]),
                  backgroundColor: const Color(0xFF1A1A1A),
                ),
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemCount: absent.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlyAnalytics() {
    final data = _monthlyCounts(6);
    final labels = data.keys.toList();
    final values = data.values.toList();
    final max = values.isEmpty ? 1 : values.reduce((a, b) => a > b ? a : b);

    // If there's a risk of overflow, allow horizontal scroll for many months
    return Card(
      color: const Color(0xFF101012),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Check-ins (last 6 months)',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          for (int i = 0; i < labels.length; i++)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 500),
                                    height:
                                        (values[i] / (max == 0 ? 1 : max)) *
                                            80 +
                                        8,
                                    width: 22,
                                    decoration: BoxDecoration(
                                      color: _accent,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      labels[i],
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 10,
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    values[i].toString(),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showExportOptionsQuick() async {
    final rows = _displayedRecords;
    await showModalBottomSheet(
      context: context,
      backgroundColor: _panel,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Export ${rows.length} records (${_viewMode == ViewMode.today ? 'Today' : 'All'})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                        ),
                        icon: const Icon(Icons.picture_as_pdf),
                        label: const Text('Export PDF'),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _exportDisplayedPdf();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        icon: const Icon(Icons.table_view),
                        label: const Text('Export Excel'),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _exportDisplayedExcel();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.share),
                        label: const Text('Share PDF'),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _shareDisplayedPdf();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Share Excel'),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          _shareDisplayedExcel();
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatShort(dynamic raw) {
    if (raw == null) return 'N/A';
    try {
      final dt = DateTime.parse(raw.toString());
      return DateFormat('dd MMM, hh:mm a').format(dt);
    } catch (_) {
      return raw.toString();
    }
  }
}

/// small activity tile used in recent list (compact)
class _ActivityTileSimple extends StatelessWidget {
  final String name;
  final String department;
  final String inTime;
  final String outTime;
  final bool pending;
  final VoidCallback? onTap;
  final VoidCallback? onSummaryTap;

  const _ActivityTileSimple({
    required this.name,
    required this.department,
    required this.inTime,
    required this.outTime,
    this.pending = false,
    this.onTap,
    this.onSummaryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF141416),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.white12,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: onSummaryTap,
                          child: const Icon(
                            Icons.info_outline,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      department,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.login,
                          size: 14,
                          color: Colors.greenAccent,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'In: $inTime',
                            style: const TextStyle(color: Colors.white60),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.logout,
                          size: 14,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Out: $outTime',
                            style: const TextStyle(color: Colors.white60),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: pending ? Colors.orange : Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pending ? 'Pending' : 'Checked',
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
