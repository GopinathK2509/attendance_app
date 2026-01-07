// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:mobile_attendance_application/presentation/widgets/logout_dialog.dart';

// class AdminAttendanceHistoryScreen extends StatefulWidget {
//   const AdminAttendanceHistoryScreen({super.key});

//   @override
//   State<AdminAttendanceHistoryScreen> createState() =>
//       _AdminAttendanceHistoryScreenState();
// }

// class _AdminAttendanceHistoryScreenState
//     extends State<AdminAttendanceHistoryScreen> {
//   bool _isLoading = true;
//   List attendanceList = [];
//   List filteredList = [];
//   List<String> userList = [];

//   String? _selectedUser;
//   DateTime? _startDate;
//   DateTime? _endDate;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAttendanceHistory();
//   }

//   Future<void> _fetchAttendanceHistory() async {
//     try {
//       final url = Uri.parse(
//         "https://trainerattendence-backed.onrender.com/api/attendance/all",
//       );
//       final response = await http.get(url);
//       if (kDebugMode) print("API Response: ${response.body}");

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final List records = data;

//         final users = records
//             .map((e) => e['userName'] ?? 'Unknown')
//             .toSet()
//             .toList();

//         setState(() {
//           attendanceList = records;
//           filteredList = records;
//           userList = users.cast<String>();
//           _isLoading = false;
//         });
//       } else {
//         setState(() => _isLoading = false);
//       }
//     } catch (e) {
//       if (kDebugMode) print("Error fetching attendance: $e");
//       setState(() => _isLoading = false);
//     }
//   }

//   void _filterRecords() {
//     List result = attendanceList;

//     if (_selectedUser != null) {
//       result = result.where((r) => r['userName'] == _selectedUser).toList();
//     }

//     if (_startDate != null && _endDate != null) {
//       result = result.where((record) {
//         final checkIn = record['checkInTime'];
//         if (checkIn == null) return false;

//         final checkInDate = DateTime.parse(checkIn);
//         final recordDate = DateTime(
//           checkInDate.year,
//           checkInDate.month,
//           checkInDate.day,
//         );
//         final startDate = DateTime(
//           _startDate!.year,
//           _startDate!.month,
//           _startDate!.day,
//         );
//         final endDate = DateTime(
//           _endDate!.year,
//           _endDate!.month,
//           _endDate!.day,
//         );

//         return (recordDate.isAtSameMomentAs(startDate) ||
//             recordDate.isAtSameMomentAs(endDate) ||
//             (recordDate.isAfter(startDate) && recordDate.isBefore(endDate)));
//       }).toList();
//     }

//     setState(() {
//       filteredList = result;
//     });
//   }

//   Future<void> _pickDateRange() async {
//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(2024),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: ThemeData.dark().copyWith(
//             colorScheme: const ColorScheme.dark(
//               primary: Color(0xFF6A11CB),
//               surface: Color(0xFF1E1E2C),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       setState(() {
//         _startDate = picked.start;
//         _endDate = picked.end;
//       });
//       _filterRecords();
//     }
//   }

//   void _clearFilters() {
//     setState(() {
//       _selectedUser = null;
//       _startDate = null;
//       _endDate = null;
//       filteredList = attendanceList;
//     });
//   }

//   String _formatDateTime(String? dateTime) {
//     if (dateTime == null || dateTime == "N/A") return "N/A";
//     try {
//       final dt = DateTime.parse(dateTime);
//       return DateFormat('hh:mm a').format(dt);
//     } catch (e) {
//       return "N/A";
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final dateFormat = DateFormat('dd MMM yyyy');

//     return Scaffold(
//       backgroundColor: const Color(0xFF121212),
//       appBar: AppBar(
//         title: const Text(
//           "Admin Attendance History",
//           style: TextStyle(fontWeight: FontWeight.w600),
//         ),
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         centerTitle: true,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.logout, color: Colors.white),
//             onPressed: () {
//               LogoutDialog.show(context);
//             },
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator(color: Colors.white))
//           : Column(
//               children: [
//                 _buildFilters(dateFormat),
//                 _buildCountSummary(),
//                 Expanded(
//                   child: filteredList.isEmpty
//                       ? const Center(
//                           child: Text(
//                             "No attendance records found.",
//                             style: TextStyle(
//                               color: Colors.white70,
//                               fontSize: 16,
//                             ),
//                           ),
//                         )
//                       : RefreshIndicator(
//                           onRefresh: _fetchAttendanceHistory,
//                           color: const Color(0xFF6A11CB),
//                           child: ListView.builder(
//                             padding: const EdgeInsets.all(12),
//                             itemCount: filteredList.length,
//                             itemBuilder: (context, index) {
//                               final record = filteredList[index];
//                               final name = record['userName'] ?? 'Unknown';
//                               final checkIn = record['checkInTime'] ?? 'N/A';
//                               final checkOut =
//                                   record['checkOutTime'] ?? 'Pending';
//                               final dept = record['department'] ?? 'N/A';

//                               String formattedDate = 'N/A';
//                               if (checkIn != 'N/A') {
//                                 formattedDate = DateFormat(
//                                   'dd MMM yyyy',
//                                 ).format(DateTime.parse(checkIn));
//                               }

//                               final isPending = checkOut == 'Pending';

//                               return AnimatedContainer(
//                                 duration: const Duration(milliseconds: 300),
//                                 margin: const EdgeInsets.symmetric(
//                                   vertical: 6.0,
//                                 ),
//                                 decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.circular(15),
//                                   color: const Color(
//                                     0xFF1E1E2C,
//                                   ).withOpacity(0.8),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: Colors.black.withOpacity(0.3),
//                                       blurRadius: 6,
//                                       offset: const Offset(0, 3),
//                                     ),
//                                   ],
//                                 ),
//                                 child: ListTile(
//                                   leading: CircleAvatar(
//                                     radius: 25,
//                                     backgroundColor: isPending
//                                         ? Colors.orangeAccent
//                                         : Colors.green,
//                                     child: const Icon(
//                                       Icons.person,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                                   title: Text(
//                                     name,
//                                     style: const TextStyle(
//                                       color: Colors.white,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                   subtitle: Padding(
//                                     padding: const EdgeInsets.only(top: 4),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           "Dept: $dept",
//                                           style: const TextStyle(
//                                             color: Colors.white70,
//                                             fontSize: 13,
//                                           ),
//                                         ),
//                                         Text(
//                                           "Check-in: ${_formatDateTime(checkIn)}",
//                                           style: const TextStyle(
//                                             color: Colors.greenAccent,
//                                             fontSize: 13,
//                                           ),
//                                         ),
//                                         Text(
//                                           "Check-out: ${isPending ? 'Pending' : _formatDateTime(checkOut)}",
//                                           style: TextStyle(
//                                             color: isPending
//                                                 ? Colors.orangeAccent
//                                                 : Colors.redAccent,
//                                             fontSize: 13,
//                                           ),
//                                         ),
//                                         Text(
//                                           "Date: $formattedDate",
//                                           style: const TextStyle(
//                                             color: Colors.white70,
//                                             fontSize: 13,
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ),
//                 ),
//               ],
//             ),
//     );
//   }

