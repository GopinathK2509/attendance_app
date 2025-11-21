import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:http/http.dart' as http;
import 'package:mobile_attendance_application/data/models/attendance_model.dart';
import 'package:mobile_attendance_application/data/models/user_model.dart';
import 'package:mobile_attendance_application/presentation/widgets/logout_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'attendance_list_screen.dart';

class UserHomeScreen extends StatefulWidget {
  final UserModel user;

  const UserHomeScreen({super.key, required this.user});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  AttendanceModel? todayAttendance;

  late UserModel currentUser;

  String? latitude;
  String? longitude;
  String? address;
  bool mode = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await initializeUser();
    await fetchTodayAttendance();
  }

  Future<void> initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      currentUser = UserModel(
        userId: widget.user.userId ?? prefs.getString('userId'),
        name: widget.user.name ?? prefs.getString('name'),
        email: widget.user.email ?? prefs.getString('email'),
        department: widget.user.department ?? prefs.getString('department'),
        role: widget.user.role ?? prefs.getString('role'),
      );
    });
  }

  Future<void> fetchTodayAttendance() async {
    try {
      final url = Uri.parse(
        "https://trainerattendence-backed.onrender.com/api/attendance/user/${widget.user.userId}/today",
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          todayAttendance = data != null
              ? AttendanceModel.fromJson(data)
              : null;
          if (todayAttendance != null &&
              todayAttendance!.checkOutTime == null) {}
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) throw Exception('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied.');
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

  Future<void> checkIn() async {
    try {
      Position pos = await _determinePosition();
      await _getAddress(pos);

      final body = {
        "userId": widget.user.userId ?? "unknown",
        "name": widget.user.name ?? "User",
        "department": widget.user.department ?? "N/A",
        "mode": mode,
        "checkInLatitude": pos.latitude,
        "checkInLongitude": pos.longitude,
        "checkInAddress": address,
      };

      final response = await http.post(
        Uri.parse(
          "https://trainerattendence-backed.onrender.com/api/attendance/checkin",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        setState(() {
          todayAttendance = AttendanceModel.fromJson(jsonDecode(response.body));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Checked in (${mode ? 'Online' : 'Offline'}) successfully",
            ),
          ),
        );
      } else {
        throw Exception("Check-in failed (${response.statusCode})");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> checkOut() async {
    if (todayAttendance == null) return;

    try {
      Position pos = await _determinePosition();
      await _getAddress(pos);

      final body = {
        "userId": todayAttendance!.userId,
        "name": todayAttendance!.userName,
        "department": todayAttendance!.department,
        "mode": mode,
        "checkOutLatitude": pos.latitude,
        "checkOutLongitude": pos.longitude,
        "checkOutAddress": address,
      };

      final response = await http.post(
        Uri.parse(
          "https://trainerattendence-backed.onrender.com/api/attendance/checkout",
        ),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        setState(() {
          todayAttendance = AttendanceModel.fromJson(jsonDecode(response.body));
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Checked Out (${mode ? 'Online' : 'Offline'}) successfully",
            ),
          ),
        );
      } else {
        throw Exception("Check-out failed (${response.statusCode})");
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  String formatDuration(Duration d) =>
      "${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";

  String formatDate(DateTime dt) =>
      "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
      "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        elevation: 0,
        title: Text('Welcome, ${widget.user.name ?? ""} 👋'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () => LogoutDialog.show(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.user.name ?? "",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.user.email ?? "",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Dept: ${widget.user.department ?? "N/A"}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 15,
                ),
                child: Column(
                  children: [
                    const Text(
                      "Select Attendance Mode",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Radio<bool>(
                          value: true,
                          groupValue: mode,
                          onChanged: (v) => setState(() => mode = v!),
                          activeColor: Colors.deepPurple,
                        ),
                        const Text(
                          "Online",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(width: 30),
                        Radio<bool>(
                          value: false,
                          groupValue: mode,
                          onChanged: (v) => setState(() => mode = v!),
                          activeColor: Colors.deepPurple,
                        ),
                        const Text(
                          "Offline",
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (todayAttendance != null) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.login,
                            size: 18,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Check-in: ${formatDate(todayAttendance!.checkInTime)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Check-in Mode: ${todayAttendance?.checkInMode == true ? 'Online' : 'Offline'}",
                      ),

                      if (todayAttendance!.checkInAddress != null)
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 18,
                              color: Colors.deepPurpleAccent,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "Check-in Address: ${todayAttendance!.checkInAddress}",
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 8),
                      if (todayAttendance!.checkOutTime != null) ...[
                        Row(
                          children: [
                            const Icon(
                              Icons.logout,
                              size: 18,
                              color: Colors.redAccent,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "Check-out: ${formatDate(todayAttendance!.checkOutTime!)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Check-out Mode: ${todayAttendance?.checkOutMode == true ? 'Online' : 'Offline'}",
                        ),

                        if (todayAttendance!.checkOutAddress != null)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on,
                                size: 18,
                                color: Colors.redAccent,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  "Check-out Address: ${todayAttendance!.checkOutAddress}",
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 4),
                        Text(
                          "Duration: ${formatDuration(todayAttendance!.duration)}",
                        ),
                      ],
                      const SizedBox(height: 15),
                    ],
                    todayAttendance == null
                        ? Center(
                            child: ElevatedButton.icon(
                              onPressed: checkIn,
                              icon: const Icon(
                                Icons.login,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Check In",
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 15,
                                ),
                              ),
                            ),
                          )
                        : todayAttendance!.checkOutTime == null
                        ? Center(
                            child: ElevatedButton.icon(
                              onPressed: checkOut,
                              icon: const Icon(Icons.logout),
                              label: const Text("Check Out"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.redAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 15,
                                ),
                              ),
                            ),
                          )
                        : const Center(
                            child: Text(
                              "✅ Attendance Completed",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AttendanceListScreen(user: widget.user),
                  ),
                );
              },
              icon: const Icon(Icons.history),
              label: const Text('View Attendance History'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepPurple),
              accountName: Text(widget.user.name ?? 'User'),
              accountEmail: Text(widget.user.email ?? 'No Email'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 40, color: Colors.deepPurple),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Attendance History'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AttendanceListScreen(user: widget.user),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () => LogoutDialog.show(context),
            ),
          ],
        ),
      ),
    );
  }
}
