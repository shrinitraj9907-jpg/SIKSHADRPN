import 'package:flutter/material.dart';

enum AchievementCategory {
  sports,
  academics,
  extracurricular,
}

extension AchievementCategoryX on AchievementCategory {
  String get label {
    switch (this) {
      case AchievementCategory.sports:
        return 'Sports';
      case AchievementCategory.academics:
        return 'Academics';
      case AchievementCategory.extracurricular:
        return 'Extracurricular';
    }
  }

  String get firestoreKey => name;

  IconData get icon {
    switch (this) {
      case AchievementCategory.sports:
        return Icons.sports_soccer;
      case AchievementCategory.academics:
        return Icons.school;
      case AchievementCategory.extracurricular:
        return Icons.palette;
    }
  }

  static AchievementCategory fromKey(String key) {
    return AchievementCategory.values.firstWhere(
      (e) => e.name == key,
      orElse: () => AchievementCategory.academics,
    );
  }
}

class AchievementModel {
  final String id;
  final String studentId;
  final String title;
  final DateTime date;
  final AchievementCategory category;
  final String description;
  final String? photoUrl;
  final String addedByTeacherId;
  final String addedByTeacherName;

  AchievementModel({
    required this.id,
    required this.studentId,
    required this.title,
    required this.date,
    required this.category,
    required this.description,
    this.photoUrl,
    required this.addedByTeacherId,
    this.addedByTeacherName = '',
  });

  factory AchievementModel.fromJson(
    Map<String, dynamic> json, {
    String? studentId,
  }) {
    return AchievementModel(
      id: json['id'] ?? '',
      studentId: studentId ?? json['studentId'] ?? '',
      title: json['title'] ?? '',
      date: DateTime.tryParse(json['date']?.toString() ?? '') ?? DateTime.now(),
      category: AchievementCategoryX.fromKey(
        json['category']?.toString() ?? 'academics',
      ),
      description: json['description'] ?? '',
      photoUrl: json['photoUrl'],
      addedByTeacherId: json['addedByTeacherId'] ?? '',
      addedByTeacherName: json['addedByTeacherName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'title': title,
        'date': date.toIso8601String(),
        'category': category.firestoreKey,
        'description': description,
        'photoUrl': photoUrl,
        'addedByTeacherId': addedByTeacherId,
        'addedByTeacherName': addedByTeacherName,
      };
}
