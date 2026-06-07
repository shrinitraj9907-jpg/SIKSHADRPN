// lib/services/fee_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shiksha_darpan/models/fee_model.dart';

class FeeService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _feeStructures(
          String schoolUdise) =>
      _db
          .collection('schools')
          .doc(schoolUdise)
          .collection('fee_structures');

  CollectionReference<Map<String, dynamic>> get _payments =>
      _db.collection('fee_payments');

  // ── Fee Structure ─────────────────────────────────────────────────────────

  Future<void> setFeeStructure(
      String schoolUdise, FeeStructureModel structure) async {
    await _feeStructures(schoolUdise)
        .doc(structure.id)
        .set(structure.toJson());
  }

  Stream<List<FeeStructureModel>> streamFeeStructures(
      String schoolUdise, int academicYear) {
    return _feeStructures(schoolUdise)
        .where('academicYear', isEqualTo: academicYear)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => FeeStructureModel.fromJson(d.data(), docId: d.id))
            .toList());
  }

  Future<FeeStructureModel?> getFeeStructureForGrade(
      String schoolUdise, int grade, int academicYear) async {
    final snap = await _feeStructures(schoolUdise)
        .where('grade', isEqualTo: grade)
        .where('academicYear', isEqualTo: academicYear)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return FeeStructureModel.fromJson(snap.docs.first.data(),
        docId: snap.docs.first.id);
  }

  // ── Fee Payments ──────────────────────────────────────────────────────────

  Stream<List<FeePaymentModel>> streamStudentFees(
      String studentId, int academicYear) {
    return _payments
        .where('studentId', isEqualTo: studentId)
        .where('academicYear', isEqualTo: academicYear)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => FeePaymentModel.fromJson(d.data(), docId: d.id))
            .toList());
  }

  Stream<List<FeePaymentModel>> streamSchoolFees(
      String schoolUdise, int academicYear) {
    return _payments
        .where('schoolUdise', isEqualTo: schoolUdise)
        .where('academicYear', isEqualTo: academicYear)
        .orderBy('studentName')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => FeePaymentModel.fromJson(d.data(), docId: d.id))
            .toList());
  }

  Stream<List<FeePaymentModel>> streamOverdueFees(
      String schoolUdise, int academicYear) {
    return _payments
        .where('schoolUdise', isEqualTo: schoolUdise)
        .where('academicYear', isEqualTo: academicYear)
        .where('status', whereIn: [FeeStatus.pending.name, FeeStatus.partial.name])
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => FeePaymentModel.fromJson(d.data(), docId: d.id))
            .toList());
  }

  Future<void> createFeeRecord(FeePaymentModel payment) async {
    await _payments.doc(payment.id).set(payment.toJson());
  }

  Future<void> updatePayment(FeePaymentModel payment) async {
    await _payments.doc(payment.id).update(payment.toJson());
  }

  Future<void> markFeePaid(
      String paymentId, double amountPaid, String receiptNumber) async {
    final doc = await _payments.doc(paymentId).get();
    if (!doc.exists) return;
    final payment = FeePaymentModel.fromJson(doc.data()!, docId: paymentId);
    final newPaid = payment.paidAmount + amountPaid;
    final totalDue =
        payment.totalAmount - (payment.scholarshipAmount ?? 0);
    final newStatus = newPaid >= totalDue
        ? FeeStatus.paid
        : newPaid > 0
            ? FeeStatus.partial
            : FeeStatus.pending;
    await _payments.doc(paymentId).update({
      'paidAmount': newPaid,
      'status': newStatus.name,
      'paidDate': DateTime.now().toIso8601String(),
      'receiptNumber': receiptNumber,
    });
  }

  // ── Seed default fee structure ─────────────────────────────────────────────

  Future<void> seedDefaultFeeStructures(
      String schoolUdise, int academicYear) async {
    final batch = _db.batch();
    final structures = [
      for (int grade = 1; grade <= 5; grade++)
        FeeStructureModel(
          id: 'fee_${grade}_$academicYear',
          grade: grade,
          schoolUdise: schoolUdise,
          academicYear: academicYear,
          feeComponents: {
            FeeType.tuition: 1200,
            FeeType.library: 200,
            FeeType.sports: 300,
            FeeType.examination: 100,
          },
        ),
      for (int grade = 6; grade <= 8; grade++)
        FeeStructureModel(
          id: 'fee_${grade}_$academicYear',
          grade: grade,
          schoolUdise: schoolUdise,
          academicYear: academicYear,
          feeComponents: {
            FeeType.tuition: 1800,
            FeeType.library: 250,
            FeeType.sports: 400,
            FeeType.examination: 150,
          },
        ),
      for (int grade = 9; grade <= 10; grade++)
        FeeStructureModel(
          id: 'fee_${grade}_$academicYear',
          grade: grade,
          schoolUdise: schoolUdise,
          academicYear: academicYear,
          feeComponents: {
            FeeType.tuition: 2400,
            FeeType.library: 300,
            FeeType.sports: 500,
            FeeType.examination: 200,
          },
        ),
      for (int grade = 11; grade <= 12; grade++)
        FeeStructureModel(
          id: 'fee_${grade}_$academicYear',
          grade: grade,
          schoolUdise: schoolUdise,
          academicYear: academicYear,
          feeComponents: {
            FeeType.tuition: 3000,
            FeeType.library: 350,
            FeeType.sports: 600,
            FeeType.examination: 250,
          },
        ),
    ];

    for (final s in structures) {
      batch.set(_feeStructures(schoolUdise).doc(s.id), s.toJson());
    }
    await batch.commit();
  }
}
