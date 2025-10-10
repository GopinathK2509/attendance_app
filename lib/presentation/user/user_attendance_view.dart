import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:mobile_attendance_application/data/models/attendance_model.dart';
import 'package:mobile_attendance_application/data/models/user_model.dart';
import 'package:mobile_attendance_application/data/repositories/attendance_repository_impl.dart';
import 'package:mobile_attendance_application/domain/repositories/user/attendance_list_screen.dart';

class UserAttendanceView extends StatefulWidget {
  final UserModel user;
  final AttendanceRepositoryImpl repository;

  const UserAttendanceView({
    super.key,
    required this.user,
    required this.repository,
  });

  @override
  State<UserAttendanceView> createState() => _UserAttendanceViewState();
}

class _UserAttendanceViewState extends State<UserAttendanceView> {
  AttendanceModel? todayAttendance;
  Timer? _timer;
  Duration runningDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    loadTodayAttendance();
  }

  Future<void> loadTodayAttendance() async {
    final records = await widget.repository.getUserAttendance(widget.user.id);
    final today = DateTime.now();

    try {
      todayAttendance = records.firstWhere(
        (a) =>
            a.checkInTime.year == today.year &&
            a.checkInTime.month == today.month &&
            a.checkInTime.day == today.day,
      );
    } catch (_) {
      todayAttendance = null;
    }

    if (todayAttendance != null && todayAttendance!.checkOutTime == null) {
      startTimer();
    }

    setState(() {});
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled')),
      );
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Location permissions are permanently denied, enable from settings',
          ),
        ),
      );
      return false;
    }

    return true;
  }

  Future<Location> _getLocationWithAddress() async {
    Position pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    String? address;

    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        address =
            '${p.name}, ${p.subLocality}, ${p.locality}, ${p.postalCode}, ${p.country}';
      }
    } catch (_) {
      address = 'Could not fetch address';
    }

    return Location(
      latitude: pos.latitude,
      longitude: pos.longitude,
      address: address,
    );
  }

  Future<void> checkIn() async {
    if (!await _handleLocationPermission()) return;

    final location = await _getLocationWithAddress();
    final attendance = await widget.repository.checkIn(location);

    setState(() {
      todayAttendance = attendance;
      runningDuration = Duration.zero;
    });

    startTimer();
  }

  Future<void> checkOut() async {
    if (todayAttendance == null) return;
    if (!await _handleLocationPermission()) return;

    final location = await _getLocationWithAddress();
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (todayAttendance != null) ...[
            if (todayAttendance!.latitude != null &&
                todayAttendance!.longitude != null)
              Text(
                'Latitude: ${todayAttendance!.latitude}, Longitude: ${todayAttendance!.longitude}',
              ),
            if (todayAttendance!.address != null)
              Text('Address: ${todayAttendance!.address}'),
            const SizedBox(height: 16),
          ],
          if (todayAttendance == null)
            ElevatedButton(onPressed: checkIn, child: const Text('Check In'))
          else if (todayAttendance!.checkOutTime == null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Checked in at: ${todayAttendance!.checkInTime}'),
                const SizedBox(height: 8),
                Text('Running: ${formatDuration(runningDuration)}'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: checkOut,
                  child: const Text('Check Out'),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Checked in at: ${todayAttendance!.checkInTime}'),
                Text('Checked out at: ${todayAttendance!.checkOutTime}'),
                Text('Duration: ${formatDuration(todayAttendance!.duration)}'),
              ],
            ),
          const SizedBox(height: 20),
          ElevatedButton(
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
            child: const Text('View Attendance History'),
          ),
        ],
      ),
    );
  }
}
