import 'package:flutter/material.dart';
import 'package:shiksha_darpan/models/student_attendance_model.dart';
import 'package:shiksha_darpan/services/student_panel_service.dart';
import 'package:shiksha_darpan/theme/student_panel_theme.dart';

class AttendanceTab extends StatefulWidget {
  const AttendanceTab({super.key, required this.studentId});

  final String studentId;

  @override
  State<AttendanceTab> createState() => _AttendanceTabState();
}

class _AttendanceTabState extends State<AttendanceTab> {
  final _service = StudentPanelService();
  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  }

  void _changeMonth(int delta) {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + delta);
    });
  }

  static const _monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StudentMonthlyAttendanceModel?>(
      stream: _service.streamMonthlyAttendance(
        widget.studentId,
        _focusedMonth.year,
        _focusedMonth.month,
      ),
      builder: (context, snap) {
        final attendance = snap.data ??
            StudentMonthlyAttendanceModel(
              id: StudentMonthlyAttendanceModel.monthDocId(
                _focusedMonth.year,
                _focusedMonth.month,
              ),
              studentId: widget.studentId,
              year: _focusedMonth.year,
              month: _focusedMonth.month,
              days: {},
            );

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (attendance.isBelowThreshold) _lowAttendanceAlert(attendance),
            _summaryCard(attendance),
            const SizedBox(height: 16),
            _calendarCard(attendance),
            const SizedBox(height: 16),
            _legend(),
          ],
        );
      },
    );
  }

  Widget _lowAttendanceAlert(StudentMonthlyAttendanceModel att) {
    return Card(
      color: Colors.red.shade50,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        leading: Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
        title: Text(
          'Attendance Below 75%',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.red.shade800,
          ),
        ),
        subtitle: Text(
          'Current: ${att.attendancePercentage.toStringAsFixed(1)}% — '
          'Please improve regularity.',
          style: TextStyle(color: Colors.red.shade700),
        ),
      ),
    );
  }

  Widget _summaryCard(StudentMonthlyAttendanceModel att) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _summaryItem(
              'Present',
              att.presentCount.toString(),
              Colors.green,
            ),
            _summaryItem(
              'Absent',
              att.absentCount.toString(),
              Colors.red,
            ),
            _summaryItem(
              'Holiday',
              att.holidayCount.toString(),
              Colors.blue,
            ),
            _summaryItem(
              'Attendance',
              '${att.attendancePercentage.toStringAsFixed(1)}%',
              StudentPanelTheme.indigo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _calendarCard(StudentMonthlyAttendanceModel att) {
    final firstDay = DateTime(att.year, att.month, 1);
    final daysInMonth = DateTime(att.year, att.month + 1, 0).day;
    final startWeekday = firstDay.weekday % 7;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => _changeMonth(-1),
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  '${_monthNames[att.month - 1]} ${att.year}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: StudentPanelTheme.indigoDark,
                  ),
                ),
                IconButton(
                  onPressed: () => _changeMonth(1),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
              ),
              itemCount: startWeekday + daysInMonth,
              itemBuilder: (context, index) {
                if (index < startWeekday) return const SizedBox.shrink();
                final day = index - startWeekday + 1;
                final status = att.days[day] ?? AttendanceDayStatus.unmarked;
                return _dayCell(day, status);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _dayCell(int day, AttendanceDayStatus status) {
    Color bg;
    Color fg = Colors.white;
    IconData? icon;

    switch (status) {
      case AttendanceDayStatus.present:
        bg = Colors.green;
        icon = Icons.check;
        break;
      case AttendanceDayStatus.absent:
        bg = Colors.red;
        icon = Icons.close;
        break;
      case AttendanceDayStatus.holiday:
        bg = Colors.blue.shade300;
        icon = Icons.star;
        break;
      case AttendanceDayStatus.unmarked:
        bg = Colors.grey.shade200;
        fg = Colors.grey.shade600;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$day',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: fg,
            ),
          ),
          if (icon != null)
            Icon(icon, size: 12, color: fg),
        ],
      ),
    );
  }

  Widget _legend() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 16,
          runSpacing: 8,
          children: [
            _legendItem(Colors.green, 'Present'),
            _legendItem(Colors.red, 'Absent'),
            _legendItem(Colors.blue.shade300, 'Holiday'),
            _legendItem(Colors.grey.shade200, 'Unmarked', textDark: true),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label, {bool textDark = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: textDark ? Colors.grey.shade700 : Colors.black87,
          ),
        ),
      ],
    );
  }
}
