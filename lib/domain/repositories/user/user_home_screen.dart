

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile_attendance_application/data/models/attendance_model.dart';
import 'package:mobile_attendance_application/data/models/user_model.dart';
import 'package:mobile_attendance_application/data/repositories/attendance_repository_impl.dart';
import 'package:mobile_attendance_application/presentation/auth/role_selection_screen.dart';
import 'attendance_list_screen.dart';
import 'package:geocoding/geocoding.dart' hide Location;

class UserHomeScreen extends StatefulWidget {
  final UserModel user;
  final AttendanceRepositoryImpl repository;

  const UserHomeScreen({
    super.key,
    required this.user,
    required this.repository,
  });

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  AttendanceModel? todayAttendance;
  Timer? _timer;
  Duration runningDuration = Duration.zero;

  String? latitude;
  String? longitude;
  String? address;

  @override
  void initState() {
    super.initState();
    loadTodayAttendance();
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<void> _getAddress(Position pos) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        setState(() {
          latitude = pos.latitude.toStringAsFixed(6);
          longitude = pos.longitude.toStringAsFixed(6);
          address =
              '${p.name}, ${p.subLocality}, ${p.locality}, ${p.postalCode}, ${p.country}';
        });
      }
    } catch (_) {
      setState(() => address = 'Could not fetch address');
    }
  }

  void loadTodayAttendance() async {
    final records = await widget.repository.getUserAttendance(widget.user.id);
    final today = DateTime.now();

    try {
      todayAttendance = records.firstWhere(
        (a) =>
            a.checkInTime.year == today.year &&
            a.checkInTime.month == today.month &&
            a.checkInTime.day == today.day,
      );
      latitude = todayAttendance?.latitude?.toStringAsFixed(6);
      longitude = todayAttendance?.longitude?.toStringAsFixed(6);
      address = todayAttendance?.address;
    } catch (_) {
      todayAttendance = null;
    }

    if (todayAttendance != null && todayAttendance!.checkOutTime == null)
      startTimer();
    setState(() {});
  }

  Future<void> checkIn() async {
    try {
      Position pos = await _determinePosition();
      await _getAddress(pos);
      final location = Location(
        latitude: pos.latitude,
        longitude: pos.longitude,
        address: address,
      );
      final attendance = await widget.repository.checkIn(location);

      setState(() {
        todayAttendance = attendance;
        runningDuration = Duration.zero;
      });

      startTimer();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> checkOut() async {
    if (todayAttendance == null) return;

    Position pos = await _determinePosition();
    await _getAddress(pos);
    final location = Location(
      latitude: pos.latitude,
      longitude: pos.longitude,
      address: address,
    );
    final updated = await widget.repository.checkOut(location);

    _timer?.cancel();
    setState(() {
      todayAttendance = updated;
    });
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (todayAttendance != null && todayAttendance!.checkOutTime == null) {
        setState(() {
          runningDuration = DateTime.now().difference(
            todayAttendance!.checkInTime,
          );
        });
      }
    });
  }

  String formatDuration(Duration d) =>
      "${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Widget buildAttendanceCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (todayAttendance != null)
              Text(
                'Checked in at: ${todayAttendance!.checkInTime}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            if (todayAttendance?.checkOutTime != null)
              Text(
                'Checked out at: ${todayAttendance!.checkOutTime}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            if (todayAttendance?.checkOutTime != null)
              Text('Duration: ${formatDuration(todayAttendance!.duration)}'),
            const SizedBox(height: 8),
            if (todayAttendance?.latitude != null &&
                todayAttendance?.longitude != null)
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'Lat: ${todayAttendance!.latitude}, Lon: ${todayAttendance!.longitude}',
                    ),
                  ),
                ],
              ),
            if (todayAttendance?.address != null)
              Row(
                children: [
                  const Icon(Icons.map, size: 18, color: Colors.green),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text('Address : ${todayAttendance!.address}'),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            todayAttendance == null
                ? ElevatedButton.icon(
                    onPressed: checkIn,
                    icon: const Icon(Icons.login),
                    label: const Text('Check In'),
                  )
                : todayAttendance!.checkOutTime == null
                ? ElevatedButton.icon(
                    onPressed: checkOut,
                    icon: const Icon(Icons.logout),
                    label: const Text('Check Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${widget.user.name}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await widget.repository.localStorage.clearCurrentUser();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => RoleSelectionScreen(
                    storage: widget.repository.localStorage,
                  ),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildAttendanceCard(),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AttendanceListScreen(
                      user: widget.user,
                      repository: widget.repository,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.history),
              label: const Text('View Attendance History'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }
}
