class ClassroomLocation {
  final double latitude;
  final double longitude;
  final double radiusMeters;

  ClassroomLocation({
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 100,
  });

  factory ClassroomLocation.fromJson(Map<String, dynamic> json) {
    return ClassroomLocation(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      radiusMeters: (json['radiusMeters'] as num?)?.toDouble() ?? 100,
    );
  }

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'radiusMeters': radiusMeters,
  };
}

class ClassModel {
  final String id;
  final String subject;
  final String? courseCode;
  final String? room;
  final DateTime startTime;
  final DateTime endTime;
  final String teacherId;
  final String? teacherName;
  final ClassroomLocation? classroomLocation;
  final String dayOfWeek;
  final String? semester;
  final bool isActive;

  ClassModel({
    required this.id,
    required this.subject,
    this.courseCode,
    this.room,
    required this.startTime,
    required this.endTime,
    required this.teacherId,
    this.teacherName,
    this.classroomLocation,
    required this.dayOfWeek,
    this.semester,
    this.isActive = true,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    String teacherId = '';
    String? teacherName;

    if (json['teacherId'] is Map) {
      teacherId = json['teacherId']['_id'] ?? '';
      teacherName = json['teacherId']['name'];
    } else {
      teacherId = json['teacherId'] ?? '';
    }

    return ClassModel(
      id: json['_id'] ?? '',
      subject: json['subject'] ?? '',
      courseCode: json['courseCode'],
      room: json['room'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      teacherId: teacherId,
      teacherName: teacherName,
      classroomLocation: json['classroomLocation'] != null
          ? ClassroomLocation.fromJson(json['classroomLocation'])
          : null,
      dayOfWeek: json['dayOfWeek'] ?? '',
      semester: json['semester'],
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'subject': subject,
    'courseCode': courseCode,
    'room': room,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'teacherId': teacherId,
    'classroomLocation': classroomLocation?.toJson(),
    'dayOfWeek': dayOfWeek,
    'semester': semester,
    'isActive': isActive,
  };

  bool get isUpcoming => startTime.isAfter(DateTime.now());
  bool get isOngoing =>
      DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime);
  bool get hasEnded => endTime.isBefore(DateTime.now());

  Duration get timeUntilStart => startTime.difference(DateTime.now());
}