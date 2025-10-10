import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_attendance_application/core/themes/constants/app_constants.dart';
import 'package:mobile_attendance_application/core/themes/constants/string_constants.dart';
import '../../core/themes/app_theme.dart';
import '../../core/themes/text_styles.dart';
import '../../data/models/attendance_model.dart';

class AttendanceListItem extends StatelessWidget {
  final AttendanceModel attendance;

  const AttendanceListItem({super.key, required this.attendance});

  @override
  Widget build(BuildContext context) {
    final duration = attendance.duration;
    final textStyle = _getDurationTextStyle(context, duration);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: _buildStatusIcon(context),
        title: Text(
          DateFormat(AppConstants.dateFormat).format(attendance.checkInTime),
          style: TextStyles.bodyLarge(
            context,
          ).copyWith(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${StringConstants.time}: ${DateFormat(AppConstants.timeFormat).format(attendance.checkInTime)}',
            ),
            if (attendance.checkOutTime != null)
              Text(
                '${StringConstants.time}: ${DateFormat(AppConstants.timeFormat).format(attendance.checkOutTime!)}',
              ),
            const SizedBox(height: 4),
            Text(
              '${StringConstants.duration}: ${_formatDuration(duration)}',
              style: textStyle,
            ),
            if (attendance.department != null)
              Text(
                '${StringConstants.department}: ${attendance.department}',
                style: TextStyles.bodySmall(context),
              ),
          ],
        ),

        trailing: attendance.checkOutTime == null
            ? Chip(
                label: Text(
                  StringConstants.active,
                  style: Theme.of(context).textTheme.labelSmall!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: AppTheme.attendanceStatusColors['active'],
              )
            : null,
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        attendance.checkOutTime == null ? Icons.timer : Icons.check_circle,
        color: Theme.of(context).colorScheme.primary,
        size: 20,
      ),
    );
  }

  TextStyle _getDurationTextStyle(BuildContext context, Duration duration) {
    final hours = duration.inHours;
    if (hours < AppConstants.minWorkHours) {
      return TextStyles.attendanceDurationShort(context);
    } else if (hours < AppConstants.standardWorkHours) {
      return TextStyles.attendanceDurationMedium(context);
    } else {
      return TextStyles.attendanceDurationLong(context);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    return "$hours:$minutes";
  }
}
