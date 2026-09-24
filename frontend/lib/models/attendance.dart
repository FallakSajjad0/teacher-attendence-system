import 'package:teacher_attendance_app/models/class_model.dart';

class AttendanceLocation {
  final double? latitude;
  final double? longitude;
  final double? accuracy;
  final DateTime? capturedAt;
  final bool? isWithinRadius;
  final double? distanceFromClassroom;

  AttendanceLocation({
    this.latitude,
    this.longitude,
    this.accuracy,
    this.capturedAt,
    this.isWithinRadius,
    this.distanceFromClassroom,
  });

  factory AttendanceLocation.fromJson(Map<String, dynamic> json) {
    return AttendanceLocation(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble(),
      capturedAt: json['capturedAt'] != null
          ? DateTime.tryParse(json['capturedAt'])
          : null,
      isWithinRadius: json['isWithinRadius'],
      distanceFromClassroom:
          (json['distanceFromClassroom'] as num?)?.toDouble(),
    );
  }
}

class Attendance {
  final String id;
  final String userId;
  final ClassModel? classData;
  final String status;
  final DateTime? availabilityResponseAt;
  final DateTime? arrivalConfirmedAt;
  final AttendanceLocation? location;
  final String? photoId;
  final Map<String, dynamic>? photo;
  final String verificationStatus;
  final String? verificationNotes;
  final bool isAbsent;
  final DateTime? createdAt;
  final String? teacherName;
  final String? teacherEmail;

  Attendance({
    required this.id,
    required this.userId,
    this.classData,
    required this.status,
    this.availabilityResponseAt,
    this.arrivalConfirmedAt,
    this.location,
    this.photoId,
    this.photo,
    this.verificationStatus = 'pending',
    this.verificationNotes,
    this.isAbsent = false,
    this.createdAt,
    this.teacherName,
    this.teacherEmail,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    String? teacherName;
    String? teacherEmail;
    if (json['userId'] is Map) {
      teacherName = json['userId']['name'];
      teacherEmail = json['userId']['email'];
    }

    return Attendance(
      id: json['_id'] ?? '',
      userId: json['userId'] is Map
          ? (json['userId']['_id'] ?? '')
          : (json['userId'] ?? ''),
      classData: json['classId'] is Map
          ? ClassModel.fromJson(json['classId'])
          : null,
      status: json['status'] ?? 'pending',
      availabilityResponseAt: json['availabilityResponseAt'] != null
          ? DateTime.tryParse(json['availabilityResponseAt'])
          : null,
      arrivalConfirmedAt: json['arrivalConfirmedAt'] != null
          ? DateTime.tryParse(json['arrivalConfirmedAt'])
          : null,
      location: json['location'] != null &&
              json['location'] is Map &&
              json['location']['capturedAt'] != null
          ? AttendanceLocation.fromJson(json['location'])
          : null,
      photoId: json['photoId'] is Map
          ? json['photoId']['_id']
          : json['photoId'],
      photo: json['photoId'] is Map ? json['photoId'] : null,
      verificationStatus: json['verificationStatus'] ?? 'pending',
      verificationNotes: json['verificationNotes'],
      isAbsent: json['isAbsent'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      teacherName: teacherName,
      teacherEmail: teacherEmail,
    );
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'available':
        return 'Available';
      case 'not_available':
        return 'Not Available';
      case 'arrived':
        return 'Arrived';
      case 'evidence_submitted':
        return 'Evidence Submitted';
      case 'verified':
        return 'Verified';
      case 'absent':
        return 'Absent';
      default:
        return status;
    }
  }
}