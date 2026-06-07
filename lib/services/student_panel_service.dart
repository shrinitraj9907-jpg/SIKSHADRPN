import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shiksha_darpan/models/achievement_model.dart';
import 'package:shiksha_darpan/models/exam_model.dart';
import 'package:shiksha_darpan/models/student_attendance_model.dart';
import 'package:shiksha_darpan/models/student_model.dart';
import 'package:shiksha_darpan/models/subject_mark_model.dart';

class StudentPanelService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _students() =>
      _firestore.collection('students');

  DocumentReference<Map<String, dynamic>> _studentDoc(String studentId) =>
      _students().doc(studentId);

  // ── Student profile ───────────────────────────────────────────────────────

  Future<StudentModel?> getStudent(String studentId) async {
    final doc = await _studentDoc(studentId).get();
    if (!doc.exists || doc.data() == null) return null;
    return StudentModel.fromJson(doc.data()!, docId: studentId);
  }

  Stream<StudentModel?> streamStudent(String studentId) {
    return _studentDoc(studentId).snapshots().map((doc) {
      if (!doc.exists || doc.data() == null) return null;
      return StudentModel.fromJson(doc.data()!, docId: studentId);
    });
  }

  Future<List<StudentModel>> listStudents({String? schoolUdise}) async {
    Query<Map<String, dynamic>> query = _students();
    if (schoolUdise != null) {
      query = query.where('enrolledSchoolUdise', isEqualTo: schoolUdise);
    }
    final snap = await query.orderBy('name').get();
    return snap.docs
        .map((d) => StudentModel.fromJson(d.data(), docId: d.id))
        .toList();
  }

  Stream<List<StudentModel>> streamStudents({String? schoolUdise}) {
    Query<Map<String, dynamic>> query = _students();
    if (schoolUdise != null) {
      query = query.where('enrolledSchoolUdise', isEqualTo: schoolUdise);
    }
    return query.orderBy('name').snapshots().map(
          (snap) => snap.docs
              .map((d) => StudentModel.fromJson(d.data(), docId: d.id))
              .toList(),
        );
  }

  // ── Exams & marks ─────────────────────────────────────────────────────────

  Stream<List<ExamModel>> streamExams(String studentId, {int? year}) {
    return _studentDoc(studentId)
        .collection('exams')
        .orderBy('sortOrder')
        .snapshots()
        .map((snap) {
      var exams = snap.docs
          .map((d) => ExamModel.fromJson(d.data(), studentId: studentId))
          .toList();
      if (year != null) {
        exams = exams.where((e) => e.year == year).toList();
      }
      return exams;
    });
  }

  Stream<List<SubjectMarkModel>> streamExamSubjects(
    String studentId,
    String examId,
  ) {
    return _studentDoc(studentId)
        .collection('exams')
        .doc(examId)
        .collection('subjects')
        .orderBy('subjectName')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => SubjectMarkModel.fromJson({...d.data(), 'id': d.id}))
              .toList(),
        );
  }

  Future<Map<String, List<SubjectMarkModel>>> fetchAllMarksBySubject(
    String studentId, {
    int? year,
  }) async {
    final examsSnap = await _studentDoc(studentId).collection('exams').get();
    final bySubject = <String, List<SubjectMarkModel>>{};

    for (final examDoc in examsSnap.docs) {
      final exam = ExamModel.fromJson(examDoc.data(), studentId: studentId);
      if (year != null && exam.year != year) continue;

      final subjectsSnap = await examDoc.reference.collection('subjects').get();
      for (final subDoc in subjectsSnap.docs) {
        final mark = SubjectMarkModel.fromJson({
          ...subDoc.data(),
          'id': subDoc.id,
        });
        bySubject.putIfAbsent(mark.subjectName, () => []).add(mark);
      }
    }
    return bySubject;
  }

  /// Teacher submits/updates marks for their subject only.
  Future<void> upsertSubjectMark({
    required String studentId,
    required String examId,
    required SubjectMarkModel mark,
  }) async {
    await _studentDoc(studentId)
        .collection('exams')
        .doc(examId)
        .collection('subjects')
        .doc(mark.id)
        .set(mark.toJson(), SetOptions(merge: true));
  }

  Future<void> ensureExamExists({
    required String studentId,
    required ExamModel exam,
  }) async {
    await _studentDoc(studentId)
        .collection('exams')
        .doc(exam.id)
        .set(exam.toJson(), SetOptions(merge: true));
  }

  // ── Attendance ────────────────────────────────────────────────────────────

  Stream<StudentMonthlyAttendanceModel?> streamMonthlyAttendance(
    String studentId,
    int year,
    int month,
  ) {
    final docId = StudentMonthlyAttendanceModel.monthDocId(year, month);
    return _studentDoc(studentId)
        .collection('attendance')
        .doc(docId)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) {
        return StudentMonthlyAttendanceModel(
          id: docId,
          studentId: studentId,
          year: year,
          month: month,
          days: {},
        );
      }
      return StudentMonthlyAttendanceModel.fromJson(
        doc.data()!,
        studentId: studentId,
        docId: docId,
      );
    });
  }

  Future<double> calculateYearAttendancePercentage(
    String studentId,
    int year,
  ) async {
    final snap =
        await _studentDoc(studentId).collection('attendance').get();
    int present = 0;
    int working = 0;
    for (final doc in snap.docs) {
      final data = doc.data();
      if (data['year'] != year) continue;
      final month = StudentMonthlyAttendanceModel.fromJson(
        data,
        studentId: studentId,
        docId: doc.id,
      );
      present += month.presentCount;
      working += month.workingDays;
    }
    return working > 0 ? (present / working) * 100 : 100;
  }

  Future<void> setAttendanceDay({
    required String studentId,
    required int year,
    required int month,
    required int day,
    required AttendanceDayStatus status,
  }) async {
    final docId = StudentMonthlyAttendanceModel.monthDocId(year, month);
    final ref = _studentDoc(studentId).collection('attendance').doc(docId);
    await _firestore.runTransaction((txn) async {
      final snap = await txn.get(ref);
      final data = snap.data() ?? {
        'studentId': studentId,
        'year': year,
        'month': month,
        'days': <String, String>{},
      };
      final days = Map<String, dynamic>.from(data['days'] as Map? ?? {});
      days[day.toString()] = status.firestoreKey;
      data['days'] = days;
      data['id'] = docId;
      txn.set(ref, data, SetOptions(merge: true));
    });
  }

  // ── Achievements ──────────────────────────────────────────────────────────

  Stream<List<AchievementModel>> streamAchievements(String studentId) {
    return _studentDoc(studentId)
        .collection('achievements')
        .orderBy('date', descending: true)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map(
                (d) => AchievementModel.fromJson(
                  {...d.data(), 'id': d.id},
                  studentId: studentId,
                ),
              )
              .toList(),
        );
  }

  Future<void> addAchievement(AchievementModel achievement) async {
    await _studentDoc(achievement.studentId)
        .collection('achievements')
        .doc(achievement.id)
        .set(achievement.toJson());
  }

  // ── Demo seed ─────────────────────────────────────────────────────────────

  Future<void> seedDemoStudentData(String studentId) async {
    final studentRef = _studentDoc(studentId);
    await studentRef.set({
      'apaarId': 'APAAR-$studentId',
      'name': 'Priya Sharma',
      'grade': 8,
      'enrolledSchoolUdise': '27201804302',
      'dateOfBirth': '2012-04-15T00:00:00.000',
      'section': 'A',
      'rollNumber': '18',
    }, SetOptions(merge: true));

    final year = DateTime.now().year;
    final exams = [
      ExamModel(
        id: '${year}_unitTest1',
        studentId: studentId,
        type: ExamType.unitTest1,
        year: year,
        name: 'Unit Test 1',
        sortOrder: 1,
      ),
      ExamModel(
        id: '${year}_unitTest2',
        studentId: studentId,
        type: ExamType.unitTest2,
        year: year,
        name: 'Unit Test 2',
        sortOrder: 2,
      ),
      ExamModel(
        id: '${year}_halfYearly',
        studentId: studentId,
        type: ExamType.halfYearly,
        year: year,
        name: 'Half Yearly',
        sortOrder: 3,
      ),
      ExamModel(
        id: '${year}_annual',
        studentId: studentId,
        type: ExamType.annual,
        year: year,
        name: 'Annual',
        sortOrder: 4,
      ),
    ];

    final subjects = ['Mathematics', 'Science', 'English', 'Hindi', 'Social Studies'];
    final batch = _firestore.batch();

    for (final exam in exams) {
      final examRef = studentRef.collection('exams').doc(exam.id);
      batch.set(examRef, exam.toJson());
      for (var i = 0; i < subjects.length; i++) {
        final obtained = 55.0 + (exam.sortOrder * 3) + (i * 2);
        batch.set(
          examRef.collection('subjects').doc(subjects[i].toLowerCase().replaceAll(' ', '_')),
          SubjectMarkModel(
            id: subjects[i].toLowerCase().replaceAll(' ', '_'),
            subjectName: subjects[i],
            obtainedMarks: obtained.clamp(0, 100),
            totalMarks: 100,
            teacherId: 'demo_teacher',
            teacherName: 'Demo Teacher',
          ).toJson(),
        );
      }
    }

    final now = DateTime.now();
    final attDocId =
        StudentMonthlyAttendanceModel.monthDocId(now.year, now.month);
    final days = <String, String>{};
    for (var d = 1; d <= now.day; d++) {
      if (d % 7 == 0) {
        days[d.toString()] = AttendanceDayStatus.holiday.firestoreKey;
      } else if (d % 11 == 0) {
        days[d.toString()] = AttendanceDayStatus.absent.firestoreKey;
      } else {
        days[d.toString()] = AttendanceDayStatus.present.firestoreKey;
      }
    }
    batch.set(studentRef.collection('attendance').doc(attDocId), {
      'id': attDocId,
      'studentId': studentId,
      'year': now.year,
      'month': now.month,
      'days': days,
    });

    batch.set(
      studentRef.collection('achievements').doc('ach1'),
      AchievementModel(
        id: 'ach1',
        studentId: studentId,
        title: 'District Science Olympiad – 2nd Place',
        date: DateTime(now.year, 2, 14),
        category: AchievementCategory.academics,
        description: 'Secured 2nd position in district-level science quiz.',
        addedByTeacherId: 'demo_teacher',
        addedByTeacherName: 'Sunita Sharma',
      ).toJson(),
    );
    batch.set(
      studentRef.collection('achievements').doc('ach2'),
      AchievementModel(
        id: 'ach2',
        studentId: studentId,
        title: 'Inter-School Kho-Kho Champion',
        date: DateTime(now.year, 1, 20),
        category: AchievementCategory.sports,
        description: 'Led school team to victory in block-level tournament.',
        addedByTeacherId: 'demo_teacher',
        addedByTeacherName: 'Ramesh Kumar',
      ).toJson(),
    );

    await batch.commit();
  }
}
