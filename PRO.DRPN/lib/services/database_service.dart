import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shiksha_darpan/models/complaint_model.dart';
import 'package:shiksha_darpan/models/user_model.dart';
import 'package:shiksha_darpan/models/lesson_log_model.dart';
import 'package:shiksha_darpan/models/teacher_rating_model.dart';

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

  // --- USER DATA ---

  /// Retrieves user profile based on Firebase UID.
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

  /// Retrieves user profile by email address.
  /// Used for first-time Google login to find pre-registered accounts.
  Future<UserModel?> getUserProfileByEmail(String email) async {
    if (email.isEmpty) return null;
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase().trim())
          .limit(1)
          .get();
      if (snapshot.docs.isNotEmpty) {
        return UserModel.fromJson(snapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user profile by email: $e');
    }
  }

  /// Links a Google sign-in to a pre-registered profile.
  /// Migrates the existing email-keyed doc to a Firebase-UID-keyed doc,
  /// then removes the old stub so lookups are always O(1) by UID.
  Future<void> linkGoogleAccount({
    required String email,
    required String newUid,
    String? photoUrl,
    String? displayName,
  }) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase().trim())
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return;

      final oldDoc = snapshot.docs.first;
      final data = Map<String, dynamic>.from(oldDoc.data());

      // Populate Google-provided fields
      data['id'] = newUid;
      data['googleId'] = newUid;
      data['profilePicture'] = photoUrl;
      if (displayName != null && (data['name'] == null || (data['name'] as String).trim().isEmpty)) {
        data['name'] = displayName;
      }
      // Normalise email casing
      data['email'] = email.toLowerCase().trim();

      final batch = _firestore.batch();
      // Write new UID-keyed document
      batch.set(_firestore.collection('users').doc(newUid), data);
      // Remove old stub if it had a different doc ID
      if (oldDoc.id != newUid) {
        batch.delete(oldDoc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to link Google account: $e');
    }
  }

  /// Creates a new user profile in Firestore
  Future<void> createUserProfile(UserModel user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.id)
          .set(user.toJson());
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
}
