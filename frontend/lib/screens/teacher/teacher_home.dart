import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/class_model.dart';
import '../../models/attendance.dart';
import '../../providers/auth_provider.dart';
import '../../providers/class_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/notification_provider.dart';
import '../../services/socket_service.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';
import '../../widgets/common_widgets.dart';
import 'class_detail.dart';
import 'attendance_history.dart';
import '../login_screen.dart';

class TeacherHome extends StatefulWidget {
  const TeacherHome({super.key});

  @override
  State<TeacherHome> createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  final SocketService _socket = SocketService();
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _setupSocket();
    });
  }

  void _loadData() {
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      context.read<ClassProvider>().fetchTodayClasses();
      context.read<AttendanceProvider>().fetchMyAttendance();
      context.read<NotificationProvider>().fetchUnreadCount();
    }
  }

  void _setupSocket() {
    _socket.on('notification_received', (data) {
      if (!mounted) return;
      context.read<NotificationProvider>().fetchUnreadCount();
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['notification']?['title'] ?? 'New notification'),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );
    });

    _socket.on('verification_update', (_) => _loadData());
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthProvider>().logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Classes'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (_, notif, __) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    onPressed: () {
                      notif.fetchNotifications();
                      _showNotifications();
                    },
                  ),
                  if (notif.unreadCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          '${notif.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _currentIndex == 0 ? _buildClassesTab() : const AttendanceHistory(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.class_outlined),
            activeIcon: Icon(Icons.class_),
            label: 'Classes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }

  Widget _buildClassesTab() {
    return Consumer2<ClassProvider, AttendanceProvider>(
      builder: (context, classProv, attProv, _) {
        if (classProv.isLoading && classProv.todayClasses.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (classProv.todayClasses.isEmpty) {
          return RefreshIndicator(
            onRefresh: () async => _loadData(),
            child: ListView(
              children: const [
                SizedBox(height: 120),
                EmptyState(
                  icon: Icons.event_busy,
                  title: 'No Classes Today',
                  subtitle: 'You have no scheduled classes today.',
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: classProv.todayClasses.length,
            itemBuilder: (context, index) {
              final cls = classProv.todayClasses[index];
              final attendance = _findAttendance(attProv.myAttendance, cls.id);

              return _TeacherClassCard(
                classData: cls,
                attendance: attendance,
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ClassDetailScreen(
                        classData: cls,
                        attendance: attendance,
                      ),
                    ),
                  );
                  _loadData();
                },
              );
            },
          ),
        );
      },
    );
  }

  Attendance? _findAttendance(List<Attendance> list, String classId) {
    try {
      return list.firstWhere((a) => a.classData?.id == classId);
    } catch (_) {
      return null;
    }
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Consumer<NotificationProvider>(
        builder: (context, prov, _) {
          if (prov.isLoading) {
            return const SizedBox(
              height: 300,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (prov.notifications.isEmpty) {
            return const SizedBox(
              height: 300,
              child: EmptyState(
                icon: Icons.notifications_none,
                title: 'No Notifications',
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(16),
            itemCount: prov.notifications.length,
            itemBuilder: (context, i) {
              final n = prov.notifications[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: n.isRead
                      ? Colors.grey.shade200
                      : Theme.of(context).primaryColor.withValues(alpha: 0.15),
                  child: Icon(
                    n.isAvailabilityCheck
                        ? Icons.event_available
                        : Icons.notifications_active,
                    color: n.isRead
                        ? Colors.grey
                        : Theme.of(context).primaryColor,
                  ),
                ),
                title: Text(
                  n.title,
                  style: TextStyle(
                    fontWeight: n.isRead ? FontWeight.normal : FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(n.body, style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      AppDateUtils.timeAgo(n.createdAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                onTap: () => prov.markAsRead(n.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _TeacherClassCard extends StatelessWidget {
  final ClassModel classData;
  final Attendance? attendance;
  final VoidCallback onTap;

  const _TeacherClassCard({
    required this.classData,
    required this.attendance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      classData.subject,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (attendance != null) StatusChip(status: attendance!.status),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.access_time,
                      size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    '${AppDateUtils.formatTime(classData.startTime)} - ${AppDateUtils.formatTime(classData.endTime)}',
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  ),
                ],
              ),
              if (classData.room != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.room_outlined,
                        size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      classData.room!,
                      style:
                          TextStyle(fontSize: 13, color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _ActionHint(
                      icon: _iconForStatus(),
                      text: _textForStatus(),
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _iconForStatus() {
    if (attendance == null) return Icons.hourglass_empty;
    switch (attendance!.status) {
      case AppConstants.statusPending:
        return Icons.pending_actions;
      case AppConstants.statusAvailable:
        return Icons.event_available;
      case AppConstants.statusNotAvailable:
        return Icons.event_busy;
      case AppConstants.statusArrived:
        return Icons.location_on;
      case AppConstants.statusEvidenceSubmitted:
        return Icons.camera_alt;
      case AppConstants.statusVerified:
        return Icons.verified;
      case AppConstants.statusAbsent:
        return Icons.cancel;
      default:
        return Icons.info_outline;
    }
  }

  String _textForStatus() {
    if (attendance == null) return 'Waiting for notification...';
    switch (attendance!.status) {
      case AppConstants.statusPending:
        return 'Tap to respond to availability';
      case AppConstants.statusAvailable:
        return 'Confirm arrival at class start';
      case AppConstants.statusNotAvailable:
        return 'You marked yourself unavailable';
      case AppConstants.statusArrived:
        return 'Tap to capture classroom photo';
      case AppConstants.statusEvidenceSubmitted:
        return 'Awaiting management verification';
      case AppConstants.statusVerified:
        return 'Verified - attendance confirmed';
      case AppConstants.statusAbsent:
        return 'Marked absent';
      default:
        return 'Tap to view details';
    }
  }
}

class _ActionHint extends StatelessWidget {
  final IconData icon;
  final String text;

  const _ActionHint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}