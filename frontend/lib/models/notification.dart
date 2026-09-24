class AppNotification {
  final String id;
  final String userId;
  final String? classId;
  final String type;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final DateTime? sentAt;
  final String status;
  final DateTime? readAt;
  final Map<String, dynamic> data;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.userId,
    this.classId,
    required this.type,
    required this.title,
    required this.body,
    required this.scheduledAt,
    this.sentAt,
    this.status = 'pending',
    this.readAt,
    this.data = const {},
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      classId: json['classId'],
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      scheduledAt: DateTime.tryParse(json['scheduledAt'] ?? '') ?? DateTime.now(),
      sentAt: json['sentAt'] != null ? DateTime.tryParse(json['sentAt']) : null,
      status: json['status'] ?? 'pending',
      readAt: json['readAt'] != null ? DateTime.tryParse(json['readAt']) : null,
      data: (json['data'] as Map?)?.cast<String, dynamic>() ?? {},
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isRead => status == 'read' || readAt != null;
  bool get isAvailabilityCheck => type == 'availability_check';
  bool get isArrivalConfirmation => type == 'arrival_confirmation';
}