//   Widget _buildFilters(DateFormat dateFormat) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFF1E1E2C),
//         borderRadius: const BorderRadius.vertical(bottom: Radius.circular(15)),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 6,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       child: Column(
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               TextButton.icon(
//                 onPressed: _pickDateRange,
//                 icon: const Icon(Icons.date_range, color: Colors.white),
//                 label: Text(
//                   _startDate == null
//                       ? "Select Date Range"
//                       : "${dateFormat.format(_startDate!)} → ${dateFormat.format(_endDate!)}",
//                   style: const TextStyle(color: Colors.white),
//                 ),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.filter_alt_off, color: Colors.white),
//                 onPressed: _clearFilters,
//               ),
//             ],
//           ),
//           const SizedBox(height: 8),
//           DropdownButton<String>(
//             value: _selectedUser,
//             hint: const Text(
//               "Filter by User",
//               style: TextStyle(color: Colors.white70),
//             ),
//             dropdownColor: const Color(0xFF2C2C3E),
//             style: const TextStyle(color: Colors.white),
//             isExpanded: true,
//             items: userList
//                 .map((u) => DropdownMenuItem(value: u, child: Text(u)))
//                 .toList(),
//             onChanged: (value) {
//               setState(() => _selectedUser = value);
//               _filterRecords();
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildCountSummary() {
//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       decoration: BoxDecoration(
//         color: const Color(0xFF2C2C3E),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Text(
//         "Total Records: ${filteredList.length}",
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
// }

// import 'dart:convert';
// import 'dart:io';

// import 'package:excel/excel.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:open_filex/open_filex.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:share_plus/share_plus.dart';

// class AdminAttendanceHistoryScreen extends StatefulWidget {
//   const AdminAttendanceHistoryScreen({super.key});

//   @override
//   State<AdminAttendanceHistoryScreen> createState() =>
//       _AdminAttendanceHistoryScreenState();
// }

// class _AdminAttendanceHistoryScreenState
//     extends State<AdminAttendanceHistoryScreen> {
//   // Data & caches
//   bool _isLoading = true;
//   List<Map<String, dynamic>> _allRecords = [];
//   List<Map<String, dynamic>> _filtered = [];

//   // filter controls
//   String? _selectedUser;
//   String? _selectedDept;
//   DateTime? _startDate;
//   DateTime? _endDate;
//   String _statusFilter = 'all'; // all / checkedout / pending
//   String _searchQuery = '';

//   // sort
//   String _sortBy = 'newest'; // newest, oldest, name_asc, name_desc

//   // pagination
//   static const int _pageSize = 25;
//   int _currentPage = 1;

//   // helper lists
//   List<String> _userList = [];
//   List<String> _deptList = [];

//   // export / busy state
//   bool _isExporting = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchAttendanceHistory();
//   }

//   Future<void> _fetchAttendanceHistory() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final uri = Uri.parse(
//         "https://trainerattendence-backed.onrender.com/api/attendance/all",
//       );
//       final res = await http.get(uri);

//       if (res.statusCode == 200) {
//         final data = jsonDecode(res.body);
//         final List<Map<String, dynamic>> list = (data as List)
//             .map((e) => Map<String, dynamic>.from(e as Map))
//             .toList();

//         // Cache
//         _allRecords = list;

//         // build helper lists
//         final users = _allRecords
//             .map((e) => (e['userName'] ?? 'Unknown').toString())
//             .toSet()
//             .toList();
//         final depts = _allRecords
//             .map((e) => (e['department'] ?? 'Unknown').toString())
//             .toSet()
//             .toList();

//         users.sort();
//         depts.sort();

//         setState(() {
//           _userList = users.cast<String>();
//           _deptList = depts.cast<String>();
//         });

//         _applyFiltersAndSort();
//       } else {
//         if (kDebugMode) {
//           print('Attendance API failed: ${res.statusCode} ${res.body}');
//         }
//         setState(() {
//           _allRecords = [];
//           _filtered = [];
//         });
//       }
//     } catch (e) {
//       if (kDebugMode) print('Fetch error: $e');
//       setState(() {
//         _allRecords = [];
//         _filtered = [];
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // ================== FILTER / SORT / PAGINATION ==================

//   void _applyFiltersAndSort() {
//     List<Map<String, dynamic>> list = List.from(_allRecords);

//     // Search
//     final q = _searchQuery.trim().toLowerCase();
//     if (q.isNotEmpty) {
//       list = list.where((r) {
//         final name = (r['userName'] ?? '').toString().toLowerCase();
//         final dept = (r['department'] ?? '').toString().toLowerCase();
//         final date = (r['checkInTime'] ?? '').toString().toLowerCase();
//         return name.contains(q) || dept.contains(q) || date.contains(q);
//       }).toList();
//     }

//     // user filter
//     if (_selectedUser != null && _selectedUser!.isNotEmpty) {
//       list = list.where((r) => (r['userName'] ?? '') == _selectedUser).toList();
//     }

//     // dept filter
//     if (_selectedDept != null && _selectedDept!.isNotEmpty) {
//       list = list
//           .where((r) => (r['department'] ?? '') == _selectedDept)
//           .toList();
//     }

//     // status filter
//     if (_statusFilter == 'checkedout') {
//       list = list.where((r) => r['checkOutTime'] != null).toList();
//     } else if (_statusFilter == 'pending') {
//       list = list.where((r) => r['checkOutTime'] == null).toList();
//     }

//     // date range
//     if (_startDate != null && _endDate != null) {
//       final start = DateTime(
//         _startDate!.year,
//         _startDate!.month,
//         _startDate!.day,
//       );
//       final end = DateTime(
//         _endDate!.year,
//         _endDate!.month,
//         _endDate!.day,
//         23,
//         59,
//         59,
//       );
//       list = list.where((r) {
//         final raw = r['checkInTime'];
//         if (raw == null) return false;
//         try {
//           final dt = DateTime.parse(raw.toString());
//           return (dt.isAfter(start) || dt.isAtSameMomentAs(start)) &&
//               (dt.isBefore(end) || dt.isAtSameMomentAs(end));
//         } catch (_) {
//           return false;
//         }
//       }).toList();
//     }

//     // sort
//     list.sort((a, b) {
//       switch (_sortBy) {
//         case 'oldest':
//           return _parseDate(
//             a['checkInTime'],
//           ).compareTo(_parseDate(b['checkInTime']));
//         case 'name_asc':
//           return (a['userName'] ?? '').toString().compareTo(
//             (b['userName'] ?? '').toString(),
//           );
//         case 'name_desc':
//           return (b['userName'] ?? '').toString().compareTo(
//             (a['userName'] ?? '').toString(),
//           );
//         case 'newest':
//         default:
//           return _parseDate(
//             b['checkInTime'],
//           ).compareTo(_parseDate(a['checkInTime']));
//       }
//     });

//     setState(() {
//       _filtered = list;
//       _currentPage = 1;
//     });
//   }

//   DateTime _parseDate(dynamic raw) {
//     if (raw == null) return DateTime.fromMillisecondsSinceEpoch(0);
//     try {
//       return DateTime.parse(raw.toString());
//     } catch (_) {
//       return DateTime.fromMillisecondsSinceEpoch(0);
//     }
//   }

//   List<Map<String, dynamic>> get _pagedList {
//     final start = 0;
//     final end = (_currentPage * _pageSize).clamp(0, _filtered.length);
//     return _filtered.sublist(start, end);
//   }

//   bool get _canLoadMore => _pagedList.length < _filtered.length;

//   void _loadMore() {
//     if (_canLoadMore) {
//       setState(() {
//         _currentPage++;
//       });
//     }
//   }

//   // ================== UI Helpers ==================

//   Future<void> _pickDateRange() async {
//     final now = DateTime.now();
//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(now.year - 5),
//       lastDate: DateTime(now.year + 1),
//       initialDateRange: _startDate != null && _endDate != null
//           ? DateTimeRange(start: _startDate!, end: _endDate!)
//           : null,
//     );

//     if (picked != null) {
//       setState(() {
//         _startDate = picked.start;
//         _endDate = picked.end;
//       });
//       _applyFiltersAndSort();
//     }
//   }

//   void _clearFilters() {
//     setState(() {
//       _selectedUser = null;
//       _selectedDept = null;
//       _startDate = null;
//       _endDate = null;
//       _statusFilter = 'all';
//       _searchQuery = '';
//       _sortBy = 'newest';
//     });
//     _applyFiltersAndSort();
//   }

//   String _formatTimeOrNA(dynamic raw) {
//     if (raw == null) return 'N/A';
//     try {
//       final dt = DateTime.parse(raw.toString());
//       return DateFormat('hh:mm a').format(dt);
//     } catch (_) {
//       return raw.toString();
//     }
//   }

//   String _formatDateOnly(dynamic raw) {
//     if (raw == null) return 'N/A';
//     try {
//       final dt = DateTime.parse(raw.toString());
//       return DateFormat('dd MMM yyyy').format(dt);
//     } catch (_) {
//       return raw.toString();
//     }
//   }

//   Future<Directory> _getDownloadDir() async {
//     if (Platform.isAndroid) {
//       final candidate = Directory('/storage/emulated/0/Download');
//       if (await candidate.exists()) return candidate;
//       final ext = await getExternalStorageDirectory();
//       if (ext != null) return ext;
//     }
//     return getApplicationDocumentsDirectory();
//   }

//   // ================== EXPORT / SHARE ==================
//   Future<File?> _exportExcelFile({List<Map<String, dynamic>>? rows}) async {
//     final exportRows = rows ?? _filtered;

//     if (exportRows.isEmpty) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('No records to export')));
//       }
//       return null;
//     }

//     final excel = Excel.createExcel();
//     final Sheet sheet = excel['Sheet1'];

//     // Header (use TextCellValue to match excel package expectations)
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
//       final date = _formatDateOnly(r['checkInTime']);
//       final inTime = _formatTimeOrNA(r['checkInTime']);
//       final outTime = _formatTimeOrNA(r['checkOutTime']);
//       final durationVal = r['duration'];
//       final duration = durationVal != null ? durationVal.toString() : '-';

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
//         TextCellValue(duration),
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

//   Future<File?> _exportPdfFile({List<Map<String, dynamic>>? rows}) async {
//     final exportRows = rows ?? _filtered;
//     if (exportRows.isEmpty) {
//       if (mounted)
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('No records to export')));
//       return null;
//     }

//     final pdf = pw.Document();
//     final title = 'Attendance Report';
//     final period = (_startDate != null && _endDate != null)
//         ? '${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}'
//         : 'All Dates';

//     // Build table data ensuring addresses are single-line
//     final tableHeaders = [
//       'Name',
//       'Dept',
//       'Date',
//       'In',
//       'Out',
//       'Duration',
//       'In Addr',
//       'Out Addr',
//       'In Mode',
//       'Out Mode',
//     ];

//     final tableData = exportRows.map((r) {
//       final date = _formatDateOnly(r['checkInTime']);
//       final inTime = _formatTimeOrNA(r['checkInTime']);
//       final outTime = _formatTimeOrNA(r['checkOutTime']);
//       final dur = r['duration'] != null ? r['duration'].toString() : '-';
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
//         r['userName'] ?? '-',
//         r['department'] ?? '-',
//         date,
//         inTime,
//         outTime,
//         dur,
//         inAddr,
//         outAddr,
//         inMode,
//         outMode,
//       ];
//     }).toList();

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         build: (context) {
//           return [
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//               children: [
//                 pw.Text(
//                   title,
//                   style: pw.TextStyle(
//                     fontSize: 18,
//                     fontWeight: pw.FontWeight.bold,
//                   ),
//                 ),
//                 pw.Text(period, style: pw.TextStyle(fontSize: 10)),
//               ],
//             ),
//             pw.SizedBox(height: 12),
//             pw.Table.fromTextArray(
//               headers: tableHeaders,
//               data: tableData,
//               cellStyle: const pw.TextStyle(fontSize: 8),
//               headerStyle: pw.TextStyle(
//                 fontSize: 9,
//                 fontWeight: pw.FontWeight.bold,
//               ),
//               columnWidths: {
//                 0: pw.FlexColumnWidth(2),
//                 6: pw.FlexColumnWidth(3),
//                 7: pw.FlexColumnWidth(3),
//               },
//             ),
//             pw.SizedBox(height: 10),
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//               children: [
//                 pw.Text(
//                   'Total records: ${exportRows.length}',
//                   style: const pw.TextStyle(fontSize: 10),
//                 ),
//                 pw.Text(
//                   'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
//                   style: const pw.TextStyle(fontSize: 10),
//                 ),
//               ],
//             ),
//           ];
//         },
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

//   Future<void> _doExportExcel() async {
//     setState(() => _isExporting = true);
//     try {
//       final f = await _exportExcelFile();
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
//       if (mounted)
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Excel export failed: $e')));
//     } finally {
//       setState(() => _isExporting = false);
//     }
//   }

//   Future<void> _doExportPdf() async {
//     setState(() => _isExporting = true);
//     try {
//       final f = await _exportPdfFile();
//       if (f != null) {
//         await OpenFilex.open(f.path);
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('PDF exported: ${f.path.split('/').last}')),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted)
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('PDF export failed: $e')));
//     } finally {
//       setState(() => _isExporting = false);
//     }
//   }

//   Future<void> _shareExcel() async {
//     setState(() => _isExporting = true);
//     try {
//       final f = await _exportExcelFile();
//       if (f != null) {
//         await Share.shareXFiles([XFile(f.path)], text: 'Attendance (Excel)');
//       }
//     } catch (e) {
//       if (mounted)
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
//     } finally {
//       setState(() => _isExporting = false);
//     }
//   }

//   Future<void> _sharePdf() async {
//     setState(() => _isExporting = true);
//     try {
//       final f = await _exportPdfFile();
//       if (f != null) {
//         await Share.shareXFiles([XFile(f.path)], text: 'Attendance (PDF)');
//       }
//     } catch (e) {
//       if (mounted)
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
//     } finally {
//       setState(() => _isExporting = false);
//     }
//   }

//   // ================== Build UI ==================
//   @override
//   Widget build(BuildContext context) {
//     final dateLabel = (_startDate != null && _endDate != null)
//         ? '${DateFormat('dd MMM yyyy').format(_startDate!)} → ${DateFormat('dd MMM yyyy').format(_endDate!)}'
//         : 'All dates';

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Admin Attendance History"),
//         centerTitle: true,
//         backgroundColor: const Color(0xFF4A148C), // deep purple
//         elevation: 0,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _fetchAttendanceHistory,
//             tooltip: 'Refresh',
//           ),
//           PopupMenuButton<String>(
//             onSelected: (s) {
//               if (s == 'exp_xlsx') _doExportExcel();
//               if (s == 'exp_pdf') _doExportPdf();
//               if (s == 'share_xlsx') _shareExcel();
//               if (s == 'share_pdf') _sharePdf();
//             },
//             itemBuilder: (_) => [
//               const PopupMenuItem(
//                 value: 'exp_xlsx',
//                 child: Text('Export Excel'),
//               ),
//               const PopupMenuItem(value: 'exp_pdf', child: Text('Export PDF')),
//               const PopupMenuDivider(),
//               const PopupMenuItem(
//                 value: 'share_xlsx',
//                 child: Text('Share Excel'),
//               ),
//               const PopupMenuItem(value: 'share_pdf', child: Text('Share PDF')),
//             ],
//             icon: const Icon(Icons.download),
//           ),
//         ],
//       ),
//       body: Container(
//         color: const Color(0xFF0E0E10),
//         child: Column(
//           children: [
//             // Filters area (responsive)
//             Container(
//               padding: const EdgeInsets.all(12),
//               color: const Color(0xFF151516),
//               child: LayoutBuilder(
//                 builder: (context, constraints) {
//                   final narrow = constraints.maxWidth < 800;
//                   return Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // First row: search + icons
//                       Row(
//                         children: [
//                           Expanded(
//                             child: TextField(
//                               style: const TextStyle(color: Colors.white),
//                               decoration: InputDecoration(
//                                 hintText: 'Search by name / dept / date',
//                                 hintStyle: TextStyle(
//                                   color: Colors.white70.withOpacity(0.9),
//                                 ),
//                                 prefixIcon: const Icon(
//                                   Icons.search,
//                                   color: Colors.white70,
//                                 ),
//                                 filled: true,
//                                 fillColor: const Color(0xFF1A1A1A),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(10),
//                                   borderSide: BorderSide.none,
//                                 ),
//                                 contentPadding: const EdgeInsets.symmetric(
//                                   vertical: 12,
//                                 ),
//                               ),
//                               onChanged: (v) {
//                                 _searchQuery = v;
//                                 _applyFiltersAndSort();
//                               },
//                             ),
//                           ),
//                           const SizedBox(width: 8),
//                           IconButton(
//                             icon: const Icon(
//                               Icons.date_range,
//                               color: Colors.white,
//                             ),
//                             onPressed: _pickDateRange,
//                             tooltip: 'Date range',
//                           ),
//                           const SizedBox(width: 2),
//                           IconButton(
//                             icon: const Icon(
//                               Icons.filter_alt_off,
//                               color: Colors.white70,
//                             ),
//                             onPressed: _clearFilters,
//                             tooltip: 'Clear filters',
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),

