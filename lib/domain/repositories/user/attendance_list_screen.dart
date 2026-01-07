import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:mobile_attendance_application/data/models/attendance_model.dart';
import 'package:mobile_attendance_application/data/models/user_model.dart';

class AttendanceListScreen extends StatefulWidget {
  final UserModel user;

  const AttendanceListScreen({super.key, required this.user});

  @override
  State<AttendanceListScreen> createState() => _AttendanceListScreenState();
}

class _AttendanceListScreenState extends State<AttendanceListScreen> {
  Future<List<AttendanceModel>>? _attendanceFuture;

  List<AttendanceModel> _cachedRecords = [];

  DateTimeRange? _selectedRange;

  static const int _pageSize = 20;
  int _currentPage = 1;

  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _attendanceFuture = _fetchAttendance();
  }

  Future<List<AttendanceModel>> _fetchAttendance() async {
    final url = Uri.parse(
      "https://trainerattendence-backed.onrender.com/api/attendance/user/${widget.user.userId}",
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      if (kDebugMode) {
        print(response.body);
      }

      final List data = jsonDecode(response.body);
      final list = data.map((e) => AttendanceModel.fromJson(e)).toList();

      list.sort((a, b) => b.checkInTime.compareTo(a.checkInTime));

      _cachedRecords = list;
      return list;
    } else {
      throw Exception('Failed to load attendance data');
    }
  }

  String formatDate(DateTime dateTime) =>
      "${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} "
      "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";

  String formatDuration(Duration d) => "${d.inHours}h ${d.inMinutes % 60}m";

  List<AttendanceModel> _applyDateFilter(List<AttendanceModel> input) {
    if (_selectedRange == null) return input;

    final start = DateTime(
      _selectedRange!.start.year,
      _selectedRange!.start.month,
      _selectedRange!.start.day,
    );
    final end = DateTime(
      _selectedRange!.end.year,
      _selectedRange!.end.month,
      _selectedRange!.end.day,
      23,
      59,
      59,
    );

    return input.where((att) {
      final d = att.checkInTime;
      return (d.isAfter(start) || d.isAtSameMomentAs(start)) &&
          (d.isBefore(end) || d.isAtSameMomentAs(end));
    }).toList();
  }

  List<AttendanceModel> _applyPagination(List<AttendanceModel> list) {
    final endIndex = _currentPage * _pageSize;
    if (endIndex >= list.length) return list;
    return list.sublist(0, endIndex);
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final initialStart =
        _selectedRange?.start ?? DateTime(now.year, now.month, 1);
    final initialEnd = _selectedRange?.end ?? now;

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 3),
      lastDate: DateTime(now.year + 1),
      initialDateRange: DateTimeRange(start: initialStart, end: initialEnd),
    );

    if (picked != null) {
      setState(() {
        _selectedRange = picked;
        _currentPage = 1;
      });
    }
  }

  List<AttendanceModel> _getRecordsForExport() {
    if (_cachedRecords.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No data to export')));
      return [];
    }

    final filtered = _applyDateFilter(_cachedRecords);
    if (filtered.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No records in selected date range')),
      );
    }
    return filtered;
  }

  String _buildBaseFileName() {
    final safeName = (widget.user.name ?? 'User').replaceAll(
      RegExp(r'\s+'),
      '_',
    );
    final baseDate = _selectedRange?.start ?? DateTime.now();
    final monthString = DateFormat('yyyy_MM').format(baseDate);
    return "Attendance_${safeName}_$monthString";
  }

  Future<Directory> _getDownloadDirectory() async {
    if (Platform.isAndroid) {
      final downloadDir = Directory('/storage/emulated/0/Download');
      if (await downloadDir.exists()) {
        return downloadDir;
      }
      return await getExternalStorageDirectory() ??
          await getApplicationDocumentsDirectory();
    } else if (Platform.isIOS) {
      return await getApplicationDocumentsDirectory();
    } else {
      return await getApplicationDocumentsDirectory();
    }
  }

  Future<File?> _generateExcelFile() async {
    final records = _getRecordsForExport();
    if (records.isEmpty) return null;

    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    sheet.appendRow([
      TextCellValue('Date'),
      TextCellValue('Check-In Time'),
      TextCellValue('Check-Out Time'),
      TextCellValue('Duration'),
      TextCellValue('Check-In Address'),
      TextCellValue('Check-Out Address'),
      TextCellValue('Check-In Mode'),
      TextCellValue('Check-Out Mode'),
    ]);

    for (final att in records) {
      final date = DateFormat('yyyy-MM-dd').format(att.checkInTime);
      final checkInTime = DateFormat('HH:mm').format(att.checkInTime);
      final checkOutTime = att.checkOutTime != null
          ? DateFormat('HH:mm').format(att.checkOutTime!)
          : '-';
      final duration = formatDuration(att.duration ?? Duration.zero);
      final checkInAddress = att.checkInAddress ?? '';
      final checkOutAddress = att.checkOutAddress ?? '';
      final checkInMode = att.checkInMode == true ? 'Online' : 'Offline';
      final checkOutMode = att.checkOutMode == true ? 'Online' : 'Offline';

      sheet.appendRow([
        TextCellValue(date),
        TextCellValue(checkInTime),
        TextCellValue(checkOutTime),
        TextCellValue(duration),
        TextCellValue(checkInAddress),
        TextCellValue(checkOutAddress),
        TextCellValue(checkInMode),
        TextCellValue(checkOutMode),
      ]);
    }

    final fileName = "${_buildBaseFileName()}.xlsx";
    final bytes = excel.encode();
    if (bytes == null) throw Exception('Failed to encode Excel');

    final dir = await _getDownloadDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);

    return file;
  }

  Future<File?> _generatePdfFile() async {
    final records = _getRecordsForExport();
    if (records.isEmpty) return null;

    final pdf = pw.Document();

    Duration totalDuration = Duration.zero;
    for (var att in records) {
      totalDuration += att.duration ?? Duration.zero;
    }

    String formatTotal(Duration d) => "${d.inHours}h ${d.inMinutes % 60}m";

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
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                "ATTENDANCE REPORT  ${(widget.user.name ?? 'User').toUpperCase()}",
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
            widget.user.name ?? "User",
            style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
          ),

          if (_selectedRange != null)
            pw.Text(
              "From ${DateFormat('dd MMM yyyy').format(_selectedRange!.start)}"
              " to ${DateFormat('dd MMM yyyy').format(_selectedRange!.end)}",
              style: pw.TextStyle(fontSize: 11),
            ),

          pw.SizedBox(height: 16),

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
                  "Total Records: ${records.length}",
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

          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.2),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1),
              3: const pw.FlexColumnWidth(1.2),
              4: const pw.FlexColumnWidth(2),
              5: const pw.FlexColumnWidth(2),
              6: const pw.FlexColumnWidth(1),
              7: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      "Date",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      "In",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      "Out",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      "Duration",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      "In Address",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      "Out Address",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      "In Mode",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                  pw.Padding(
                    padding: const pw.EdgeInsets.all(6),
                    child: pw.Text(
                      "Out Mode",
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),

              ...records.map((att) {
                final dateStr = DateFormat(
                  'yyyy-MM-dd',
                ).format(att.checkInTime);
                final inTime = DateFormat('HH:mm').format(att.checkInTime);
                final outTime = att.checkOutTime != null
                    ? DateFormat('HH:mm').format(att.checkOutTime!)
                    : "-";

                final inAddr = (att.checkInAddress?.trim().isEmpty ?? true)
                    ? "-"
                    : att.checkInAddress!.replaceAll('\n', ' ');

                final outAddr = (att.checkOutAddress?.trim().isEmpty ?? true)
                    ? "-"
                    : att.checkOutAddress!.replaceAll('\n', ' ');

                final dur = formatDuration(att.duration ?? Duration.zero);

                return pw.TableRow(
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(dateStr),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(inTime),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(outTime),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(dur),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(inAddr),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(outAddr),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        att.checkInMode == true ? "Online" : "Offline",
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(6),
                      child: pw.Text(
                        att.checkOutMode == true ? "Online" : "Offline",
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );

    final fileName = "${_buildBaseFileName()}.pdf";
    final dir = await _getDownloadDirectory();
    final file = File("${dir.path}/$fileName");
    await file.writeAsBytes(await pdf.save(), flush: true);

    return file;
  }

  Future<void> _exportToExcel() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final file = await _generateExcelFile();
      if (file == null) return;

      await OpenFilex.open(file.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Excel exported: ${file.path.split('/').last}'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Excel export failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _exportToPdf() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final file = await _generatePdfFile();
      if (file == null) return;

      await OpenFilex.open(file.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF exported: ${file.path.split('/').last}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('PDF export failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _shareExcel() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final file = await _generateExcelFile();
      if (file == null) return;

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Attendance report (Excel)');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Excel share failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  Future<void> _sharePdf() async {
    setState(() {
      _isExporting = true;
    });

    try {
      final file = await _generatePdfFile();
      if (file == null) return;

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Attendance report (PDF)');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('PDF share failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
      }
    }
  }

  void _showExportSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return _ExportBottomSheet(
          onExportExcel: _exportToExcel,
          onExportPdf: _exportToPdf,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateRangeLabel = _selectedRange == null
        ? 'All dates'
        : '${DateFormat('dd MMM yyyy').format(_selectedRange!.start)} - '
              '${DateFormat('dd MMM yyyy').format(_selectedRange!.end)}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance History'),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: 'Filter by date range',
            onPressed: _pickDateRange,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export',
            onPressed: _showExportSheet,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.share),
            tooltip: 'Share',
            onSelected: (value) {
              if (value == 'share_excel') {
                _shareExcel();
              } else if (value == 'share_pdf') {
                _sharePdf();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'share_excel', child: Text('Share Excel')),
              PopupMenuItem(value: 'share_pdf', child: Text('Share PDF')),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Colors.deepPurple.withOpacity(0.05),
                child: Row(
                  children: [
                    const Icon(Icons.date_range, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        dateRangeLabel,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _selectedRange = null;
                          _currentPage = 1;
                        });
                      },
                      child: const Text(
                        'Clear',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FutureBuilder<List<AttendanceModel>>(
                  future: _attendanceFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Colors.deepPurple,
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    final all = snapshot.data ?? [];
                    _cachedRecords = all;

                    final filtered = _applyDateFilter(all);

                    if (filtered.isEmpty) {
                      return const Center(
                        child: Text('No attendance records found.'),
                      );
                    }

                    final paged = _applyPagination(filtered);
                    final bool canLoadMore = paged.length < filtered.length;

                    return RefreshIndicator(
                      onRefresh: () async {
                        setState(() {
                          _currentPage = 1;
                          _attendanceFuture = _fetchAttendance();
                        });
                        await _attendanceFuture;
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: paged.length + (canLoadMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == paged.length && canLoadMore) {
                            return Center(
                              child: TextButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _currentPage++;
                                  });
                                },
                                icon: const Icon(Icons.expand_more),
                                label: const Text("Load more"),
                              ),
                            );
                          }

                          final attendance = paged[index];
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
                                      : [
                                          Colors.purple.shade50,
                                          Colors.purple.shade100,
                                        ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
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
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          checkedOut
                                              ? 'Checked Out'
                                              : 'Checked In',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    color: Colors.deepPurple,
                                    height: 24,
                                  ),

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
                                              value: formatDate(
                                                attendance.checkOutTime!,
                                              ),
                                            ),
                                            InfoRow(
                                              icon: Icons.timer,
                                              color: Colors.deepPurpleAccent,
                                              label: "Duration",
                                              value: formatDuration(
                                                attendance.duration ??
                                                    Duration.zero,
                                              ),
                                            ),
                                            if (attendance.checkOutLatitude !=
                                                    null &&
                                                attendance.checkOutLongitude !=
                                                    null)
                                              InfoRow(
                                                icon: Icons.my_location,
                                                color: Colors.deepPurple,
                                                label: "Coordinates",
                                                value:
                                                    "${attendance.checkOutLatitude}, ${attendance.checkOutLongitude}",
                                              ),
                                            if (attendance.checkOutAddress !=
                                                null)
                                              InfoRow(
                                                icon: Icons.location_on,
                                                color: Colors.deepPurpleAccent,
                                                label: "Address",
                                                value:
                                                    attendance.checkOutAddress!,
                                              ),
                                            InfoRow(
                                              icon: Icons.settings,
                                              color: Colors.deepPurple,
                                              label: "Mode",
                                              value:
                                                  attendance.checkOutMode ==
                                                      true
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
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          if (_isExporting)
            Container(
              color: Colors.black.withOpacity(0.25),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

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

class _ExportBottomSheet extends StatelessWidget {
  final VoidCallback onExportExcel;
  final VoidCallback onExportPdf;

  const _ExportBottomSheet({
    required this.onExportExcel,
    required this.onExportPdf,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        color: Colors.black45,
        child: GestureDetector(
          onTap: () {},
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPadding),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.90),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const Text(
                        "Export Attendance",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: const Icon(Icons.grid_on),
                        title: const Text("Export as Excel"),
                        subtitle: const Text("Download .xlsx file"),
                        onTap: onExportExcel,
                      ),
                      ListTile(
                        leading: const Icon(Icons.picture_as_pdf),
                        title: const Text("Export as PDF"),
                        subtitle: const Text("Download .pdf report"),
                        onTap: onExportPdf,
                      ),
                      const SizedBox(height: 4),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.redAccent),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
