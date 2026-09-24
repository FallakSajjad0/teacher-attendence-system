class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? department;
  final String? employeeId;
  final String? fcmToken;
  final bool isActive;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.department,
    this.employeeId,
    this.fcmToken,
    this.isActive = true,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone'],
      department: json['department'],
      employeeId: json['employeeId'],
      fcmToken: json['fcmToken'],
      isActive: json['isActive'] ?? true,
      lastLogin: json['lastLogin'] != null ? DateTime.tryParse(json['lastLogin']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'email': email,
    'role': role,
    'phone': phone,
    'department': department,
    'employeeId': employeeId,
    'fcmToken': fcmToken,
    'isActive': isActive,
    'lastLogin': lastLogin?.toIso8601String(),
  };

  bool get isTeacher => role == 'teacher';
  bool get isManagement => role == 'management';
  bool get isAdmin => role == 'admin';
  bool get isFaculty => role == 'faculty';

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}