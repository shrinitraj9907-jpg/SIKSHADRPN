import 'package:flutter/material.dart';
import 'package:shiksha_darpan/models/exam_model.dart';
import 'package:shiksha_darpan/models/student_model.dart';
import 'package:shiksha_darpan/models/subject_mark_model.dart';
import 'package:shiksha_darpan/theme/student_panel_theme.dart';
import 'package:shiksha_darpan/utils/marksheet_calculator.dart';

class PrintableMarksheetCard extends StatelessWidget {
  const PrintableMarksheetCard({
    super.key,
    required this.student,
    required this.exam,
    required this.subjects,
    required this.summary,
    required this.year,
  });

  final StudentModel student;
  final ExamModel exam;
  final List<SubjectMarkModel> subjects;
  final MarksheetSummary summary;
  final int year;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: StudentPanelTheme.indigoLight, width: 2),
        boxShadow: [
          BoxShadow(
            color: StudentPanelTheme.indigo.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: StudentPanelTheme.indigo,
              borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
            ),
            child: Column(
              children: [
                const Text(
                  'SHIKSHADARPAN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Official Marksheet — ${exam.name} ($year)',
                  style: const TextStyle(color: Color(0xCCFFFFFF), fontSize: 13),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoRow('Student', student.name),
                _infoRow('Class', 'Grade ${student.grade}${student.section.isNotEmpty ? ' • Sec ${student.section}' : ''}'),
                _infoRow('Roll No.', student.rollNumber.isNotEmpty ? student.rollNumber : '—'),
                _infoRow('APAAR ID', student.apaarId),
                const Divider(height: 28),
                Table(
                  border: TableBorder.all(color: StudentPanelTheme.indigoLight),
                  columnWidths: const {
                    0: FlexColumnWidth(2),
                    1: FlexColumnWidth(1),
                    2: FlexColumnWidth(1),
                    3: FlexColumnWidth(1),
                  },
                  children: [
                    TableRow(
                      decoration: BoxDecoration(
                        color: StudentPanelTheme.indigo.withOpacity(0.08),
                      ),
                      children: _headerCells(
                        ['Subject', 'Obtained', 'Total', '%'],
                      ),
                    ),
                    ...subjects.map((s) => TableRow(
                          children: [
                            _cell(s.subjectName, bold: true),
                            _cell(s.obtainedMarks.toStringAsFixed(0)),
                            _cell(s.totalMarks.toStringAsFixed(0)),
                            _cell('${s.percentage.toStringAsFixed(1)}%'),
                          ],
                        )),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _statBox(
                        'Exam %',
                        '${summary.examPercentage.toStringAsFixed(1)}%',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statBox(
                        'Annual %',
                        '${summary.overallAnnualPercentage.toStringAsFixed(1)}%',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _statBox(
                        'Grade',
                        summary.overallGrade,
                        color: MarksheetCalculator.gradeColor(
                          summary.overallGrade,
                        ),
                      ),
                    ),
                  ],
                ),
                if (summary.subjectAnnualAverages.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Subject Annual Averages',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: StudentPanelTheme.indigoDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: summary.subjectAnnualAverages.entries
                        .map(
                          (e) => Chip(
                            label: Text(
                              '${e.key}: ${e.value.toStringAsFixed(1)}%',
                              style: const TextStyle(fontSize: 11),
                            ),
                            backgroundColor:
                                StudentPanelTheme.indigoLight.withOpacity(0.5),
                          ),
                        )
                        .toList(),
                  ),
                ],
                const SizedBox(height: 20),
                const Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'This is a computer-generated marksheet from ShikshaDarpan.',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _headerCells(List<String> labels) {
    return labels
        .map(
          (l) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            child: Text(
              l,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: StudentPanelTheme.indigoDark,
              ),
            ),
          ),
        )
        .toList();
  }

  Widget _cell(String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _statBox(String label, String value, {Color? color}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: (color ?? StudentPanelTheme.indigo).withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (color ?? StudentPanelTheme.indigo).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color ?? StudentPanelTheme.indigoDark,
            ),
          ),
          Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}
