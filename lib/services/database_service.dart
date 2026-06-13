import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shiksha_darpan/models/complaint_model.dart';
import 'package:shiksha_darpan/models/user_model.dart';
import 'package:shiksha_darpan/models/lesson_log_model.dart';
import 'package:shiksha_darpan/models/teacher_rating_model.dart';
import 'package:shiksha_darpan/models/pgi_model.dart';
import 'package:shiksha_darpan/models/assessment_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // --- COMPLAINTS & ESCALATIONS ---
  
  /// Submits a new complaint to the database.
  Future<void> submitComplaint(ComplaintModel complaint) async {
    try {
      await _firestore
          .collection('complaints')
          .doc(complaint.id)
          .set(complaint.toJson());
    } catch (e) {
      throw Exception('Failed to submit complaint: $e');
    }
  }

  /// Fetches complaints that have been escalated to a specific administrative level.
  Stream<List<ComplaintModel>> getEscalatedComplaints(AdministrativeLevel level) {
    return _firestore
        .collection('complaints')
        .where('currentEscalationLevel', isEqualTo: level.toString().split('.').last)
        .where('status', isNotEqualTo: ComplaintStatus.resolved.toString().split('.').last)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ComplaintModel.fromJson(doc.data()))
            .toList());
  }

  /// Updates the status or escalates a complaint to the next level.
  Future<void> updateComplaintStatus(String complaintId, ComplaintStatus status, AdministrativeLevel? nextLevel) async {
    Map<String, dynamic> updates = {
      'status': status.toString().split('.').last,
    };
    
    if (nextLevel != null) {
      updates['currentEscalationLevel'] = nextLevel.toString().split('.').last;
    }

    try {
      await _firestore.collection('complaints').doc(complaintId).update(updates);
    } catch (e) {
      throw Exception('Failed to update complaint: $e');
    }
  }

  /// Simulates a daily cron job to auto-escalate complaints exceeding 7-day SLA per level
  Future<void> runAutoEscalationJob() async {
    try {
      final now = DateTime.now();
      final snapshot = await _firestore
          .collection('complaints')
          .where('status', isNotEqualTo: ComplaintStatus.resolved.toString().split('.').last)
          .get();

      for (var doc in snapshot.docs) {
        final complaint = ComplaintModel.fromJson(doc.data());
        
        // Simple logic: 7 days SLA per level. 
        final daysSinceSubmission = now.difference(complaint.submittedDate).inDays;
        
        AdministrativeLevel targetLevel = AdministrativeLevel.ground;
        if (daysSinceSubmission >= 21) {
          targetLevel = AdministrativeLevel.national;
        } else if (daysSinceSubmission >= 14) {
          targetLevel = AdministrativeLevel.state;
        } else if (daysSinceSubmission >= 7) {
          targetLevel = AdministrativeLevel.intermediate;
        }

        // Ensure we only escalate upwards, not downwards
        if (targetLevel.index > complaint.currentEscalationLevel.index) {
          await updateComplaintStatus(
            complaint.id, 
            ComplaintStatus.escalated, 
            targetLevel,
          );
        }
      }
    } catch (e) {
      throw Exception('Failed to run auto-escalation: $e');
    }
  }

  // --- USER DATA ---

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user profile: $e');
    }
  }

  Future<void> createUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toJson());
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  // --- ATTENDANCE (Teacher Check-in) ---

  /// Records daily check-in timestamp and location for a teacher
  Future<void> logTeacherCheckin(String uid, DateTime timestamp) async {
    try {
      await _firestore.collection('attendance').add({
        'teacherId': uid,
        'checkinTime': timestamp.toIso8601String(),
        // Real app would include Geolocation data here
      });
    } catch (e) {
      throw Exception('Failed to log attendance: $e');
    }
  }

  // --- LESSON LOGS ---

  Future<void> submitLessonLog(LessonLogModel log) async {
    try {
      await _firestore.collection('lesson_logs').doc(log.id).set(log.toJson());
    } catch (e) {
      throw Exception('Failed to submit lesson log: $e');
    }
  }

  Stream<List<LessonLogModel>> getTeacherLessonLogs(String teacherId) {
    return _firestore
        .collection('lesson_logs')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => LessonLogModel.fromJson(doc.data())).toList());
  }

  // --- TEACHER RATINGS ---

  Future<void> submitTeacherRating(TeacherRatingModel rating) async {
    try {
      await _firestore.collection('teacher_ratings').doc(rating.id).set(rating.toJson());
    } catch (e) {
      throw Exception('Failed to submit teacher rating: $e');
    }
  }

  Stream<List<TeacherRatingModel>> getTeacherRatings(String teacherId) {
    return _firestore
        .collection('teacher_ratings')
        .where('teacherId', isEqualTo: teacherId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => TeacherRatingModel.fromJson(doc.data())).toList());
  }

  // --- PGI SCORE TRACKING ---

  /// Seed the database with some initial mock PGI data for demonstration
  Future<void> seedMockPgiData() async {
    final mockScores = [
      PgiScoreModel(districtId: 'Pune', stateId: 'Maharashtra', year: 2026, learningOutcomes: 160, access: 70, infrastructure: 140, equity: 210, governanceProcess: 320),
      PgiScoreModel(districtId: 'Mumbai', stateId: 'Maharashtra', year: 2026, learningOutcomes: 155, access: 75, infrastructure: 145, equity: 220, governanceProcess: 330),
      PgiScoreModel(districtId: 'Nagpur', stateId: 'Maharashtra', year: 2026, learningOutcomes: 140, access: 65, infrastructure: 120, equity: 190, governanceProcess: 280),
      PgiScoreModel(districtId: 'Amritsar', stateId: 'Punjab', year: 2026, learningOutcomes: 165, access: 78, infrastructure: 142, equity: 225, governanceProcess: 340),
      PgiScoreModel(districtId: 'Ludhiana', stateId: 'Punjab', year: 2026, learningOutcomes: 158, access: 72, infrastructure: 138, equity: 215, governanceProcess: 310),
      PgiScoreModel(districtId: 'Ernakulam', stateId: 'Kerala', year: 2026, learningOutcomes: 175, access: 79, infrastructure: 148, equity: 228, governanceProcess: 350),
    ];

    final batch = _firestore.batch();
    for (var score in mockScores) {
      final docRef = _firestore.collection('pgi_scores').doc('${score.stateId}_${score.districtId}_${score.year}');
      batch.set(docRef, score.toJson());
    }
    
    try {
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to seed PGI data: $e');
    }
  }

  /// Get PGI scores for all districts in a state for a specific year
  Stream<List<PgiScoreModel>> streamStateDistrictPgiScores(String stateId, {int year = 2026}) {
    return _firestore
        .collection('pgi_scores')
        .where('stateId', isEqualTo: stateId)
        .where('year', isEqualTo: year)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PgiScoreModel.fromJson(doc.data())).toList());
  }

  /// Get all PGI scores for national aggregation
  Stream<List<PgiScoreModel>> streamNationalPgiScores({int year = 2026}) {
    return _firestore
        .collection('pgi_scores')
        .where('year', isEqualTo: year)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => PgiScoreModel.fromJson(doc.data())).toList());
  }

  // --- ASSESSMENT & COMPETENCY TRACKING ---

  /// Seed the database with mock Assessment data (NAS and NIPUN Bharat)
  Future<void> seedMockAssessmentData() async {
    final List<AssessmentModel> mockAssessments = [
      // NIPUN Bharat (Foundational Literacy and Numeracy)
      AssessmentModel(id: 'a1', studentApaarId: 'S001', type: AssessmentType.nipunBharat, assessmentDate: DateTime.now(), scores: {'literacy': 75, 'numeracy': 60}, meetsNipunStandard: true),
      AssessmentModel(id: 'a2', studentApaarId: 'S002', type: AssessmentType.nipunBharat, assessmentDate: DateTime.now(), scores: {'literacy': 45, 'numeracy': 55}, meetsNipunStandard: false),
      AssessmentModel(id: 'a3', studentApaarId: 'S003', type: AssessmentType.nipunBharat, assessmentDate: DateTime.now(), scores: {'literacy': 85, 'numeracy': 70}, meetsNipunStandard: true),
      AssessmentModel(id: 'a4', studentApaarId: 'S004', type: AssessmentType.nipunBharat, assessmentDate: DateTime.now(), scores: {'literacy': 65, 'numeracy': 65}, meetsNipunStandard: true),
      
      // NAS (National Achievement Survey)
      // Class 3
      AssessmentModel(id: 'n1', studentApaarId: 'S101', type: AssessmentType.nas, assessmentDate: DateTime.now(), scores: {'class': 3, 'average': 78}),
      AssessmentModel(id: 'n2', studentApaarId: 'S102', type: AssessmentType.nas, assessmentDate: DateTime.now(), scores: {'class': 3, 'average': 68}),
      // Class 5
      AssessmentModel(id: 'n3', studentApaarId: 'S201', type: AssessmentType.nas, assessmentDate: DateTime.now(), scores: {'class': 5, 'average': 60}),
      AssessmentModel(id: 'n4', studentApaarId: 'S202', type: AssessmentType.nas, assessmentDate: DateTime.now(), scores: {'class': 5, 'average': 70}),
      // Class 8
      AssessmentModel(id: 'n5', studentApaarId: 'S301', type: AssessmentType.nas, assessmentDate: DateTime.now(), scores: {'class': 8, 'average': 55}),
      AssessmentModel(id: 'n6', studentApaarId: 'S302', type: AssessmentType.nas, assessmentDate: DateTime.now(), scores: {'class': 8, 'average': 48}),
      // Class 10
      AssessmentModel(id: 'n7', studentApaarId: 'S401', type: AssessmentType.nas, assessmentDate: DateTime.now(), scores: {'class': 10, 'average': 40}),
      AssessmentModel(id: 'n8', studentApaarId: 'S402', type: AssessmentType.nas, assessmentDate: DateTime.now(), scores: {'class': 10, 'average': 50}),
    ];

    final batch = _firestore.batch();
    for (var assessment in mockAssessments) {
      final docRef = _firestore.collection('assessments').doc(assessment.id);
      batch.set(docRef, assessment.toJson());
    }
    
    try {
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to seed Assessment data: $e');
    }
  }

  /// Get all assessment scores for national aggregation
  Stream<List<AssessmentModel>> streamNationalAssessments() {
    return _firestore
        .collection('assessments')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => AssessmentModel.fromJson(doc.data())).toList());
  }
}
