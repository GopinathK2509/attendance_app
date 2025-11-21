

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_attendance_application/presentation/widgets/logout_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  bool _isLoading = true;
  int totalUsers = 0;
  int totalCheckIns = 0;
  int pendingCheckOuts = 0;
  List recentActivities = [];

  String name = '';
  String email = '';
  String department = '';
  String role = '';
  String userId = '';

  @override
  void initState() {
    super.initState();
    _loadAdminInfo();
    _fetchDashboardData();
  }

  Future<void> _loadAdminInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '';
      email = prefs.getString('email') ?? '';
      department = prefs.getString('department') ?? '';
      role = prefs.getString('role') ?? '';
      userId = prefs.getString('userId') ?? '';
    });
  }

  Future<void> _fetchDashboardData() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://trainerattendence-backed.onrender.com/api/attendance/all",
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> attendanceList = jsonDecode(response.body);

        setState(() {
          totalUsers = attendanceList.map((e) => e['userId']).toSet().length;
          totalCheckIns = attendanceList
              .where((e) => e['checkInTime'] != null)
              .length;
          pendingCheckOuts = attendanceList
              .where((e) => e['checkOutTime'] == null)
              .length;
          recentActivities = attendanceList.reversed.take(6).toList();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("❌ Error fetching dashboard data: $e");
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load dashboard data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E2C),
      appBar: AppBar(
        title: const Text("Admin Dashboard"),
        backgroundColor: const Color(0xFF6A11CB),
        centerTitle: true,
      ),
      drawer: _buildDrawer(context),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAdminHeader(),
                  const SizedBox(height: 20),
                  _buildSummaryCards(),
                  const SizedBox(height: 25),
                  const Text(
                    "Recent Activities",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _buildRecentActivityList(),
                ],
              ),
            ),
    );
  }

  Widget _buildAdminHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundColor: Colors.white,
            child: Icon(
              Icons.admin_panel_settings,
              size: 40,
              color: Color(0xFF6A11CB),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Welcome, $name\n($role)",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      mainAxisSpacing: 15,
      crossAxisSpacing: 15,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _summaryCard(
          Icons.people,
          "Total Users",
          totalUsers.toString(),
          Colors.blue,
        ),
        _summaryCard(
          Icons.login,
          "Total Check-ins",
          totalCheckIns.toString(),
          Colors.green,
        ),
        _summaryCard(
          Icons.pending_actions,
          "Pending Check-outs",
          pendingCheckOuts.toString(),
          Colors.orange,
        ),
        _summaryCard(
          Icons.calendar_month,
          "Records",
          (totalCheckIns + pendingCheckOuts).toString(),
          Colors.purple,
        ),
      ],
    );
  }

  Widget _summaryCard(IconData icon, String title, String value, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C3E),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 35),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(title, style: TextStyle(color: Colors.grey[300], fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList() {
    if (recentActivities.isEmpty) {
      return const Center(
        child: Text(
          "No recent activity found.",
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentActivities.length,
      itemBuilder: (context, index) {
        final activity = recentActivities[index];
        return Card(
          color: const Color(0xFF2C2C3E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: const Icon(Icons.access_time, color: Colors.white),
            title: Text(
              activity['userName'] ?? 'Unknown User',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              "Check-in: ${activity['checkInTime'] ?? 'N/A'}\n"
              "Check-out: ${activity['checkOutTime'] ?? 'N/A'}",
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFF2C2C3E),
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.transparent),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: Color(0xFF6A11CB),
                    size: 35,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.people, color: Colors.white),
            title: const Text(
              "User List",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/adminList');
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.white),
            title: const Text(
              "Attendance History",
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/adminAttendanceHistory');
            },
          ),
          const Spacer(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.white),
            title: const Text("Logout", style: TextStyle(color: Colors.white)),
            onTap: () {
              LogoutDialog.show(context);
            },
          ),
        ],
      ),
    );
  }

}