//                       // Second row: dropdowns & controls (responsive)
//                       narrow
//                           ? Column(
//                               crossAxisAlignment: CrossAxisAlignment.stretch,
//                               children: [
//                                 _buildDropdownsWrap(isNarrow: true),
//                                 const SizedBox(height: 8),
//                                 _buildChipsAndCounts(dateLabel),
//                               ],
//                             )
//                           : Row(
//                               children: [
//                                 Expanded(
//                                   child: _buildDropdownsWrap(isNarrow: false),
//                                 ),
//                                 const SizedBox(width: 12),
//                                 Expanded(
//                                   child: _buildChipsAndCounts(dateLabel),
//                                 ),
//                               ],
//                             ),
//                     ],
//                   );
//                 },
//               ),
//             ),

//             // content area
//             Expanded(
//               child: _isLoading
//                   ? _buildShimmer()
//                   : RefreshIndicator(
//                       onRefresh: _fetchAttendanceHistory,
//                       color: Colors.deepPurple,
//                       child: _filtered.isEmpty
//                           ? ListView(
//                               children: const [
//                                 SizedBox(height: 60),
//                                 Center(
//                                   child: Text(
//                                     'No records found',
//                                     style: TextStyle(color: Colors.white70),
//                                   ),
//                                 ),
//                               ],
//                             )
//                           : ListView.builder(
//                               padding: const EdgeInsets.all(12),
//                               itemCount:
//                                   _pagedList.length + (_canLoadMore ? 1 : 0),
//                               itemBuilder: (context, idx) {
//                                 if (idx == _pagedList.length && _canLoadMore) {
//                                   return Center(
//                                     child: TextButton.icon(
//                                       onPressed: _loadMore,
//                                       icon: const Icon(Icons.expand_more),
//                                       label: const Text('Load more'),
//                                     ),
//                                   );
//                                 }

//                                 final r = _pagedList[idx];
//                                 final name = (r['userName'] ?? 'Unknown')
//                                     .toString();
//                                 final dept = (r['department'] ?? '-')
//                                     .toString();
//                                 final checkIn = r['checkInTime'];
//                                 final checkOut = r['checkOutTime'];
//                                 final dateStr = _formatDateOnly(checkIn);
//                                 final inTime = _formatTimeOrNA(checkIn);
//                                 final outTime = _formatTimeOrNA(checkOut);
//                                 final isPending = checkOut == null;
//                                 final avatarUrl =
//                                     r['photoUrl'] ?? r['photo'] ?? null;

//                                 return Card(
//                                   color: const Color(0xFF171718),
//                                   margin: const EdgeInsets.symmetric(
//                                     vertical: 6,
//                                   ),
//                                   shape: RoundedRectangleBorder(
//                                     borderRadius: BorderRadius.circular(12),
//                                   ),
//                                   child: ListTile(
//                                     leading: CircleAvatar(
//                                       radius: 26,
//                                       backgroundColor: isPending
//                                           ? Colors.orange
//                                           : Colors.green,
//                                       backgroundImage: avatarUrl != null
//                                           ? NetworkImage(avatarUrl)
//                                           : null,
//                                       child: avatarUrl == null
//                                           ? const Icon(
//                                               Icons.person,
//                                               color: Colors.white,
//                                             )
//                                           : null,
//                                     ),
//                                     title: Row(
//                                       mainAxisAlignment:
//                                           MainAxisAlignment.spaceBetween,
//                                       children: [
//                                         Expanded(
//                                           child: Text(
//                                             name,
//                                             style: const TextStyle(
//                                               color: Colors.white,
//                                               fontWeight: FontWeight.bold,
//                                             ),
//                                           ),
//                                         ),
//                                         Container(
//                                           padding: const EdgeInsets.symmetric(
//                                             horizontal: 8,
//                                             vertical: 4,
//                                           ),
//                                           decoration: BoxDecoration(
//                                             color: isPending
//                                                 ? Colors.orange
//                                                 : Colors.green,
//                                             borderRadius: BorderRadius.circular(
//                                               8,
//                                             ),
//                                           ),
//                                           child: Text(
//                                             isPending
//                                                 ? 'Pending'
//                                                 : 'Checked Out',
//                                             style: const TextStyle(
//                                               color: Colors.white,
//                                               fontSize: 12,
//                                             ),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                     subtitle: Padding(
//                                       padding: const EdgeInsets.only(top: 8),
//                                       child: Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.start,
//                                         children: [
//                                           Text(
//                                             'Dept: $dept',
//                                             style: const TextStyle(
//                                               color: Colors.white70,
//                                             ),
//                                           ),
//                                           const SizedBox(height: 6),

//                                           Wrap(
//                                             spacing: 12,
//                                             runSpacing: 8,
//                                             crossAxisAlignment:
//                                                 WrapCrossAlignment.center,
//                                             children: [
//                                               Row(
//                                                 mainAxisSize: MainAxisSize.min,
//                                                 children: [
//                                                   const Icon(
//                                                     Icons.calendar_today,
//                                                     size: 14,
//                                                     color: Colors.white70,
//                                                   ),
//                                                   const SizedBox(width: 6),
//                                                   Text(
//                                                     dateStr,
//                                                     style: const TextStyle(
//                                                       color: Colors.white70,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),

//                                               Row(
//                                                 mainAxisSize: MainAxisSize.min,
//                                                 children: [
//                                                   const Icon(
//                                                     Icons.login,
//                                                     size: 14,
//                                                     color: Colors.greenAccent,
//                                                   ),
//                                                   const SizedBox(width: 6),
//                                                   Text(
//                                                     inTime,
//                                                     style: const TextStyle(
//                                                       color: Colors.greenAccent,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),

//                                               Row(
//                                                 mainAxisSize: MainAxisSize.min,
//                                                 children: [
//                                                   const Icon(
//                                                     Icons.logout,
//                                                     size: 14,
//                                                     color: Colors.redAccent,
//                                                   ),
//                                                   const SizedBox(width: 6),
//                                                   Text(
//                                                     outTime,
//                                                     style: TextStyle(
//                                                       color: isPending
//                                                           ? Colors.orangeAccent
//                                                           : Colors.redAccent,
//                                                     ),
//                                                   ),
//                                                 ],
//                                               ),
//                                             ],
//                                           ),
//                                         ],
//                                       ),
//                                     ),
//                                     isThreeLine: true,
//                                   ),
//                                 );
//                               },
//                             ),
//                     ),
//             ),
//           ],
//         ),
//       ),

//       // busy overlay when exporting
//       floatingActionButton: _isExporting
//           ? FloatingActionButton(
//               onPressed: () {},
//               backgroundColor: Colors.grey,
//               child: const CircularProgressIndicator(color: Colors.white),
//             )
//           : null,
//     );
//   }

//   // Build dropdowns as a single row / column depending on width
//   Widget _buildDropdownsWrap({required bool isNarrow}) {
//     // Constrain each dropdown so they don't overflow horizontally
//     Widget constrainedDropdown({required Widget child, double? width}) {
//       if (isNarrow)
//         return Padding(padding: const EdgeInsets.only(bottom: 8), child: child);
//       return ConstrainedBox(
//         constraints: BoxConstraints(minWidth: 120, maxWidth: width ?? 220),
//         child: Padding(padding: const EdgeInsets.only(right: 8), child: child),
//       );
//     }

