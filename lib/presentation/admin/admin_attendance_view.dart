import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mobile_attendance_application/presentation/widgets/logout_dialog.dart';

class AdminAttendanceHistoryScreen extends StatefulWidget {
  const AdminAttendanceHistoryScreen({super.key});

  @override
  State<AdminAttendanceHistoryScreen> createState() =>
      _AdminAttendanceHistoryScreenState();
}

class _AdminAttendanceHistoryScreenState
    extends State<AdminAttendanceHistoryScreen> {
  bool _isLoading = true;
  List attendanceList = [];
  List filteredList = [];
  List<String> userList = [];

  String? _selectedUser;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _fetchAttendanceHistory();
  }

  Future<void> _fetchAttendanceHistory() async {
    try {
      final url = Uri.parse(
        "https://trainerattendence-backed.onrender.com/api/attendance/all",
      );
      final response = await http.get(url);
      if (kDebugMode) print("API Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List records = data;

        final users = records
            .map((e) => e['userName'] ?? 'Unknown')
            .toSet()
            .toList();

        setState(() {
          attendanceList = records;
          filteredList = records;
          userList = users.cast<String>();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (kDebugMode) print("Error fetching attendance: $e");
      setState(() => _isLoading = false);
    }
  }

  void _filterRecords() {
    List result = attendanceList;

    if (_selectedUser != null) {
      result = result.where((r) => r['userName'] == _selectedUser).toList();
    }

    if (_startDate != null && _endDate != null) {
      result = result.where((record) {
        final checkIn = record['checkInTime'];
        if (checkIn == null) return false;

        final checkInDate = DateTime.parse(checkIn);
        final recordDate = DateTime(
          checkInDate.year,
          checkInDate.month,
          checkInDate.day,
        );
        final startDate = DateTime(
          _startDate!.year,
          _startDate!.month,
          _startDate!.day,
        );
        final endDate = DateTime(
          _endDate!.year,
          _endDate!.month,
          _endDate!.day,
        );

        return (recordDate.isAtSameMomentAs(startDate) ||
            recordDate.isAtSameMomentAs(endDate) ||
            (recordDate.isAfter(startDate) && recordDate.isBefore(endDate)));
      }).toList();
    }

    setState(() {
      filteredList = result;
    });
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6A11CB),
              surface: Color(0xFF1E1E2C),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _filterRecords();
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedUser = null;
      _startDate = null;
      _endDate = null;
      filteredList = attendanceList;
    });
  }

  String _formatDateTime(String? dateTime) {
    if (dateTime == null || dateTime == "N/A") return "N/A";
    try {
      final dt = DateTime.parse(dateTime);
      return DateFormat('hh:mm a').format(dt);
    } catch (e) {
      return "N/A";
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text(
          "Admin Attendance History",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              LogoutDialog.show(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              children: [
                _buildFilters(dateFormat),
                _buildCountSummary(),
                Expanded(
                  child: filteredList.isEmpty
                      ? const Center(
                          child: Text(
                            "No attendance records found.",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchAttendanceHistory,
                          color: const Color(0xFF6A11CB),
                          child: ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final record = filteredList[index];
                              final name = record['userName'] ?? 'Unknown';
                              final checkIn = record['checkInTime'] ?? 'N/A';
                              final checkOut =
                                  record['checkOutTime'] ?? 'Pending';
                              final dept = record['department'] ?? 'N/A';

                              String formattedDate = 'N/A';
                              if (checkIn != 'N/A') {
                                formattedDate = DateFormat(
                                  'dd MMM yyyy',
                                ).format(DateTime.parse(checkIn));
                              }

                              final isPending = checkOut == 'Pending';

                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.symmetric(
                                  vertical: 6.0,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: const Color(
                                    0xFF1E1E2C,
                                  ).withOpacity(0.8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    radius: 25,
                                    backgroundColor: isPending
                                        ? Colors.orangeAccent
                                        : Colors.green,
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                  ),
                                  title: Text(
                                    name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Dept: $dept",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          "Check-in: ${_formatDateTime(checkIn)}",
                                          style: const TextStyle(
                                            color: Colors.greenAccent,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          "Check-out: ${isPending ? 'Pending' : _formatDateTime(checkOut)}",
                                          style: TextStyle(
                                            color: isPending
                                                ? Colors.orangeAccent
                                                : Colors.redAccent,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Text(
                                          "Date: $formattedDate",
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilters(DateFormat dateFormat) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _pickDateRange,
                icon: const Icon(Icons.date_range, color: Colors.white),
                label: Text(
                  _startDate == null
                      ? "Select Date Range"
                      : "${dateFormat.format(_startDate!)} → ${dateFormat.format(_endDate!)}",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.filter_alt_off, color: Colors.white),
                onPressed: _clearFilters,
              ),
            ],
          ),
          const SizedBox(height: 8),
          DropdownButton<String>(
            value: _selectedUser,
            hint: const Text(
              "Filter by User",
              style: TextStyle(color: Colors.white70),
            ),
            dropdownColor: const Color(0xFF2C2C3E),
            style: const TextStyle(color: Colors.white),
            isExpanded: true,
            items: userList
                .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                .toList(),
            onChanged: (value) {
              setState(() => _selectedUser = value);
              _filterRecords();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCountSummary() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C3E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "Total Records: ${filteredList.length}",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
