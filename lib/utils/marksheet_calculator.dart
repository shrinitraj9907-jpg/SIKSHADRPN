import 'package:flutter/material.dart';
import 'package:shiksha_darpan/models/subject_mark_model.dart';

class MarksheetSummary {
  final double examPercentage;
  final Map<String, double> subjectAnnualAverages;
  final double overallAnnualPercentage;
  final String overallGrade;

  const MarksheetSummary({
    required this.examPercentage,
    required this.subjectAnnualAverages,
    required this.overallAnnualPercentage,
    required this.overallGrade,
  });
}

class MarksheetCalculator {
  static double examPercentage(List<SubjectMarkModel> subjects) {
    if (subjects.isEmpty) return 0;
    final obtained = subjects.fold<double>(0, (s, m) => s + m.obtainedMarks);
    final total = subjects.fold<double>(0, (s, m) => s + m.totalMarks);
    return total > 0 ? (obtained / total) * 100 : 0;
  }

  static Map<String, double> subjectAnnualAverages(
    Map<String, List<SubjectMarkModel>> marksBySubject,
  ) {
    final averages = <String, double>{};
    marksBySubject.forEach((subject, marks) {
      if (marks.isEmpty) return;
      final sum = marks.fold<double>(0, (s, m) => s + m.percentage);
      averages[subject] = sum / marks.length;
    });
    return averages;
  }

  static double overallAnnualPercentage(Map<String, double> subjectAverages) {
    if (subjectAverages.isEmpty) return 0;
    final values = subjectAverages.values.toList();
    return values.fold<double>(0, (s, v) => s + v) / values.length;
  }

  static String performanceGrade(double percentage) {
    if (percentage >= 90) return 'A+';
    if (percentage >= 80) return 'A';
    if (percentage >= 70) return 'B';
    if (percentage >= 60) return 'C';
    if (percentage >= 50) return 'D';
    return 'F';
  }

  static Color gradeColor(String grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return const Color(0xFF2E7D32);
      case 'B':
        return const Color(0xFF558B2F);
      case 'C':
        return const Color(0xFFF9A825);
      case 'D':
        return const Color(0xFFEF6C00);
      default:
        return const Color(0xFFC62828);
    }
  }

  static MarksheetSummary buildSummary({
    required List<SubjectMarkModel> selectedExamMarks,
    required Map<String, List<SubjectMarkModel>> allExamMarksBySubject,
  }) {
    final subjectAvgs = subjectAnnualAverages(allExamMarksBySubject);
    final overall = overallAnnualPercentage(subjectAvgs);
    return MarksheetSummary(
      examPercentage: examPercentage(selectedExamMarks),
      subjectAnnualAverages: subjectAvgs,
      overallAnnualPercentage: overall,
      overallGrade: performanceGrade(overall),
    );
  }
}
