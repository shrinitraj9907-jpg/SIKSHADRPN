// lib/models/library_model.dart

enum BookStatus { available, issued, lost, damaged }

class LibraryBookModel {
  final String id;
  final String title;
  final String author;
  final String? isbn;
  final String subject;
  final String schoolUdise;
  final int totalCopies;
  final int availableCopies;
  final BookStatus status;

  LibraryBookModel({
    required this.id,
    required this.title,
    required this.author,
    this.isbn,
    required this.subject,
    required this.schoolUdise,
    this.totalCopies = 1,
    this.availableCopies = 1,
    this.status = BookStatus.available,
  });

  factory LibraryBookModel.fromJson(Map<String, dynamic> json,
      {String? docId}) {
    return LibraryBookModel(
      id: docId ?? json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      isbn: json['isbn'],
      subject: json['subject'] ?? '',
      schoolUdise: json['schoolUdise'] ?? '',
      totalCopies: json['totalCopies'] ?? 1,
      availableCopies: json['availableCopies'] ?? 1,
      status: BookStatus.values.firstWhere((e) => e.name == json['status'],
          orElse: () => BookStatus.available),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'isbn': isbn,
        'subject': subject,
        'schoolUdise': schoolUdise,
        'totalCopies': totalCopies,
        'availableCopies': availableCopies,
        'status': status.name,
      };
}

class BookIssueModel {
  final String id;
  final String bookId;
  final String bookTitle;
  final String studentId;
  final String studentName;
  final String schoolUdise;
  final DateTime issueDate;
  final DateTime dueDate;
  DateTime? returnDate;
  final double finePerDay; // default ₹1

  BookIssueModel({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.studentId,
    required this.studentName,
    required this.schoolUdise,
    required this.issueDate,
    required this.dueDate,
    this.returnDate,
    this.finePerDay = 1.0,
  });

  bool get isOverdue =>
      returnDate == null && DateTime.now().isAfter(dueDate);

  double get currentFine {
    if (!isOverdue) return 0;
    final overdueDays = DateTime.now().difference(dueDate).inDays;
    return overdueDays * finePerDay;
  }

  double get totalFine {
    if (returnDate == null) return currentFine;
    if (!returnDate!.isAfter(dueDate)) return 0;
    final overdueDays = returnDate!.difference(dueDate).inDays;
    return overdueDays * finePerDay;
  }

  factory BookIssueModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    return BookIssueModel(
      id: docId ?? json['id'] ?? '',
      bookId: json['bookId'] ?? '',
      bookTitle: json['bookTitle'] ?? '',
      studentId: json['studentId'] ?? '',
      studentName: json['studentName'] ?? '',
      schoolUdise: json['schoolUdise'] ?? '',
      issueDate: DateTime.tryParse(json['issueDate'] ?? '') ?? DateTime.now(),
      dueDate: DateTime.tryParse(json['dueDate'] ?? '') ??
          DateTime.now().add(const Duration(days: 14)),
      returnDate: json['returnDate'] != null
          ? DateTime.tryParse(json['returnDate'])
          : null,
      finePerDay: (json['finePerDay'] as num?)?.toDouble() ?? 1.0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bookId': bookId,
        'bookTitle': bookTitle,
        'studentId': studentId,
        'studentName': studentName,
        'schoolUdise': schoolUdise,
        'issueDate': issueDate.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'returnDate': returnDate?.toIso8601String(),
        'finePerDay': finePerDay,
      };
}
