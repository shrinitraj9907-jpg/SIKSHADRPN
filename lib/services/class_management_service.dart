// lib/services/class_management_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shiksha_darpan/models/class_section_model.dart';
import 'package:shiksha_darpan/models/enhanced_student_model.dart';

class ClassManagementService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Collections ───────────────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _classes(String schoolUdise) =>
      _db.collection('schools').doc(schoolUdise).collection('classes');

  CollectionReference<Map<String, dynamic>> _sections(
          String schoolUdise, String classId) =>
      _classes(schoolUdise).doc(classId).collection('sections');

  CollectionReference<Map<String, dynamic>> get _students =>
      _db.collection('students');

  // ── Classes ───────────────────────────────────────────────────────────────

  Stream<List<ClassModel>> streamClasses(String schoolUdise) {
    return _classes(schoolUdise)
        .orderBy('grade')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ClassModel.fromJson(d.data(), docId: d.id))
            .toList());
  }

  Future<void> ensureClassExists(String schoolUdise, int grade) async {
    final classId = 'class_$grade';
    final ref = _classes(schoolUdise).doc(classId);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set(ClassModel(
        id: classId,
        grade: grade,
        schoolUdise: schoolUdise,
      ).toJson());
    }
  }

  // ── Sections ─────────────────────────────────────────────────────────────

  Stream<List<SectionModel>> streamSections(
      String schoolUdise, int grade) {
    final classId = 'class_$grade';
    return _sections(schoolUdise, classId)
        .orderBy('section')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => SectionModel.fromJson(d.data(), docId: d.id))
            .toList());
  }

  Future<List<SectionModel>> getSections(
      String schoolUdise, int grade) async {
    final classId = 'class_$grade';
    final snap = await _sections(schoolUdise, classId).orderBy('section').get();
    return snap.docs
        .map((d) => SectionModel.fromJson(d.data(), docId: d.id))
        .toList();
  }

  Future<void> createSection(String schoolUdise, SectionModel section) async {
    await ensureClassExists(schoolUdise, section.grade);
    final classId = 'class_${section.grade}';
    await _sections(schoolUdise, classId).doc(section.id).set(section.toJson());
  }

  Future<void> updateSection(String schoolUdise, SectionModel section) async {
    final classId = 'class_${section.grade}';
    await _sections(schoolUdise, classId)
        .doc(section.id)
        .update(section.toJson());
  }

  Future<void> deleteSection(
      String schoolUdise, int grade, String sectionId) async {
    final classId = 'class_$grade';
    await _sections(schoolUdise, classId).doc(sectionId).delete();
  }

  // ── Students ──────────────────────────────────────────────────────────────

  Stream<List<EnhancedStudentModel>> streamSectionStudents(
      String schoolUdise, int grade, String section) {
    return _students
        .where('schoolUdise', isEqualTo: schoolUdise)
        .where('grade', isEqualTo: grade)
        .where('section', isEqualTo: section)
        .orderBy('rollNumber')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                EnhancedStudentModel.fromJson(d.data(), docId: d.id))
            .toList());
  }

  Stream<List<EnhancedStudentModel>> streamSchoolStudents(
      String schoolUdise) {
    return _students
        .where('schoolUdise', isEqualTo: schoolUdise)
        .orderBy('name')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) =>
                EnhancedStudentModel.fromJson(d.data(), docId: d.id))
            .toList());
  }

  Future<EnhancedStudentModel?> getStudent(String studentId) async {
    final doc = await _students.doc(studentId).get();
    if (!doc.exists || doc.data() == null) return null;
    return EnhancedStudentModel.fromJson(doc.data()!, docId: doc.id);
  }

  Future<void> createStudent(EnhancedStudentModel student) async {
    await _students.doc(student.id).set(student.toJson());
    await _updateSectionCounts(
        student.schoolUdise, student.grade, student.section);
  }

  Future<void> updateStudent(EnhancedStudentModel student) async {
    await _students.doc(student.id).update(student.toJson());
    await _updateSectionCounts(
        student.schoolUdise, student.grade, student.section);
  }

  Future<void> deleteStudent(
      String studentId, String schoolUdise, int grade, String section) async {
    await _students.doc(studentId).delete();
    await _updateSectionCounts(schoolUdise, grade, section);
  }

  Future<void> _updateSectionCounts(
      String schoolUdise, int grade, String section) async {
    try {
      final snap = await _students
          .where('schoolUdise', isEqualTo: schoolUdise)
          .where('grade', isEqualTo: grade)
          .where('section', isEqualTo: section)
          .get();

      int boys = 0;
      int girls = 0;
      final ids = <String>[];

      for (final doc in snap.docs) {
        ids.add(doc.id);
        final gender = doc.data()['gender'] ?? 'male';
        if (gender == 'female') {
          girls++;
        } else {
          boys++;
        }
      }

      final classId = 'class_$grade';
      final sectionId = '${classId}_$section';
      await _sections(schoolUdise, classId).doc(sectionId).update({
        'totalBoys': boys,
        'totalGirls': girls,
        'studentIds': ids,
      });
    } catch (_) {
      // Section may not exist yet; silently ignore
    }
  }

  /// Seed demo classes (Class 1–12) with sections A and B for a school
  Future<void> seedDemoClasses(String schoolUdise) async {
    final batch = _db.batch();
    for (int grade = 1; grade <= 12; grade++) {
      final classId = 'class_$grade';
      final classRef = _classes(schoolUdise).doc(classId);
      batch.set(classRef, ClassModel(
        id: classId,
        grade: grade,
        schoolUdise: schoolUdise,
        sectionIds: ['${classId}_A', '${classId}_B'],
      ).toJson());

      for (final sec in ['A', 'B']) {
        final sectionId = '${classId}_$sec';
        final secRef = _sections(schoolUdise, classId).doc(sectionId);
        batch.set(secRef, SectionModel(
          id: sectionId,
          grade: grade,
          section: sec,
          schoolUdise: schoolUdise,
          classTeacherName: 'Teacher $grade$sec',
          maxStudents: 40,
        ).toJson());
      }
    }
    await batch.commit();
  }
}