//     return Wrap(
//       spacing: 8,
//       runSpacing: 8,
//       children: [
//         constrainedDropdown(
//           width: 260,
//           child: DropdownButtonFormField<String?>(
//             value: null,
//             isExpanded: true,
//             dropdownColor: const Color(0xFF1A1A1A),
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: const Color(0xFF1A1A1A),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide.none,
//               ),
//               contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//             ),
//             items:
//                 [
//                   const DropdownMenuItem<String?>(
//                     value: null,
//                     child: Text(
//                       'All users',
//                       style: TextStyle(color: Colors.white70),
//                     ),
//                   ),
//                 ] +
//                 _userList
//                     .map(
//                       (u) =>
//                           DropdownMenuItem<String?>(value: u, child: Text(u)),
//                     )
//                     .toList(),
//             onChanged: (v) {
//               setState(() => _selectedUser = v);
//               _applyFiltersAndSort();
//             },
//             hint: const Text('User'),
//           ),
//         ),
//         constrainedDropdown(
//           width: 220,
//           child: DropdownButtonFormField<String?>(
//             value: null,
//             isExpanded: true,
//             dropdownColor: const Color(0xFF1A1A1A),
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: const Color(0xFF1A1A1A),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide.none,
//               ),
//               contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//             ),
//             items:
//                 [
//                   const DropdownMenuItem<String?>(
//                     value: null,
//                     child: Text(
//                       'All departments',
//                       style: TextStyle(color: Colors.white70),
//                     ),
//                   ),
//                 ] +
//                 _deptList
//                     .map(
//                       (d) =>
//                           DropdownMenuItem<String?>(value: d, child: Text(d)),
//                     )
//                     .toList(),
//             onChanged: (v) {
//               setState(() => _selectedDept = v);
//               _applyFiltersAndSort();
//             },
//             hint: const Text('Department'),
//           ),
//         ),
//         constrainedDropdown(
//           width: 140,
//           child: DropdownButton<String>(
//             value: _statusFilter,
//             dropdownColor: const Color(0xFF1A1A1A),
//             underline: const SizedBox(),
//             items: const [
//               DropdownMenuItem(value: 'all', child: Text('All')),
//               DropdownMenuItem(value: 'checkedout', child: Text('Checked-out')),
//               DropdownMenuItem(value: 'pending', child: Text('Pending')),
//             ],
//             onChanged: (v) {
//               setState(() => _statusFilter = v ?? 'all');
//               _applyFiltersAndSort();
//             },
//           ),
//         ),
//         constrainedDropdown(
//           width: 160,
//           child: DropdownButton<String>(
//             value: _sortBy,
//             dropdownColor: const Color(0xFF1A1A1A),
//             underline: const SizedBox(),
//             items: const [
//               DropdownMenuItem(value: 'newest', child: Text('Newest')),
//               DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
//               DropdownMenuItem(value: 'name_asc', child: Text('Name A–Z')),
//               DropdownMenuItem(value: 'name_desc', child: Text('Name Z–A')),
//             ],
//             onChanged: (v) {
//               setState(() => _sortBy = v ?? 'newest');
//               _applyFiltersAndSort();
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildChipsAndCounts(String dateLabel) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Expanded(
//           child: Text(dateLabel, style: const TextStyle(color: Colors.white70)),
//         ),
//         const SizedBox(width: 12),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: const Color(0xFF2C2C3E),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             'Records: ${_filtered.length}',
//             style: const TextStyle(color: Colors.white70),
//           ),
//         ),
//       ],
//     );
//   }

//   // small shimmer placeholder
//   Widget _buildShimmer() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(12),
//       itemCount: 6,
//       itemBuilder: (context, i) {
//         return Container(
//           margin: const EdgeInsets.symmetric(vertical: 8),
//           height: 86,
//           decoration: BoxDecoration(
//             color: const Color(0xFF1A1A1A),
//             borderRadius: BorderRadius.circular(12),
//           ),
//         );
//       },
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

// class AdminAttendanceHistoryScreen extends StatefulWidget {
//   const AdminAttendanceHistoryScreen({super.key});

//   @override
//   State<AdminAttendanceHistoryScreen> createState() =>
//       _AdminAttendanceHistoryScreenState();
// }

// class _AdminAttendanceHistoryScreenState
//     extends State<AdminAttendanceHistoryScreen> {
//   // Data & caches
//   bool _isLoading = true;
//   List<Map<String, dynamic>> _allRecords = [];
//   List<Map<String, dynamic>> _filtered = [];

//   // filter controls
//   String? _selectedUser;
//   String? _selectedDept;
//   DateTime? _startDate;
//   DateTime? _endDate;
//   String _statusFilter = 'all'; // all / checkedout / pending
//   String _searchQuery = '';

//   // sort
//   String _sortBy = 'newest'; // newest, oldest, name_asc, name_desc

//   // pagination
//   static const int _pageSize = 25;
//   int _currentPage = 1;

//   // helper lists
//   List<String> _userList = [];
//   List<String> _deptList = [];

//   // export / busy state
//   bool _isExporting = false;

//   // theme colors
//   final Color _bg = const Color(0xFF0E0E10);
//   final Color _panel = const Color(0xFF151516);
//   final Color _card = const Color(0xFF171718);
//   final Color _deepPurple = const Color(0xFF4A148C);

//   @override
//   void initState() {
//     super.initState();
//     _fetchAttendanceHistory();
//   }

//   Future<void> _fetchAttendanceHistory() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final uri = Uri.parse(
//         "https://trainerattendence-backed.onrender.com/api/attendance/all",
//       );
//       final res = await http.get(uri);

//       if (res.statusCode == 200) {
//         final data = jsonDecode(res.body);
//         final List<Map<String, dynamic>> list = (data as List)
//             .map((e) => Map<String, dynamic>.from(e as Map))
//             .toList();

//         // Cache
//         _allRecords = list;

//         // build helper lists
//         final users = _allRecords
//             .map((e) => (e['userName'] ?? 'Unknown').toString())
//             .toSet()
//             .toList();
//         final depts = _allRecords
//             .map((e) => (e['department'] ?? 'Unknown').toString())
//             .toSet()
//             .toList();

//         users.sort();
//         depts.sort();

//         setState(() {
//           _userList = users.cast<String>();
//           _deptList = depts.cast<String>();
//         });

//         _applyFiltersAndSort();
//       } else {
//         if (kDebugMode) {
//           print('Attendance API failed: ${res.statusCode} ${res.body}');
//         }
//         setState(() {
//           _allRecords = [];
//           _filtered = [];
//         });
//       }
//     } catch (e) {
//       if (kDebugMode) print('Fetch error: $e');
//       setState(() {
//         _allRecords = [];
//         _filtered = [];
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   // ================== FILTER / SORT / PAGINATION ==================

//   void _applyFiltersAndSort() {
//     List<Map<String, dynamic>> list = List.from(_allRecords);

//     // Search
//     final q = _searchQuery.trim().toLowerCase();
//     if (q.isNotEmpty) {
//       list = list.where((r) {
//         final name = (r['userName'] ?? '').toString().toLowerCase();
//         final dept = (r['department'] ?? '').toString().toLowerCase();
//         final date = (r['checkInTime'] ?? '').toString().toLowerCase();
//         return name.contains(q) || dept.contains(q) || date.contains(q);
//       }).toList();
//     }

//     // user filter
//     if (_selectedUser != null && _selectedUser!.isNotEmpty) {
//       list = list.where((r) => (r['userName'] ?? '') == _selectedUser).toList();
//     }

//     // dept filter
//     if (_selectedDept != null && _selectedDept!.isNotEmpty) {
//       list = list
//           .where((r) => (r['department'] ?? '') == _selectedDept)
//           .toList();
//     }

//     // status filter
//     if (_statusFilter == 'checkedout') {
//       list = list.where((r) => r['checkOutTime'] != null).toList();
//     } else if (_statusFilter == 'pending') {
//       list = list.where((r) => r['checkOutTime'] == null).toList();
//     }

//     // date range
//     if (_startDate != null && _endDate != null) {
//       final start = DateTime(
//         _startDate!.year,
//         _startDate!.month,
//         _startDate!.day,
//       );
//       final end = DateTime(
//         _endDate!.year,
//         _endDate!.month,
//         _endDate!.day,
//         23,
//         59,
//         59,
//       );
//       list = list.where((r) {
//         final raw = r['checkInTime'];
//         if (raw == null) return false;
//         try {
//           final dt = DateTime.parse(raw.toString());
//           return (dt.isAfter(start) || dt.isAtSameMomentAs(start)) &&
//               (dt.isBefore(end) || dt.isAtSameMomentAs(end));
//         } catch (_) {
//           return false;
//         }
//       }).toList();
//     }

//     // sort
//     list.sort((a, b) {
//       switch (_sortBy) {
//         case 'oldest':
//           return _parseDate(
//             a['checkInTime'],
//           ).compareTo(_parseDate(b['checkInTime']));
//         case 'name_asc':
//           return (a['userName'] ?? '').toString().compareTo(
//             (b['userName'] ?? '').toString(),
//           );
//         case 'name_desc':
//           return (b['userName'] ?? '').toString().compareTo(
//             (a['userName'] ?? '').toString(),
//           );
//         case 'newest':
//         default:
//           return _parseDate(
//             b['checkInTime'],
//           ).compareTo(_parseDate(a['checkInTime']));
//       }
//     });

//     setState(() {
//       _filtered = list;
//       _currentPage = 1;
//     });
//   }

//   DateTime _parseDate(dynamic raw) {
//     if (raw == null) return DateTime.fromMillisecondsSinceEpoch(0);
//     try {
//       return DateTime.parse(raw.toString());
//     } catch (_) {
//       return DateTime.fromMillisecondsSinceEpoch(0);
//     }
//   }

//   List<Map<String, dynamic>> get _pagedList {
//     final start = 0;
//     final end = (_currentPage * _pageSize).clamp(0, _filtered.length);
//     return _filtered.sublist(start, end);
//   }

//   bool get _canLoadMore => _pagedList.length < _filtered.length;

//   void _loadMore() {
//     if (_canLoadMore) {
//       setState(() {
//         _currentPage++;
//       });
//     }
//   }

//   // ================== UI Helpers ==================

//   Future<void> _pickDateRange() async {
//     final now = DateTime.now();
//     final picked = await showDateRangePicker(
//       context: context,
//       firstDate: DateTime(now.year - 5),
//       lastDate: DateTime(now.year + 1),
//       initialDateRange: _startDate != null && _endDate != null
//           ? DateTimeRange(start: _startDate!, end: _endDate!)
//           : null,
//       builder: (context, child) {
//         // small themed picker
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.fromSwatch(
//               primarySwatch: Colors.deepPurple,
//               backgroundColor: _panel,
//               cardColor: _panel,
//             ).copyWith(secondary: _deepPurple),
//             dialogBackgroundColor: _panel,
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(foregroundColor: _deepPurple),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null) {
//       setState(() {
//         _startDate = picked.start;
//         _endDate = picked.end;
//       });
//       _applyFiltersAndSort();
//     }
//   }

//   void _clearFilters() {
//     setState(() {
//       _selectedUser = null;
//       _selectedDept = null;
//       _startDate = null;
//       _endDate = null;
//       _statusFilter = 'all';
//       _searchQuery = '';
//       _sortBy = 'newest';
//     });
//     _applyFiltersAndSort();
//   }

//   String _formatTimeOrNA(dynamic raw) {
//     if (raw == null) return 'N/A';
//     try {
//       final dt = DateTime.parse(raw.toString());
//       return DateFormat('hh:mm a').format(dt);
//     } catch (_) {
//       return raw.toString();
//     }
//   }

//   String _formatDateOnly(dynamic raw) {
//     if (raw == null) return 'N/A';
//     try {
//       final dt = DateTime.parse(raw.toString());
//       return DateFormat('dd MMM yyyy').format(dt);
//     } catch (_) {
//       return raw.toString();
//     }
//   }

//   Future<Directory> _getDownloadDir() async {
//     if (Platform.isAndroid) {
//       final candidate = Directory('/storage/emulated/0/Download');
//       if (await candidate.exists()) return candidate;
//       final ext = await getExternalStorageDirectory();
//       if (ext != null) return ext;
//     }
//     return getApplicationDocumentsDirectory();
//   }

//   // ================== EXPORT / SHARE ==================
//   Future<File?> _exportExcelFile({List<Map<String, dynamic>>? rows}) async {
//     final exportRows = rows ?? _filtered;

//     if (exportRows.isEmpty) {
//       if (mounted) {
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('No records to export')));
//       }
//       return null;
//     }

//     final excel = Excel.createExcel();
//     final Sheet sheet = excel['Sheet1'];

//     // Header (use TextCellValue to match excel package expectations)
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
//       final date = _formatDateOnly(r['checkInTime']);
//       final inTime = _formatTimeOrNA(r['checkInTime']);
//       final outTime = _formatTimeOrNA(r['checkOutTime']);
//       final durationVal = r['duration'];
//       final duration = durationVal != null ? durationVal.toString() : '-';

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
//         TextCellValue(duration),
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

//   Future<File?> _exportPdfFile({List<Map<String, dynamic>>? rows}) async {
//     final exportRows = rows ?? _filtered;
//     if (exportRows.isEmpty) {
//       if (mounted)
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('No records to export')));
//       return null;
//     }

//     final pdf = pw.Document();
//     final title = 'Attendance Report';
//     final period = (_startDate != null && _endDate != null)
//         ? '${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}'
//         : 'All Dates';

//     // Build table data ensuring addresses are single-line
//     final tableHeaders = [
//       'Name',
//       'Dept',
//       'Date',
//       'In',
//       'Out',
//       'Duration',
//       'In Addr',
//       'Out Addr',
//       'In Mode',
//       'Out Mode',
//     ];

//     final tableData = exportRows.map((r) {
//       final date = _formatDateOnly(r['checkInTime']);
//       final inTime = _formatTimeOrNA(r['checkInTime']);
//       final outTime = _formatTimeOrNA(r['checkOutTime']);
//       final dur = r['duration'] != null ? r['duration'].toString() : '-';
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
//         r['userName'] ?? '-',
//         r['department'] ?? '-',
//         date,
//         inTime,
//         outTime,
//         dur,
//         inAddr,
//         outAddr,
//         inMode,
//         outMode,
//       ];
//     }).toList();

