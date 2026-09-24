class AppConstants {
  static const String appName = 'Attendance Verification';

  // Roles
  static const String roleAdmin = 'admin';
  static const String roleManagement = 'management';
  static const String roleFaculty = 'faculty';
  static const String roleTeacher = 'teacher';

  // Attendance statuses
  static const String statusPending = 'pending';
  static const String statusAvailable = 'available';
  static const String statusNotAvailable = 'not_available';
  static const String statusArrived = 'arrived';
  static const String statusEvidenceSubmitted = 'evidence_submitted';
  static const String statusVerified = 'verified';
  static const String statusAbsent = 'absent';

  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String fcmTokenKey = 'fcm_token';
}