// lib/services/communication_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shiksha_darpan/models/announcement_model.dart';

class DirectMessage {
  final String id;
  final String fromId;
  final String fromName;
  final String toId;
  final String toName;
  final String body;
  final DateTime sentAt;
  final bool isRead;
  final String? attachmentUrl;

  DirectMessage({
    required this.id,
    required this.fromId,
    required this.fromName,
    required this.toId,
    required this.toName,
    required this.body,
    required this.sentAt,
    this.isRead = false,
    this.attachmentUrl,
  });

  factory DirectMessage.fromJson(Map<String, dynamic> json,
      {String? docId}) {
    return DirectMessage(
      id: docId ?? json['id'] ?? '',
      fromId: json['fromId'] ?? '',
      fromName: json['fromName'] ?? '',
      toId: json['toId'] ?? '',
      toName: json['toName'] ?? '',
      body: json['body'] ?? '',
      sentAt: DateTime.tryParse(json['sentAt'] ?? '') ?? DateTime.now(),
      isRead: json['isRead'] ?? false,
      attachmentUrl: json['attachmentUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'fromId': fromId,
        'fromName': fromName,
        'toId': toId,
        'toName': toName,
        'body': body,
        'sentAt': sentAt.toIso8601String(),
        'isRead': isRead,
        'attachmentUrl': attachmentUrl,
      };
}

class CommunicationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _announcements =>
      _db.collection('announcements');

  CollectionReference<Map<String, dynamic>> get _messages =>
      _db.collection('direct_messages');

  // ── Announcements ─────────────────────────────────────────────────────────

  Future<void> postAnnouncement(AnnouncementModel announcement) async {
    await _announcements.doc(announcement.id).set(announcement.toJson());
  }

  Stream<List<AnnouncementModel>> streamSchoolAnnouncements(
      String schoolUdise) {
    return _announcements
        .where('schoolUdise', isEqualTo: schoolUdise)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => AnnouncementModel.fromJson(d.data(), docId: d.id))
            .toList());
  }

  Future<void> deleteAnnouncement(String announcementId) async {
    await _announcements.doc(announcementId).delete();
  }

  // ── Direct Messages ───────────────────────────────────────────────────────

  Future<void> sendMessage(DirectMessage message) async {
    await _messages.doc(message.id).set(message.toJson());
  }

  Stream<List<DirectMessage>> streamConversation(
      String userId1, String userId2) {
    return _messages
        .where('fromId', whereIn: [userId1, userId2])
        .orderBy('sentAt', descending: true)
        .limit(100)
        .snapshots()
        .map((snap) {
          return snap.docs
              .where((d) {
                final data = d.data();
                final from = data['fromId'] as String;
                final to = data['toId'] as String;
                return (from == userId1 && to == userId2) ||
                    (from == userId2 && to == userId1);
              })
              .map((d) => DirectMessage.fromJson(d.data(), docId: d.id))
              .toList();
        });
  }

  Stream<List<DirectMessage>> streamInbox(String userId) {
    return _messages
        .where('toId', isEqualTo: userId)
        .orderBy('sentAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => DirectMessage.fromJson(d.data(), docId: d.id))
            .toList());
  }

  Future<void> markMessageRead(String messageId) async {
    await _messages.doc(messageId).update({'isRead': true});
  }
}
