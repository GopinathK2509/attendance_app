
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_attendance_application/core/themes/user_notifier.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobile_attendance_application/data/models/attendance_model.dart';
import 'package:mobile_attendance_application/data/models/user_model.dart';
import 'package:mobile_attendance_application/presentation/settings/settings_screen.dart';
import 'package:mobile_attendance_application/presentation/widgets/logout_dialog.dart';
import 'attendance_list_screen.dart';

class UserHomeScreen extends StatefulWidget {
  final UserModel user;
  final ValueNotifier<String?> profileImageUrl;

  const UserHomeScreen({
    super.key,
    required this.user,
    required this.profileImageUrl,
  });

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen>
    with WidgetsBindingObserver {
  AttendanceModel? todayAttendance;
  UserModel? currentUser;

  String? address;
  bool mode = true;

  bool isLoading = true;
  bool isLoadingAttendance = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadAll();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadAll();
    }
  }

  Future<void> _loadAll() async {
    setState(() {
      isLoading = true;
      isLoadingAttendance = true;
    });

    await _initializeUser();
    await _fetchTodayAttendance();

    setState(() {
      isLoading = false;
      isLoadingAttendance = false;
    });
  }

  Future<void> _initializeUser() async {
    final prefs = await SharedPreferences.getInstance();

    currentUser = UserModel(
      userId: prefs.getString('userId') ?? widget.user.userId,
      name: prefs.getString('name') ?? widget.user.name,
      email: prefs.getString('email') ?? widget.user.email,
      department: prefs.getString('department') ?? widget.user.department,
      role: prefs.getString('role') ?? widget.user.role,
    );

    widget.profileImageUrl.value =
        "https://trainerattendence-backed.onrender.com/api/users/photo/${currentUser!.userId}";
  }


  Future<void> _fetchTodayAttendance() async {
    if (currentUser == null) return;

    setState(() => isLoadingAttendance = true);

    try {
      final url = Uri.parse(
        "https://trainerattendence-backed.onrender.com/api/attendance/user/${currentUser!.userId}",
      );

      final response = await http.get(url);

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        dynamic decoded;

        try {
          decoded = jsonDecode(response.body);
        } catch (e) {
          debugPrint("JSON decode error: $e");
          todayAttendance = null;
          return;
        }
        if (decoded is List && decoded.isNotEmpty) {
          final now = DateTime.now();

          final todaysRecords = decoded.where((item) {
            try {
              final dt = DateTime.parse(item["date"] ?? item["checkInTime"]);
              return dt.year == now.year &&
                  dt.month == now.month &&
                  dt.day == now.day;
            } catch (_) {
              return false;
            }
          }).toList();

          if (todaysRecords.isNotEmpty) {
            todayAttendance = AttendanceModel.fromJson(todaysRecords.last);
          } else {
            todayAttendance = null; 
          }
        } else if (decoded is Map<String, dynamic>) {
          todayAttendance = AttendanceModel.fromJson(decoded);
        } else {
          todayAttendance = null;
        }
      } else {
        todayAttendance = null;
      }
    } catch (e) {
      debugPrint("Fetch today attendance error: $e");
      todayAttendance = null;
    } finally {
      setState(() => isLoadingAttendance = false);
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
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        address =
            '${p.name}, ${p.subLocality}, ${p.locality}, ${p.postalCode}, ${p.country}';
      } else {
        address = 'Address not available';
      }
    } catch (_) {
      address = 'Could not fetch address';
    }
  }

  Future<void> _checkIn() async {
    if (currentUser == null) return;

    try {
      setState(() => isLoadingAttendance = true);

      final pos = await _determinePosition();
      await _getAddress(pos);

      final body = {
        "userId": currentUser!.userId,
        "name": currentUser!.name ?? "",
        "department": currentUser!.department ?? "",
        "checkInMode": mode,
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

      debugPrint("Check-In Response: ${response.body}");

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }

      if (decoded is List && decoded.isNotEmpty) {
        todayAttendance = AttendanceModel.fromJson(decoded.last);
      }
      else if (decoded is Map<String, dynamic>) {
        todayAttendance = AttendanceModel.fromJson(decoded);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Checked in Successfully(${mode ? 'Online' : 'Offline'})",
          ),
        ),
      );
      await _fetchTodayAttendance();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoadingAttendance = false);
    }
  }

  Future<void> _checkOut() async {
    if (todayAttendance == null) return;

    try {
      setState(() => isLoadingAttendance = true);

      final pos = await _determinePosition();
      await _getAddress(pos);

      final body = {
        "userId": todayAttendance!.userId,
        "name": todayAttendance!.userName ?? "",
        "department": todayAttendance!.department ?? "",
        "checkOutMode": mode,
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

      debugPrint("Check-Out Response: ${response.body}");

      dynamic decoded;

      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        decoded = null;
      }

      if (decoded is List && decoded.isNotEmpty) {
        todayAttendance = AttendanceModel.fromJson(decoded.last);
      } else if (decoded is Map<String, dynamic>) {
        todayAttendance = AttendanceModel.fromJson(decoded);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Checked Out Successfully(${mode ? 'Online' : 'Offline'})",
          ),
        ),
      );
      await _fetchTodayAttendance();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => isLoadingAttendance = false);
    }
  }

  String formatDuration(Duration? d) => d != null
      ? "${d.inHours.toString().padLeft(2, '0')}:${(d.inMinutes % 60).toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}"
      : 'N/A';

  String formatDate(DateTime? dt) => dt != null
      ? "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} "
            "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}"
      : 'N/A';

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Widget _buildShimmerHeader() {
    return Shimmer.fromColors(
      baseColor: Colors.deepPurple.shade200,
      highlightColor: Colors.deepPurple.shade50,
      period: const Duration(milliseconds: 1100),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade400, Colors.deepPurpleAccent],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 18, width: 120, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 12, width: 200, color: Colors.white),
            const SizedBox(height: 8),
            Container(height: 12, width: 160, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7B2FF7), Color(0xFF9E7BFF)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.12),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          ValueListenableBuilder<String?>(
            valueListenable: widget.profileImageUrl,
            builder: (context, imageUrl, _) {
              return CircleAvatar(
                radius: 36,
                backgroundColor: Colors.white,
                backgroundImage: imageUrl != null
                    ? NetworkImage(imageUrl)
                    : null,
                child: imageUrl == null
                    ? const Icon(
                        Icons.person,
                        size: 36,
                        color: Colors.deepPurple,
                      )
                    : null,
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<UserModel?>(
                  valueListenable: globalUser,
                  builder: (context, user, _) {
                    return Text(
                      user?.name ?? widget.user.name ?? 'User',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 6),
                Text(
                  currentUser?.email ?? widget.user.email ?? 'example@mail.com',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  "Dept: ${currentUser?.department ?? 'N/A'}",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        child: Column(
          children: [
            const Text(
              "Select Attendance Mode",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio<bool>(
                  value: true,
                  groupValue: mode,
                  onChanged: (v) => setState(() => mode = v!),
                  activeColor: Colors.deepPurple,
                ),
                const SizedBox(width: 6),
                const Text(
                  "Online",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 30),
                Radio<bool>(
                  value: false,
                  groupValue: mode,
                  onChanged: (v) => setState(() => mode = v!),
                  activeColor: Colors.deepPurple,
                ),
                const SizedBox(width: 6),
                const Text(
                  "Offline",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceDetails() {
    if (isLoadingAttendance) {
      return Column(
        children: [
          const SizedBox(height: 8),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: 200, color: Colors.white),
                const SizedBox(height: 10),
                Container(height: 12, width: 150, color: Colors.white),
                const SizedBox(height: 12),
                Container(height: 12, width: 250, color: Colors.white),
              ],
            ),
          ),
        ],
      );
    }

    if (todayAttendance == null) {
      return Column(
        children: [
          const Text(
            "No attendance record for today",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _checkIn,
            icon: const Icon(Icons.login, color: Colors.white),
            label: const Text(
              "Check In",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7B2FF7),
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      );
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.login, color: Colors.deepPurple, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Check-in: ${formatDate(todayAttendance!.checkInTime)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            if (todayAttendance!.checkInMode != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: todayAttendance!.checkInMode!
                      ? Colors.green
                      : Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      todayAttendance!.checkInMode!
                          ? Icons.wifi
                          : Icons.wifi_off,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      todayAttendance!.checkInMode! ? 'Online' : 'Offline',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            if (todayAttendance!.checkInAddress != null)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.location_on,
                    color: Colors.deepPurpleAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      todayAttendance!.checkInAddress!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            const Divider(height: 20, thickness: 1),

            if (todayAttendance!.checkOutTime != null) ...[
              Row(
                children: [
                  const Icon(Icons.login, color: Colors.deepPurple, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Check-Out: ${formatDate(todayAttendance!.checkOutTime)}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (todayAttendance!.checkOutMode != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: todayAttendance!.checkOutMode!
                        ? Colors.green
                        : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        todayAttendance!.checkOutMode!
                            ? Icons.wifi
                            : Icons.wifi_off,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        todayAttendance!.checkOutMode! ? 'Online' : 'Offline',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 6),
              if (todayAttendance!.checkOutAddress != null)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.redAccent,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        todayAttendance!.checkOutAddress!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 8),
              Text(
                "Duration: ${formatDuration(todayAttendance!.duration)}",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],

            const SizedBox(height: 16),

            Center(
              child: todayAttendance!.checkOutTime == null
                  ? ElevatedButton.icon(
                      onPressed: _checkOut,
                      icon: const Icon(Icons.logout, color: Colors.white),
                      label: const Text(
                        "Check Out",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 36,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )
                  : const Text(
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        elevation: 0,
        title: ValueListenableBuilder<UserModel?>(
          valueListenable: globalUser,
          builder: (context, user, _) {
            final displayName = user?.name ?? widget.user.name ?? 'User';
            return Text('Welcome, $displayName');
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: RefreshIndicator(
        onRefresh: _loadAll,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              isLoading ? _buildShimmerHeader() : _buildHeaderCard(),
              const SizedBox(height: 24),
              _buildModeCard(),
              const SizedBox(height: 20),
              _buildAttendanceDetails(),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(color: Colors.deepPurple),
              accountName: ValueListenableBuilder<UserModel?>(
                valueListenable: globalUser,
                builder: (context, user, _) {
                  final displayName = user?.name ?? widget.user.name ?? 'User';
                  return Text(displayName);
                },
              ),
              accountEmail: Text(
                currentUser?.email ?? widget.user.email ?? 'example@mail.com',
              ),
              currentAccountPicture: ValueListenableBuilder<String?>(
                valueListenable: widget.profileImageUrl,
                builder: (context, imageUrl, _) {
                  return CircleAvatar(
                    backgroundColor: Colors.white,
                    backgroundImage: imageUrl != null
                        ? NetworkImage(imageUrl)
                        : null,
                    child: imageUrl == null
                        ? const Icon(
                            Icons.person,
                            size: 40,
                            color: Colors.deepPurple,
                          )
                        : null,
                  );
                },
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
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => UserSettingsScreen(
                      user: widget.user,
                      profileImageUrl: widget.profileImageUrl,
                    ),
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