//     pdf.addPage(
//       pw.MultiPage(
//         pageFormat: PdfPageFormat.a4,
//         build: (context) {
//           return [
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//               children: [
//                 pw.Text(
//                   title,
//                   style: pw.TextStyle(
//                     fontSize: 18,
//                     fontWeight: pw.FontWeight.bold,
//                   ),
//                 ),
//                 pw.Text(period, style: pw.TextStyle(fontSize: 10)),
//               ],
//             ),
//             pw.SizedBox(height: 12),
//             pw.Table.fromTextArray(
//               headers: tableHeaders,
//               data: tableData,
//               cellStyle: const pw.TextStyle(fontSize: 8),
//               headerStyle: pw.TextStyle(
//                 fontSize: 9,
//                 fontWeight: pw.FontWeight.bold,
//               ),
//               columnWidths: {
//                 0: pw.FlexColumnWidth(2),
//                 6: pw.FlexColumnWidth(3),
//                 7: pw.FlexColumnWidth(3),
//               },
//             ),
//             pw.SizedBox(height: 10),
//             pw.Row(
//               mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//               children: [
//                 pw.Text(
//                   'Total records: ${exportRows.length}',
//                   style: const pw.TextStyle(fontSize: 10),
//                 ),
//                 pw.Text(
//                   'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
//                   style: const pw.TextStyle(fontSize: 10),
//                 ),
//               ],
//             ),
//           ];
//         },
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

//   Future<void> _doExportExcel() async {
//     setState(() => _isExporting = true);
//     try {
//       final f = await _exportExcelFile();
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
//       if (mounted)
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Excel export failed: $e')));
//     } finally {
//       setState(() => _isExporting = false);
//     }
//   }

//   Future<void> _doExportPdf() async {
//     setState(() => _isExporting = true);
//     try {
//       final f = await _exportPdfFile();
//       if (f != null) {
//         await OpenFilex.open(f.path);
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text('PDF exported: ${f.path.split('/').last}')),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted)
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('PDF export failed: $e')));
//     } finally {
//       setState(() => _isExporting = false);
//     }
//   }

//   Future<void> _shareExcel() async {
//     setState(() => _isExporting = true);
//     try {
//       final f = await _exportExcelFile();
//       if (f != null) {
//         await Share.shareXFiles([XFile(f.path)], text: 'Attendance (Excel)');
//       }
//     } catch (e) {
//       if (mounted)
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
//     } finally {
//       setState(() => _isExporting = false);
//     }
//   }

//   Future<void> _sharePdf() async {
//     setState(() => _isExporting = true);
//     try {
//       final f = await _exportPdfFile();
//       if (f != null) {
//         await Share.shareXFiles([XFile(f.path)], text: 'Attendance (PDF)');
//       }
//     } catch (e) {
//       if (mounted)
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
//     } finally {
//       setState(() => _isExporting = false);
//     }
//   }

//   // ================== Build UI ==================
//   @override
//   Widget build(BuildContext context) {
//     final dateLabel = (_startDate != null && _endDate != null)
//         ? '${DateFormat('dd MMM yyyy').format(_startDate!)} → ${DateFormat('dd MMM yyyy').format(_endDate!)}'
//         : 'All dates';

//     return Scaffold(
//       backgroundColor: _bg,
//       appBar: AppBar(
//         title: const Text("Admin Attendance History"),
//         centerTitle: true,
//         elevation: 0,
//         flexibleSpace: Container(
//           decoration: BoxDecoration(
//             gradient: LinearGradient(
//               colors: [
//                 _deepPurple.withOpacity(0.95),
//                 _deepPurple.withOpacity(0.75),
//               ],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _fetchAttendanceHistory,
//             tooltip: 'Refresh',
//           ),
//           PopupMenuButton<String>(
//             onSelected: (s) {
//               if (s == 'exp_xlsx') _doExportExcel();
//               if (s == 'exp_pdf') _doExportPdf();
//               if (s == 'share_xlsx') _shareExcel();
//               if (s == 'share_pdf') _sharePdf();
//             },
//             itemBuilder: (_) => [
//               const PopupMenuItem(
//                 value: 'exp_xlsx',
//                 child: Text('Export Excel'),
//               ),
//               const PopupMenuItem(value: 'exp_pdf', child: Text('Export PDF')),
//               const PopupMenuDivider(),
//               const PopupMenuItem(
//                 value: 'share_xlsx',
//                 child: Text('Share Excel'),
//               ),
//               const PopupMenuItem(value: 'share_pdf', child: Text('Share PDF')),
//             ],
//             icon: const Icon(Icons.download),
//           ),
//         ],
//       ),
//       body: Column(
//         children: [
//           // Filters area (glass-like panel)
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(12),
//             color: _panel,
//             child: LayoutBuilder(
//               builder: (context, constraints) {
//                 final narrow = constraints.maxWidth < 800;
//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // search row
//                     Row(
//                       children: [
//                         Expanded(child: _buildSearchField()),
//                         const SizedBox(width: 8),
//                         IconButton(
//                           icon: const Icon(
//                             Icons.date_range,
//                             color: Colors.white,
//                           ),
//                           onPressed: _pickDateRange,
//                           tooltip: 'Date range',
//                         ),
//                         const SizedBox(width: 2),
//                         IconButton(
//                           icon: const Icon(
//                             Icons.filter_alt_off,
//                             color: Colors.white70,
//                           ),
//                           onPressed: _clearFilters,
//                           tooltip: 'Clear filters',
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),

//                     // second row (responsive)
//                     narrow
//                         ? Column(
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             children: [
//                               _buildDropdownsWrap(isNarrow: true),
//                               const SizedBox(height: 8),
//                               _buildChipsAndCounts(dateLabel),
//                             ],
//                           )
//                         : Row(
//                             children: [
//                               Expanded(
//                                 child: _buildDropdownsWrap(isNarrow: false),
//                               ),
//                               const SizedBox(width: 12),
//                               Expanded(child: _buildChipsAndCounts(dateLabel)),
//                             ],
//                           ),
//                   ],
//                 );
//               },
//             ),
//           ),

//           // content area
//           Expanded(
//             child: _isLoading
//                 ? _buildShimmer()
//                 : RefreshIndicator(
//                     onRefresh: _fetchAttendanceHistory,
//                     color: _deepPurple,
//                     child: _filtered.isEmpty
//                         ? ListView(
//                             children: [
//                               const SizedBox(height: 60),
//                               Center(
//                                 child: Text(
//                                   'No records found',
//                                   style: TextStyle(
//                                     color: Colors.white70.withOpacity(0.9),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           )
//                         : ListView.builder(
//                             padding: const EdgeInsets.all(12),
//                             itemCount:
//                                 _pagedList.length + (_canLoadMore ? 1 : 0),
//                             itemBuilder: (context, idx) {
//                               if (idx == _pagedList.length && _canLoadMore) {
//                                 return Center(
//                                   child: TextButton.icon(
//                                     onPressed: _loadMore,
//                                     icon: const Icon(Icons.expand_more),
//                                     label: const Text('Load more'),
//                                   ),
//                                 );
//                               }

//                               final r = _pagedList[idx];
//                               final name = (r['userName'] ?? 'Unknown')
//                                   .toString();
//                               final dept = (r['department'] ?? '-').toString();
//                               final checkIn = r['checkInTime'];
//                               final checkOut = r['checkOutTime'];
//                               final dateStr = _formatDateOnly(checkIn);
//                               final inTime = _formatTimeOrNA(checkIn);
//                               final outTime = _formatTimeOrNA(checkOut);
//                               final isPending = checkOut == null;
//                               final avatarUrl =
//                                   r['photoUrl'] ?? r['photo'] ?? null;

//                               return _AttCard(
//                                 name: name,
//                                 dept: dept,
//                                 dateStr: dateStr,
//                                 inTime: inTime,
//                                 outTime: outTime,
//                                 isPending: isPending,
//                                 avatarUrl: avatarUrl,
//                                 deepPurple: _deepPurple,
//                                 cardColor: _card,
//                               );
//                             },
//                           ),
//                   ),
//           ),
//         ],
//       ),

//       // busy overlay when exporting
//       floatingActionButton: _isExporting
//           ? FloatingActionButton(
//               onPressed: () {},
//               backgroundColor: Colors.grey,
//               child: const CircularProgressIndicator(color: Colors.white),
//             )
//           : null,
//     );
//   }

//   // Search field widget
//   Widget _buildSearchField() {
//     return TextField(
//       style: const TextStyle(color: Colors.white),
//       decoration: InputDecoration(
//         hintText: 'Search by name / dept / date',
//         hintStyle: TextStyle(color: Colors.white70.withOpacity(0.9)),
//         prefixIcon: const Icon(Icons.search, color: Colors.white70),
//         filled: true,
//         fillColor: const Color(0xFF1A1A1A),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide.none,
//         ),
//         contentPadding: const EdgeInsets.symmetric(vertical: 12),
//       ),
//       onChanged: (v) {
//         _searchQuery = v;
//         _applyFiltersAndSort();
//       },
//     );
//   }

//   // Build dropdowns as a single row / column depending on width
//   Widget _buildDropdownsWrap({required bool isNarrow}) {
//     // Constrain each dropdown so they don't overflow horizontally
//     Widget constrainedDropdown({required Widget child, double? width}) {
//       if (isNarrow) {
//         return Padding(padding: const EdgeInsets.only(bottom: 8), child: child);
//       }
//       return ConstrainedBox(
//         constraints: BoxConstraints(minWidth: 120, maxWidth: width ?? 220),
//         child: Padding(padding: const EdgeInsets.only(right: 8), child: child),
//       );
//     }

//     return Wrap(
//       spacing: 8,
//       runSpacing: 8,
//       children: [
//         constrainedDropdown(
//           width: 260,
//           child: DropdownButtonFormField<String?>(
//             value: _selectedUser,
//             isExpanded: true,
//             dropdownColor: const Color(0xFF1A1A1A),
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: const Color(0xFF1A1A1A),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide.none,
//               ),
//               contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//             ),
//             items:
//                 [
//                   const DropdownMenuItem<String?>(
//                     value: null,
//                     child: Text(
//                       'All users',
//                       style: TextStyle(color: Colors.white70),
//                     ),
//                   ),
//                 ] +
//                 _userList
//                     .map(
//                       (u) => DropdownMenuItem<String?>(
//                         value: u,
//                         child: Text(
//                           u,
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     )
//                     .toList(),
//             onChanged: (v) {
//               setState(() => _selectedUser = v);
//               _applyFiltersAndSort();
//             },
//             hint: const Text('User'),
//             style: const TextStyle(color: Colors.white),
//           ),
//         ),
//         constrainedDropdown(
//           width: 220,
//           child: DropdownButtonFormField<String?>(
//             value: _selectedDept,
//             isExpanded: true,
//             dropdownColor: const Color(0xFF1A1A1A),
//             decoration: InputDecoration(
//               filled: true,
//               fillColor: const Color(0xFF1A1A1A),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8),
//                 borderSide: BorderSide.none,
//               ),
//               contentPadding: const EdgeInsets.symmetric(horizontal: 12),
//             ),
//             items:
//                 [
//                   const DropdownMenuItem<String?>(
//                     value: null,
//                     child: Text(
//                       'All departments',
//                       style: TextStyle(color: Colors.white70),
//                     ),
//                   ),
//                 ] +
//                 _deptList
//                     .map(
//                       (d) => DropdownMenuItem<String?>(
//                         value: d,
//                         child: Text(
//                           d,
//                           style: const TextStyle(color: Colors.white),
//                         ),
//                       ),
//                     )
//                     .toList(),
//             onChanged: (v) {
//               setState(() => _selectedDept = v);
//               _applyFiltersAndSort();
//             },
//             hint: const Text('Department'),
//             style: const TextStyle(color: Colors.white),
//           ),
//         ),
//         constrainedDropdown(
//           width: 140,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             decoration: BoxDecoration(
//               color: const Color(0xFF1A1A1A),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: DropdownButton<String>(
//               value: _statusFilter,
//               dropdownColor: const Color(0xFF1A1A1A),
//               underline: const SizedBox(),
//               style: const TextStyle(color: Colors.white),
//               items: const [
//                 DropdownMenuItem(value: 'all', child: Text('All')),
//                 DropdownMenuItem(
//                   value: 'checkedout',
//                   child: Text('Checked-out'),
//                 ),
//                 DropdownMenuItem(value: 'pending', child: Text('Pending')),
//               ],
//               onChanged: (v) {
//                 setState(() => _statusFilter = v ?? 'all');
//                 _applyFiltersAndSort();
//               },
//             ),
//           ),
//         ),
//         constrainedDropdown(
//           width: 160,
//           child: Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8),
//             decoration: BoxDecoration(
//               color: const Color(0xFF1A1A1A),
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: DropdownButton<String>(
//               value: _sortBy,
//               dropdownColor: const Color(0xFF1A1A1A),
//               underline: const SizedBox(),
//               style: const TextStyle(color: Colors.white),
//               items: const [
//                 DropdownMenuItem(value: 'newest', child: Text('Newest')),
//                 DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
//                 DropdownMenuItem(value: 'name_asc', child: Text('Name A–Z')),
//                 DropdownMenuItem(value: 'name_desc', child: Text('Name Z–A')),
//               ],
//               onChanged: (v) {
//                 setState(() => _sortBy = v ?? 'newest');
//                 _applyFiltersAndSort();
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildChipsAndCounts(String dateLabel) {
//     return Row(
//       children: [
//         Expanded(
//           child: Text(dateLabel, style: const TextStyle(color: Colors.white70)),
//         ),
//         const SizedBox(width: 12),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: const Color(0xFF2C2C3E),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             'Records: ${_filtered.length}',
//             style: const TextStyle(color: Colors.white70),
//           ),
//         ),
//       ],
//     );
//   }

//   // small shimmer placeholder
//   Widget _buildShimmer() {
//     return ListView.builder(
//       padding: const EdgeInsets.all(12),
//       itemCount: 6,
//       itemBuilder: (context, i) {
//         return Container(
//           margin: const EdgeInsets.symmetric(vertical: 8),
//           height: 86,
//           decoration: BoxDecoration(
//             color: const Color(0xFF1A1A1A),
//             borderRadius: BorderRadius.circular(12),
//           ),
//         );
//       },
//     );
//   }
// }

// // small reusable attendance card widget (clean + glassy)
// class _AttCard extends StatelessWidget {
//   final String name;
//   final String dept;
//   final String dateStr;
//   final String inTime;
//   final String outTime;
//   final bool isPending;
//   final String? avatarUrl;
//   final Color deepPurple;
//   final Color cardColor;

//   const _AttCard({
//     required this.name,
//     required this.dept,
//     required this.dateStr,
//     required this.inTime,
//     required this.outTime,
//     required this.isPending,
//     required this.avatarUrl,
//     required this.deepPurple,
//     required this.cardColor,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // glass-like container with subtle elevation
//     return Card(
//       color: cardColor.withOpacity(0.98),
//       margin: const EdgeInsets.symmetric(vertical: 6),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
//         child: ListTile(
//           leading: CircleAvatar(
//             radius: 26,
//             backgroundColor: isPending ? Colors.orange : Colors.green,
//             backgroundImage: avatarUrl != null
//                 ? NetworkImage(avatarUrl!)
//                 : null,
//             child: avatarUrl == null
//                 ? const Icon(Icons.person, color: Colors.white)
//                 : null,
//           ),
//           title: Row(
//             children: [
//               Expanded(
//                 child: Text(
//                   name,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: isPending ? Colors.orange : Colors.green,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Text(
//                   isPending ? 'Pending' : 'Checked Out',
//                   style: const TextStyle(color: Colors.white, fontSize: 12),
//                 ),
//               ),
//             ],
//           ),
//           subtitle: Padding(
//             padding: const EdgeInsets.only(top: 8.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Dept: $dept',
//                   style: const TextStyle(color: Colors.white70),
//                 ),
//                 const SizedBox(height: 8),
//                 Wrap(
//                   spacing: 8,
//                   runSpacing: 6,
//                   children: [
//                     _InfoChip(icon: Icons.calendar_today, label: dateStr),
//                     _InfoChip(
//                       icon: Icons.login,
//                       label: inTime,
//                       color: Colors.greenAccent,
//                     ),
//                     _InfoChip(
//                       icon: Icons.logout,
//                       label: outTime,
//                       color: isPending ? Colors.orangeAccent : Colors.redAccent,
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//           isThreeLine: true,
//         ),
//       ),
//     );
//   }
// }

// class _InfoChip extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color? color;
//   const _InfoChip({required this.icon, required this.label, this.color});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       constraints: const BoxConstraints(minWidth: 60, maxWidth: 220),
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
//       decoration: BoxDecoration(
//         color: Color(0xFF1C1C1C),
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.white.withOpacity(0.03)),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 14, color: color ?? Colors.white70),
//           const SizedBox(width: 6),
//           Flexible(
//             child: Text(
//               label,
//               overflow: TextOverflow.ellipsis,
//               style: TextStyle(color: color ?? Colors.white70),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// Full updated file — drop-in replacement for your AdminAttendanceHistoryScreen.dart

