
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_attendance_application/data/models/attendance_model.dart';
import 'package:mobile_attendance_application/data/models/user_model.dart';

class AttendanceListScreen extends StatefulWidget {
  final UserModel user;

  const AttendanceListScreen({super.key, required this.user});

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  late Future<List<AttendanceModel>> _attendanceFuture;

  @override
  void initState() {
    super.initState();
    _attendanceFuture = fetchAttendance();
  }

  Future<List<AttendanceModel>> fetchAttendance() async {
    final url = Uri.parse(
      "https://trainerattendence-backed.onrender.com/api/attendance/user/${widget.user.userId}",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => AttendanceModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load attendance data');
    }
  }

  String formatDate(DateTime dateTime) =>
      "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} "
      "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";

  String formatDuration(Duration d) => "${d.inHours}h ${d.inMinutes % 60}m";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<AttendanceModel>>(
        future: _attendanceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.deepPurple),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final records = snapshot.data ?? [];
          if (records.isEmpty) {
            return const Center(child: Text('No attendance records found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final attendance = records[index];
              final checkedOut = attendance.checkOutTime != null;

              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: checkedOut
                          ? [
                              Colors.deepPurple.shade50,
                              Colors.deepPurple.shade100,
                            ]
                          : [Colors.purple.shade50, Colors.purple.shade100],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: User + Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.user.name ?? 'User',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: checkedOut
                                  ? Colors.deepPurple
                                  : Colors.purple,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              checkedOut ? 'Checked Out' : 'Checked In',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.deepPurple, height: 24),

                      // Check-In Section
                      const Text(
                        "Check-In",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      InfoRow(
                        icon: Icons.login,
                        color: Colors.deepPurple,
                        label: "Time",
                        value: formatDate(attendance.checkInTime),
                      ),
                      if (attendance.checkInLatitude != null &&
                          attendance.checkInLongitude != null)
                        InfoRow(
                          icon: Icons.my_location,
                          color: Colors.deepPurple,
                          label: "Coordinates",
                          value:
                              "${attendance.checkInLatitude}, ${attendance.checkInLongitude}",
                        ),
                      if (attendance.checkInAddress != null)
                        InfoRow(
                          icon: Icons.location_on,
                          color: Colors.deepPurpleAccent,
                          label: "Address",
                          value: attendance.checkInAddress!,
                        ),
                      InfoRow(
                        icon: Icons.settings,
                        color: Colors.deepPurple,
                        label: "Mode",
                        value: attendance.checkInMode == true
                            ? "Online"
                            : "Offline",
                      ),
                      const SizedBox(height: 12),

                      // Check-Out Section
                      const Text(
                        "Check-Out",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepPurple,
                        ),
                      ),
                      const SizedBox(height: 8),
                      checkedOut
                          ? Column(
                              children: [
                                InfoRow(
                                  icon: Icons.logout,
                                  color: Colors.deepPurple,
                                  label: "Time",
                                  value: formatDate(attendance.checkOutTime!),
                                ),
                                InfoRow(
                                  icon: Icons.timer,
                                  color: Colors.deepPurpleAccent,
                                  label: "Duration",
                                  value: formatDuration(attendance.duration),
                                ),
                                if (attendance.checkOutLatitude != null &&
                                    attendance.checkOutLongitude != null)
                                  InfoRow(
                                    icon: Icons.my_location,
                                    color: Colors.deepPurple,
                                    label: "Coordinates",
                                    value:
                                        "${attendance.checkOutLatitude}, ${attendance.checkOutLongitude}",
                                  ),
                                if (attendance.checkOutAddress != null)
                                  InfoRow(
                                    icon: Icons.location_on,
                                    color: Colors.deepPurpleAccent,
                                    label: "Address",
                                    value: attendance.checkOutAddress!,
                                  ),
                                InfoRow(
                                  icon: Icons.settings,
                                  color: Colors.deepPurple,
                                  label: "Mode",
                                  value: attendance.checkOutMode == true
                                      ? "Online"
                                      : "Offline",
                                ),
                              ],
                            )
                          : const Text(
                              "Not checked out yet",
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Helper widget for consistent info rows
class InfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  const InfoRow({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w500)),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
