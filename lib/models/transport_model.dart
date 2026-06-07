// lib/models/transport_model.dart

class BusRouteModel {
  final String id;
  final String schoolUdise;
  final String routeName;
  final String busNumber;
  final String driverName;
  final String driverPhone;
  final List<BusStopModel> stops;
  final double monthlyFee;

  BusRouteModel({
    required this.id,
    required this.schoolUdise,
    required this.routeName,
    required this.busNumber,
    required this.driverName,
    required this.driverPhone,
    required this.stops,
    required this.monthlyFee,
  });

  factory BusRouteModel.fromJson(Map<String, dynamic> json, {String? docId}) {
    final stopsList = (json['stops'] as List<dynamic>? ?? [])
        .map((s) => BusStopModel.fromJson(s as Map<String, dynamic>))
        .toList();
    return BusRouteModel(
      id: docId ?? json['id'] ?? '',
      schoolUdise: json['schoolUdise'] ?? '',
      routeName: json['routeName'] ?? '',
      busNumber: json['busNumber'] ?? '',
      driverName: json['driverName'] ?? '',
      driverPhone: json['driverPhone'] ?? '',
      stops: stopsList,
      monthlyFee: (json['monthlyFee'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'schoolUdise': schoolUdise,
        'routeName': routeName,
        'busNumber': busNumber,
        'driverName': driverName,
        'driverPhone': driverPhone,
        'stops': stops.map((s) => s.toJson()).toList(),
        'monthlyFee': monthlyFee,
      };
}

class BusStopModel {
  final String name;
  final String arrivalTime; // e.g. "07:30 AM"
  final int sequenceOrder;

  BusStopModel({
    required this.name,
    required this.arrivalTime,
    required this.sequenceOrder,
  });

  factory BusStopModel.fromJson(Map<String, dynamic> json) {
    return BusStopModel(
      name: json['name'] ?? '',
      arrivalTime: json['arrivalTime'] ?? '',
      sequenceOrder: json['sequenceOrder'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'arrivalTime': arrivalTime,
        'sequenceOrder': sequenceOrder,
      };
}

class StudentTransportModel {
  final String id;
  final String studentId;
  final String routeId;
  final String routeName;
  final String stopName;
  final int academicYear;

  StudentTransportModel({
    required this.id,
    required this.studentId,
    required this.routeId,
    required this.routeName,
    required this.stopName,
    required this.academicYear,
  });

  factory StudentTransportModel.fromJson(Map<String, dynamic> json,
      {String? docId}) {
    return StudentTransportModel(
      id: docId ?? json['id'] ?? '',
      studentId: json['studentId'] ?? '',
      routeId: json['routeId'] ?? '',
      routeName: json['routeName'] ?? '',
      stopName: json['stopName'] ?? '',
      academicYear: json['academicYear'] ?? DateTime.now().year,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'routeId': routeId,
        'routeName': routeName,
        'stopName': stopName,
        'academicYear': academicYear,
      };
}
