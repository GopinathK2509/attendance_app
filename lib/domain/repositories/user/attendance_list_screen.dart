
import 'package:flutter/material.dart';
import 'package:mobile_attendance_application/data/models/attendance_model.dart';
import 'package:mobile_attendance_application/data/models/user_model.dart';
import 'package:mobile_attendance_application/data/repositories/attendance_repository_impl.dart';

class AttendanceListScreen extends StatefulWidget {
  final UserModel user;
  final AttendanceRepositoryImpl repository;

  const AttendanceListScreen({
    super.key,
    required this.user,
    required this.repository,
  });

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  late Future<List<AttendanceModel>> _attendanceFuture;

  @override
  void initState() {
    super.initState();
    _attendanceFuture = widget.repository.getUserAttendance(widget.user.id);
  }

  String formatDate(DateTime dateTime) {
    return "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} "
        "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  String formatDuration(Duration d) {
    return "${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance History')),
      body: FutureBuilder<List<AttendanceModel>>(
        future: _attendanceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final records = snapshot.data ?? [];

          if (records.isEmpty) {
            return const Center(child: Text('No attendance records found.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final attendance = records[index];
              bool checkedOut = attendance.checkOutTime != null;

              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            checkedOut ? Icons.check_circle : Icons.access_time,
                            color: checkedOut ? Colors.green : Colors.orange,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Check-In: ${formatDate(attendance.checkInTime)}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (checkedOut)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Check-Out: ${formatDate(attendance.checkOutTime!)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Duration: ${formatDuration(attendance.duration)}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        )
                      else
                        const Text(
                          'Not checked out yet',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      const SizedBox(height: 8),
                      if (attendance.latitude != null &&
                          attendance.longitude != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.blueAccent,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Lat: ${attendance.latitude}, Lon: ${attendance.longitude}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      if (attendance.address != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.map,
                              size: 16,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                attendance.address!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.black87,
                                ),
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
        },
      ),
    );
  }
}
