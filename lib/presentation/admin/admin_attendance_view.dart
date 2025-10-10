
import 'package:flutter/material.dart';
import 'package:mobile_attendance_application/data/models/attendance_model.dart';
import 'package:mobile_attendance_application/data/repositories/attendance_repository_impl.dart';

class AdminAttendanceView extends StatefulWidget {
  final AttendanceRepositoryImpl repository;

  const AdminAttendanceView({super.key, required this.repository});

  @override
  State<AdminAttendanceView> createState() => _AdminAttendanceViewState();
}

class _AdminAttendanceViewState extends State<AdminAttendanceView> {
  List<AttendanceModel> allRecords = [];

  @override
  void initState() {
    super.initState();
    loadAllAttendance();
  }

  Future<void> loadAllAttendance() async {
    final records = await widget.repository.getAllAttendance();
    setState(() {
      allRecords = records;
    });
  }

  Color getDurationColor(Duration d) {
    if (d.inHours >= 8) return Colors.green;
    if (d.inHours >= 4) return Colors.orange;
    return Colors.red;
  }

  String formatDuration(Duration d) =>
      "${d.inHours.toString().padLeft(2, '0')}h ${(d.inMinutes % 60).toString().padLeft(2, '0')}m";

  String formatDate(DateTime dt) =>
      "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
      "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Attendance Records')),
      body: allRecords.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: allRecords.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, index) {
                final a = allRecords[index];
                final durationColor = getDurationColor(a.duration);
                final checkedOut = a.checkOutTime != null;

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
                              checkedOut
                                  ? Icons.check_circle
                                  : Icons.access_time,
                              color: checkedOut ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              a.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check-In: ${formatDate(a.checkInTime)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Check-Out: ${a.checkOutTime != null ? formatDate(a.checkOutTime!) : '---'}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text(
                              'Duration: ',
                              style: TextStyle(fontSize: 14),
                            ),
                            Text(
                              formatDuration(a.duration),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: durationColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (a.latitude != null && a.longitude != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 16,
                                color: Colors.blueAccent,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Lat: ${a.latitude}, Lon: ${a.longitude}',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        if (a.address != null)
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
                                  a.address!,
                                  style: const TextStyle(fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