import 'dart:convert';
import 'dart:io';

import 'package:excel/excel.dart' hide Border;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class AdminAttendanceHistoryScreen extends StatefulWidget {
  const AdminAttendanceHistoryScreen({super.key});

  @override
  State<AdminAttendanceHistoryScreen> createState() =>
      _AdminAttendanceHistoryScreenState();
}

class _AdminAttendanceHistoryScreenState
    extends State<AdminAttendanceHistoryScreen> {
  // Data & caches
  bool _isLoading = true;
  List<Map<String, dynamic>> _allRecords = [];
  List<Map<String, dynamic>> _filtered = [];

  // filter controls
  String? _selectedUser;
  String? _selectedDept;
  DateTime? _startDate;
  DateTime? _endDate;
  String _statusFilter = 'all'; // all / checkedout / pending
  String _searchQuery = '';

  // sort
  String _sortBy = 'newest'; // newest, oldest, name_asc, name_desc

  // pagination
  static const int _pageSize = 25;
  int _currentPage = 1;

  // helper lists
  List<String> _userList = [];
  List<String> _deptList = [];

  // export / busy state
  bool _isExporting = false;

  // theme colors
  final Color _bg = const Color(0xFF0E0E10);
  final Color _panel = const Color(0xFF151516);
  final Color _card = const Color(0xFF171718);
  final Color _deepPurple = const Color(0xFF4A148C);

  @override
  void initState() {
    super.initState();
    _fetchAttendanceHistory();
  }

  // ---------- Safe setState helper ----------
  void _safeSetState(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
  }

  Future<void> _fetchAttendanceHistory() async {
    _safeSetState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse(
        "https://trainerattendence-backed.onrender.com/api/attendance/all",
      );
      final res = await http.get(uri);

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final List<Map<String, dynamic>> list = (data as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();

        // Cache
        _allRecords = list;

        // build helper lists
        final users = _allRecords
            .map((e) => (e['userName'] ?? 'Unknown').toString())
            .toSet()
            .toList();
        final depts = _allRecords
            .map((e) => (e['department'] ?? 'Unknown').toString())
            .toSet()
            .toList();

        users.sort();
        depts.sort();

        _safeSetState(() {
          _userList = users.cast<String>();
          _deptList = depts.cast<String>();
        });

        _applyFiltersAndSort();
      } else {
        if (kDebugMode) {
          print('Attendance API failed: ${res.statusCode} ${res.body}');
        }
        _safeSetState(() {
          _allRecords = [];
          _filtered = [];
        });
      }
    } catch (e) {
      if (kDebugMode) print('Fetch error: $e');
      _safeSetState(() {
        _allRecords = [];
        _filtered = [];
      });
    } finally {
      _safeSetState(() {
        _isLoading = false;
      });
    }
  }

  // ================== FILTER / SORT / PAGINATION ==================

  void _applyFiltersAndSort() {
    List<Map<String, dynamic>> list = List.from(_allRecords);

    // Search
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((r) {
        final name = (r['userName'] ?? '').toString().toLowerCase();
        final dept = (r['department'] ?? '').toString().toLowerCase();
        final date = (r['checkInTime'] ?? '').toString().toLowerCase();
        return name.contains(q) || dept.contains(q) || date.contains(q);
      }).toList();
    }

    // user filter
    if (_selectedUser != null && _selectedUser!.isNotEmpty) {
      list = list.where((r) => (r['userName'] ?? '') == _selectedUser).toList();
    }

    // dept filter
    if (_selectedDept != null && _selectedDept!.isNotEmpty) {
      list = list
          .where((r) => (r['department'] ?? '') == _selectedDept)
          .toList();
    }

    // status filter
    if (_statusFilter == 'checkedout') {
      list = list.where((r) => r['checkOutTime'] != null).toList();
    } else if (_statusFilter == 'pending') {
      list = list.where((r) => r['checkOutTime'] == null).toList();
    }

    // date range
    if (_startDate != null && _endDate != null) {
      final start = DateTime(
        _startDate!.year,
        _startDate!.month,
        _startDate!.day,
      );
      final end = DateTime(
        _endDate!.year,
        _endDate!.month,
        _endDate!.day,
        23,
        59,
        59,
      );
      list = list.where((r) {
        final raw = r['checkInTime'];
        if (raw == null) return false;
        try {
          final dt = DateTime.parse(raw.toString());
          return (dt.isAfter(start) || dt.isAtSameMomentAs(start)) &&
              (dt.isBefore(end) || dt.isAtSameMomentAs(end));
        } catch (_) {
          return false;
        }
      }).toList();
    }

    // sort
    list.sort((a, b) {
      switch (_sortBy) {
        case 'oldest':
          return _parseDate(
            a['checkInTime'],
          ).compareTo(_parseDate(b['checkInTime']));
        case 'name_asc':
          return (a['userName'] ?? '').toString().compareTo(
            (b['userName'] ?? '').toString(),
          );
        case 'name_desc':
          return (b['userName'] ?? '').toString().compareTo(
            (a['userName'] ?? '').toString(),
          );
        case 'newest':
        default:
          return _parseDate(
            b['checkInTime'],
          ).compareTo(_parseDate(a['checkInTime']));
      }
    });

    _safeSetState(() {
      _filtered = list;
      _currentPage = 1;
    });
  }

  DateTime _parseDate(dynamic raw) {
    if (raw == null) return DateTime.fromMillisecondsSinceEpoch(0);
    try {
      return DateTime.parse(raw.toString());
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }

  /// Compute a Duration for an attendance record:
  /// - prefer explicit `duration` if it's an int (seconds) or string of minutes/hours,
  /// - else compute from checkIn/checkOut timestamps.
  Duration _computeDurationFromRecord(Map<String, dynamic> r) {
    try {
      final dRaw = r['duration'];
      if (dRaw != null) {
        // If it's already an int or double (seconds/minutes), try to convert
        if (dRaw is int) return Duration(minutes: dRaw);
        if (dRaw is double) return Duration(minutes: dRaw.toInt());
        if (dRaw is String) {
          // try formats like "1:30" (hours:minutes) or "90" as minutes
          if (dRaw.contains(':')) {
            final parts = dRaw
                .split(':')
                .map((s) => int.tryParse(s) ?? 0)
                .toList();
            if (parts.length == 2) {
              return Duration(hours: parts[0], minutes: parts[1]);
            }
          } else {
            final mins = int.tryParse(dRaw);
            if (mins != null) return Duration(minutes: mins);
          }
        }
      }

      final inRaw = r['checkInTime'];
      final outRaw = r['checkOutTime'];
      if (inRaw == null || outRaw == null) return Duration.zero;
      final dtIn = DateTime.parse(inRaw.toString());
      final dtOut = DateTime.parse(outRaw.toString());
      if (dtOut.isBefore(dtIn)) return Duration.zero;
      return dtOut.difference(dtIn);
    } catch (_) {
      return Duration.zero;
    }
  }

  List<Map<String, dynamic>> get _pagedList {
    final start = 0;
    final end = (_currentPage * _pageSize).clamp(0, _filtered.length);
    return _filtered.sublist(start, end);
  }

  bool get _canLoadMore => _pagedList.length < _filtered.length;

  void _loadMore() {
    if (_canLoadMore) {
      _safeSetState(() {
        _currentPage++;
      });
    }
  }

  // ================== UI Helpers ==================

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
      builder: (context, child) {
        // small themed picker
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSwatch(
              primarySwatch: Colors.deepPurple,
              backgroundColor: _panel,
              cardColor: _panel,
            ).copyWith(secondary: _deepPurple),
            dialogBackgroundColor: _panel,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: _deepPurple),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      _safeSetState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _applyFiltersAndSort();
    }
  }

  void _clearFilters() {
    _safeSetState(() {
      _selectedUser = null;
      _selectedDept = null;
      _startDate = null;
      _endDate = null;
      _statusFilter = 'all';
      _searchQuery = '';
      _sortBy = 'newest';
    });
    _applyFiltersAndSort();
  }

  String _formatTimeOrNA(dynamic raw) {
    if (raw == null) return 'N/A';
    try {
      final dt = DateTime.parse(raw.toString());
      return DateFormat('hh:mm a').format(dt);
    } catch (_) {
      return raw.toString();
    }
  }

  String _formatDateOnly(dynamic raw) {
    if (raw == null) return 'N/A';
    try {
      final dt = DateTime.parse(raw.toString());
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return raw.toString();
    }
  }

  Future<Directory> _getDownloadDir() async {
    if (Platform.isAndroid) {
      final candidate = Directory('/storage/emulated/0/Download');
      if (await candidate.exists()) return candidate;
      final ext = await getExternalStorageDirectory();
      if (ext != null) return ext;
    }
    return getApplicationDocumentsDirectory();
  }

  // ================== EXPORT / SHARE ==================
  Future<File?> _exportExcelFile({List<Map<String, dynamic>>? rows}) async {
    final exportRows = rows ?? _filtered;

    if (exportRows.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No records to export')));
      }
      return null;
    }

    final excel = Excel.createExcel();
    // Use or create a sheet
    final String sheetName = 'Attendance';
    final Sheet sheet = excel[sheetName];

    // Header row
    sheet.appendRow([
      TextCellValue('Name'),
      TextCellValue('Department'),
      TextCellValue('Date'),
      TextCellValue('Check-In Time'),
      TextCellValue('Check-Out Time'),
      TextCellValue('Duration (h:m)'),
      TextCellValue('Check-In Address'),
      TextCellValue('Check-Out Address'),
      TextCellValue('Check-In Mode'),
      TextCellValue('Check-Out Mode'),
    ]);

    for (final r in exportRows) {
      final date = _formatDateOnly(r['checkInTime']);
      final inTime = _formatTimeOrNA(r['checkInTime']);
      final outTime = _formatTimeOrNA(r['checkOutTime']);

      // compute duration as h:mm
      final dur = _computeDurationFromRecord(r);
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

      final inMode = (r['checkInMode'] == true) ? 'Online' : 'Offline';
      final outMode = (r['checkOutMode'] == true) ? 'Online' : 'Offline';

      sheet.appendRow([
        TextCellValue(r['userName'] ?? '-'),
        TextCellValue(r['department'] ?? '-'),
        TextCellValue(date),
        TextCellValue(inTime),
        TextCellValue(outTime),
        TextCellValue(durStr),
        TextCellValue(inAddr),
        TextCellValue(outAddr),
        TextCellValue(inMode),
        TextCellValue(outMode),
      ]);
    }

    final bytes = excel.encode();
    if (bytes == null) return null;

    final fileName =
        'attendance_export_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.xlsx';

    final dir = await _getDownloadDir();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);

    return file;
  }

  // Future<File?> _exportPdfFile({List<Map<String, dynamic>>? rows}) async {
  //   final exportRows = rows ?? _filtered;
  //   if (exportRows.isEmpty) {
  //     if (mounted)
  //       ScaffoldMessenger.of(
  //         context,
  //       ).showSnackBar(const SnackBar(content: Text('No records to export')));
  //     return null;
  //   }

  //   final pdf = pw.Document();
  //   final title = 'Attendance Report';
  //   final period = (_startDate != null && _endDate != null)
  //       ? '${DateFormat('dd MMM yyyy').format(_startDate!)} - ${DateFormat('dd MMM yyyy').format(_endDate!)}'
  //       : 'All Dates';

  //   // Prepare table data with computed durations and single-line addresses
  //   final tableHeaders = [
  //     'Name',
  //     'Dept',
  //     'Date',
  //     'In',
  //     'Out',
  //     'Duration',
  //     'In Addr',
  //     'Out Addr',
  //     'In Mode',
  //     'Out Mode',
  //   ];

  //   final tableData = exportRows.map((r) {
  //     final date = _formatDateOnly(r['checkInTime']);
  //     final inTime = _formatTimeOrNA(r['checkInTime']);
  //     final outTime = _formatTimeOrNA(r['checkOutTime']);

  //     final dur = _computeDurationFromRecord(r);
  //     final durStr = dur == Duration.zero
  //         ? '-'
  //         : '${dur.inHours}h ${dur.inMinutes.remainder(60)}m';

  //     final inAddr = (r['checkInAddress'] ?? '-').toString().replaceAll(
  //       '\n',
  //       ' ',
  //     );
  //     final outAddr = (r['checkOutAddress'] ?? '-').toString().replaceAll(
  //       '\n',
  //       ' ',
  //     );

  //     final inMode = (r['checkInMode'] == true) ? 'Online' : 'Offline';
  //     final outMode = (r['checkOutMode'] == true) ? 'Online' : 'Offline';

  //     return [
  //       r['userName'] ?? '-',
  //       r['department'] ?? '-',
  //       date,
  //       inTime,
  //       outTime,
  //       durStr,
  //       inAddr,
  //       outAddr,
  //       inMode,
  //       outMode,
  //     ];
  //   }).toList();

  //   pdf.addPage(
  //     pw.MultiPage(
  //       pageFormat: PdfPageFormat.a4,
  //       build: (context) {
  //         return [
  //           pw.Row(
  //             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //             children: [
  //               pw.Text(
  //                 title,
  //                 style: pw.TextStyle(
  //                   fontSize: 18,
  //                   fontWeight: pw.FontWeight.bold,
  //                 ),
  //               ),
  //               pw.Text(period, style: pw.TextStyle(fontSize: 10)),
  //             ],
  //           ),
  //           pw.SizedBox(height: 12),
  //           pw.Table.fromTextArray(
  //             headers: tableHeaders,
  //             data: tableData,
  //             cellStyle: const pw.TextStyle(fontSize: 8),
  //             headerStyle: pw.TextStyle(
  //               fontSize: 9,
  //               fontWeight: pw.FontWeight.bold,
  //             ),
  //             columnWidths: {
  //               0: pw.FlexColumnWidth(2),
  //               6: pw.FlexColumnWidth(3),
  //               7: pw.FlexColumnWidth(3),
  //             },
  //           ),
  //           pw.SizedBox(height: 10),
  //           pw.Row(
  //             mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
  //             children: [
  //               pw.Text(
  //                 'Total records: ${exportRows.length}',
  //                 style: const pw.TextStyle(fontSize: 10),
  //               ),
  //               pw.Text(
  //                 'Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}',
  //                 style: const pw.TextStyle(fontSize: 10),
  //               ),
  //             ],
  //           ),
  //         ];
  //       },
  //     ),
  //   );

  //   final bytes = await pdf.save();
  //   final fileName =
  //       'attendance_export_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';
  //   final dir = await _getDownloadDir();
  //   final file = File('${dir.path}/$fileName');
  //   await file.writeAsBytes(bytes, flush: true);
  //   return file;
  // }

  Future<File?> _exportPdfFile({List<Map<String, dynamic>>? rows}) async {
    final exportRows = rows ?? _filtered;
    if (exportRows.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No records to export')));
      }
      return null;
    }

    final pdf = pw.Document();

    // ------------------------------------
    // Compute Total Duration
    // ------------------------------------
    Duration totalDuration = Duration.zero;
    for (var r in exportRows) {
      totalDuration += _computeDurationFromRecord(r);
    }

    String formatTotal(Duration d) => "${d.inHours}h ${d.inMinutes % 60}m";

    String formatDuration(Duration d) =>
        "${d.inHours}h ${d.inMinutes.remainder(60)}m";

    // Title + period
    final period = (_startDate != null && _endDate != null)
        ? "From ${DateFormat('dd MMM yyyy').format(_startDate!)} "
              "to ${DateFormat('dd MMM yyyy').format(_endDate!)}"
        : "All Dates";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            "Page ${context.pageNumber} of ${context.pagesCount}",
            style: const pw.TextStyle(fontSize: 10),
          ),
        ),
        build: (context) => [
          // -------------------
          // HEADER SECTION
          // -------------------
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                "ATTENDANCE REPORT",
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.deepPurple,
                ),
              ),
            ],
          ),

          pw.SizedBox(height: 8),
          pw.Text(
            "Admin Export",
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),

          pw.Text(period, style: pw.TextStyle(fontSize: 11)),

          pw.SizedBox(height: 16),

          // -------------------
          // SUMMARY BOX
          // -------------------
          pw.Container(
            padding: const pw.EdgeInsets.all(10),
            decoration: pw.BoxDecoration(
              borderRadius: pw.BorderRadius.circular(8),
              color: PdfColors.deepPurple50,
              border: pw.Border.all(color: PdfColors.deepPurple, width: 1),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  "Total Records: ${exportRows.length}",
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.Text(
                  "Total Hours: ${formatTotal(totalDuration)}",
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.deepPurple,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 16),

          // -------------------
          // TABLE
          // -------------------
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.4), // Name
              1: const pw.FlexColumnWidth(1.2), // Dept
              2: const pw.FlexColumnWidth(1.2), // Date
              3: const pw.FlexColumnWidth(1), // In
              4: const pw.FlexColumnWidth(1), // Out
              5: const pw.FlexColumnWidth(1.2), // Duration
              6: const pw.FlexColumnWidth(2), // In Addr
              7: const pw.FlexColumnWidth(2), // Out Addr
              8: const pw.FlexColumnWidth(1), // In Mode
              9: const pw.FlexColumnWidth(1), // Out Mode
            },
            children: [
              // TABLE HEADER
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  _pdfHeaderCell("Name"),
                  _pdfHeaderCell("Dept"),
                  _pdfHeaderCell("Date"),
                  _pdfHeaderCell("In"),
                  _pdfHeaderCell("Out"),
                  _pdfHeaderCell("Duration"),
                  _pdfHeaderCell("In Address"),
                  _pdfHeaderCell("Out Address"),
                  _pdfHeaderCell("In Mode"),
                  _pdfHeaderCell("Out Mode"),
                ],
              ),

              // TABLE DATA
              ...exportRows.map((r) {
                final dateStr = _formatDateOnly(r["checkInTime"]);
                final inTime = _formatTimeOrNA(r["checkInTime"]);
                final outTime = _formatTimeOrNA(r["checkOutTime"]);
                final dur = _computeDurationFromRecord(r);

                final inAddr = (r["checkInAddress"] ?? "-")
                    .toString()
                    .replaceAll("\n", " ");
                final outAddr = (r["checkOutAddress"] ?? "-")
                    .toString()
                    .replaceAll("\n", " ");

                return pw.TableRow(
                  children: [
                    _pdfCell(r["userName"] ?? "-"),
                    _pdfCell(r["department"] ?? "-"),
                    _pdfCell(dateStr),
                    _pdfCell(inTime),
                    _pdfCell(outTime),
                    _pdfCell(formatDuration(dur)),
                    _pdfCell(inAddr),
                    _pdfCell(outAddr),
                    _pdfCell(r["checkInMode"] == true ? "Online" : "Offline"),
                    _pdfCell(r["checkOutMode"] == true ? "Online" : "Offline"),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );

    final fileName =
        'attendance_export_${DateFormat('yyyyMMdd_HHmm').format(DateTime.now())}.pdf';
    final dir = await _getDownloadDir();
    final file = File("${dir.path}/$fileName");
    await file.writeAsBytes(await pdf.save(), flush: true);

    return file;
  }

  // Small helpers used above
  pw.Widget _pdfHeaderCell(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
  );

  pw.Widget _pdfCell(String text) => pw.Padding(
    padding: const pw.EdgeInsets.all(6),
    child: pw.Text(text, maxLines: 3),
  );

  Future<void> _doExportExcel() async {
    _safeSetState(() => _isExporting = true);
    try {
      final f = await _exportExcelFile();
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
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Excel export failed: $e')));
      }
    } finally {
      _safeSetState(() => _isExporting = false);
    }
  }

  Future<void> _doExportPdf() async {
    _safeSetState(() => _isExporting = true);
    try {
      final f = await _exportPdfFile();
      if (f != null) {
        await OpenFilex.open(f.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('PDF exported: ${f.path.split('/').last}')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('PDF export failed: $e')));
      }
    } finally {
      _safeSetState(() => _isExporting = false);
    }
  }

  Future<void> _shareExcel() async {
    _safeSetState(() => _isExporting = true);
    try {
      final f = await _exportExcelFile();
      if (f != null) {
        await Share.shareXFiles([XFile(f.path)], text: 'Attendance (Excel)');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
      }
    } finally {
      _safeSetState(() => _isExporting = false);
    }
  }

  Future<void> _sharePdf() async {
    _safeSetState(() => _isExporting = true);
    try {
      final f = await _exportPdfFile();
      if (f != null) {
        await Share.shareXFiles([XFile(f.path)], text: 'Attendance (PDF)');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Share failed: $e')));
      }
    } finally {
      _safeSetState(() => _isExporting = false);
    }
  }

  // ================== Build UI ==================
  @override
  Widget build(BuildContext context) {
    final dateLabel = (_startDate != null && _endDate != null)
        ? '${DateFormat('dd MMM yyyy').format(_startDate!)} → ${DateFormat('dd MMM yyyy').format(_endDate!)}'
        : 'All dates';

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        title: const Text("Admin Attendance History"),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _deepPurple.withOpacity(0.95),
                _deepPurple.withOpacity(0.75),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAttendanceHistory,
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: (s) {
              if (s == 'exp_xlsx') _doExportExcel();
              if (s == 'exp_pdf') _doExportPdf();
              if (s == 'share_xlsx') _shareExcel();
              if (s == 'share_pdf') _sharePdf();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'exp_xlsx',
                child: Text('Export Excel'),
              ),
              const PopupMenuItem(value: 'exp_pdf', child: Text('Export PDF')),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'share_xlsx',
                child: Text('Share Excel'),
              ),
              const PopupMenuItem(value: 'share_pdf', child: Text('Share PDF')),
            ],
            icon: const Icon(Icons.download),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters area (glass-like panel)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: _panel,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final narrow = constraints.maxWidth < 800;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // search row
                    Row(
                      children: [
                        Expanded(child: _buildSearchField()),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.date_range,
                            color: Colors.white,
                          ),
                          onPressed: _pickDateRange,
                          tooltip: 'Date range',
                        ),
                        const SizedBox(width: 2),
                        IconButton(
                          icon: const Icon(
                            Icons.filter_alt_off,
                            color: Colors.white70,
                          ),
                          onPressed: _clearFilters,
                          tooltip: 'Clear filters',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // second row (responsive)
                    narrow
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildDropdownsWrap(isNarrow: true),
                              const SizedBox(height: 8),
                              _buildChipsAndCounts(dateLabel),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: _buildDropdownsWrap(isNarrow: false),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: _buildChipsAndCounts(dateLabel)),
                            ],
                          ),
                  ],
                );
              },
            ),
          ),

          // content area
          Expanded(
            child: _isLoading
                ? _buildShimmer()
                : RefreshIndicator(
                    onRefresh: _fetchAttendanceHistory,
                    color: _deepPurple,
                    child: _filtered.isEmpty
                        ? ListView(
                            children: [
                              const SizedBox(height: 60),
                              Center(
                                child: Text(
                                  'No records found',
                                  style: TextStyle(
                                    color: Colors.white70.withOpacity(0.9),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount:
                                _pagedList.length + (_canLoadMore ? 1 : 0),
                            itemBuilder: (context, idx) {
                              if (idx == _pagedList.length && _canLoadMore) {
                                return Center(
                                  child: TextButton.icon(
                                    onPressed: _loadMore,
                                    icon: const Icon(Icons.expand_more),
                                    label: const Text('Load more'),
                                  ),
                                );
                              }

                              final r = _pagedList[idx];
                              final name = (r['userName'] ?? 'Unknown')
                                  .toString();
                              final dept = (r['department'] ?? '-').toString();
                              final checkIn = r['checkInTime'];
                              final checkOut = r['checkOutTime'];
                              final dateStr = _formatDateOnly(checkIn);
                              final inTime = _formatTimeOrNA(checkIn);
                              final outTime = _formatTimeOrNA(checkOut);
                              final isPending = checkOut == null;
                              final avatarUrl =
                                  r['photoUrl'] ?? r['photo'] ?? null;

                              return _AttCard(
                                name: name,
                                dept: dept,
                                dateStr: dateStr,
                                inTime: inTime,
                                outTime: outTime,
                                isPending: isPending,
                                avatarUrl: avatarUrl,
                                deepPurple: _deepPurple,
                                cardColor: _card,
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),

      // busy overlay when exporting
      floatingActionButton: _isExporting
          ? FloatingActionButton(
              onPressed: () {},
              backgroundColor: Colors.grey,
              child: const CircularProgressIndicator(color: Colors.white),
            )
          : null,
    );
  }

  // Search field widget
  Widget _buildSearchField() {
    return TextField(
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: 'Search by name / dept / date',
        hintStyle: TextStyle(color: Colors.white70.withOpacity(0.9)),
        prefixIcon: const Icon(Icons.search, color: Colors.white70),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onChanged: (v) {
        _searchQuery = v;
        _applyFiltersAndSort();
      },
    );
  }

  // Build dropdowns as a single row / column depending on width
  Widget _buildDropdownsWrap({required bool isNarrow}) {
    // Constrain each dropdown so they don't overflow horizontally
    Widget constrainedDropdown({required Widget child, double? width}) {
      if (isNarrow) {
        return Padding(padding: const EdgeInsets.only(bottom: 8), child: child);
      }
      return ConstrainedBox(
        constraints: BoxConstraints(minWidth: 120, maxWidth: width ?? 220),
        child: Padding(padding: const EdgeInsets.only(right: 8), child: child),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        constrainedDropdown(
          width: 260,
          child: DropdownButtonFormField<String?>(
            value: _selectedUser,
            isExpanded: true,
            dropdownColor: const Color(0xFF1A1A1A),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            items:
                [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      'All users',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ] +
                _userList
                    .map(
                      (u) => DropdownMenuItem<String?>(
                        value: u,
                        child: Text(
                          u,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (v) {
              _safeSetState(() => _selectedUser = v);
              _applyFiltersAndSort();
            },
            hint: const Text('User'),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        constrainedDropdown(
          width: 220,
          child: DropdownButtonFormField<String?>(
            value: _selectedDept,
            isExpanded: true,
            dropdownColor: const Color(0xFF1A1A1A),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF1A1A1A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            items:
                [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text(
                      'All departments',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ] +
                _deptList
                    .map(
                      (d) => DropdownMenuItem<String?>(
                        value: d,
                        child: Text(
                          d,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: (v) {
              _safeSetState(() => _selectedDept = v);
              _applyFiltersAndSort();
            },
            hint: const Text('Department'),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        constrainedDropdown(
          width: 140,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _statusFilter,
              dropdownColor: const Color(0xFF1A1A1A),
              underline: const SizedBox(),
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All')),
                DropdownMenuItem(
                  value: 'checkedout',
                  child: Text('Checked-out'),
                ),
                DropdownMenuItem(value: 'pending', child: Text('Pending')),
              ],
              onChanged: (v) {
                _safeSetState(() => _statusFilter = v ?? 'all');
                _applyFiltersAndSort();
              },
            ),
          ),
        ),
        constrainedDropdown(
          width: 160,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _sortBy,
              dropdownColor: const Color(0xFF1A1A1A),
              underline: const SizedBox(),
              style: const TextStyle(color: Colors.white),
              items: const [
                DropdownMenuItem(value: 'newest', child: Text('Newest')),
                DropdownMenuItem(value: 'oldest', child: Text('Oldest')),
                DropdownMenuItem(value: 'name_asc', child: Text('Name A–Z')),
                DropdownMenuItem(value: 'name_desc', child: Text('Name Z–A')),
              ],
              onChanged: (v) {
                _safeSetState(() => _sortBy = v ?? 'newest');
                _applyFiltersAndSort();
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChipsAndCounts(String dateLabel) {
    return Row(
      children: [
        Expanded(
          child: Text(dateLabel, style: const TextStyle(color: Colors.white70)),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C3E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Records: ${_filtered.length}',
            style: const TextStyle(color: Colors.white70),
          ),
        ),
      ],
    );
  }

  // small shimmer placeholder
  Widget _buildShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      itemBuilder: (context, i) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          height: 86,
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}

// small reusable attendance card widget (clean + glassy)
class _AttCard extends StatelessWidget {
  final String name;
  final String dept;
  final String dateStr;
  final String inTime;
  final String outTime;
  final bool isPending;
  final String? avatarUrl;
  final Color deepPurple;
  final Color cardColor;

  const _AttCard({
    required this.name,
    required this.dept,
    required this.dateStr,
    required this.inTime,
    required this.outTime,
    required this.isPending,
    required this.avatarUrl,
    required this.deepPurple,
    required this.cardColor,
  });

  @override
  Widget build(BuildContext context) {
    // glass-like container with subtle elevation
    return Card(
      color: cardColor.withOpacity(0.98),
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: ListTile(
          leading: CircleAvatar(
            radius: 26,
            backgroundColor: isPending ? Colors.orange : Colors.green,
            backgroundImage: avatarUrl != null
                ? NetworkImage(avatarUrl!)
                : null,
            child: avatarUrl == null
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPending ? Colors.orange : Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isPending ? 'Pending' : 'Checked Out',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dept: $dept',
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _InfoChip(icon: Icons.calendar_today, label: dateStr),
                    _InfoChip(
                      icon: Icons.login,
                      label: inTime,
                      color: Colors.greenAccent,
                    ),
                    _InfoChip(
                      icon: Icons.logout,
                      label: outTime,
                      color: isPending ? Colors.orangeAccent : Colors.redAccent,
                    ),
                  ],
                ),
              ],
            ),
          ),
          isThreeLine: true,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 60, maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1C),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? Colors.white70),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: color ?? Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
