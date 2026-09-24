import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/class_provider.dart';
import '../../services/socket_service.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/class_card.dart';
import 'attendance_monitor.dart';
import 'photo_verification.dart';
import 'alerts_screen.dart';
import '../login_screen.dart';

class ManagementDashboard extends StatefulWidget {
  const ManagementDashboard({super.key});

  @override
  State<ManagementDashboard> createState() => _ManagementDashboardState();
}

class _ManagementDashboardState extends State<ManagementDashboard> {
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
    context.read<AttendanceProvider>().fetchDashboardStats();
    context.read<AttendanceProvider>().fetchPendingVerifications();
    context.read<ClassProvider>().fetchTodayClasses();
  }

  void _setupSocket() {
    _socket.on('new_alert', (data) {
      if (!mounted) return;
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['title'] ?? 'New alert'),
          backgroundColor: Colors.red.shade600,
          duration: const Duration(seconds: 4),
        ),
      );
    });

    _socket.on('photo_submitted', (_) => _loadData());
    _socket.on('attendance_update', (_) => _loadData());
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildOverview(),
      const AttendanceMonitorScreen(),
      const PhotoVerificationScreen(),
      const AlertsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Management Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Overview',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monitor_heart_outlined),
            activeIcon: Icon(Icons.monitor_heart),
            label: 'Monitor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library_outlined),
            activeIcon: Icon(Icons.photo_library),
            label: 'Verify',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.warning_amber_outlined),
            activeIcon: Icon(Icons.warning_amber),
            label: 'Alerts',
          ),
        ],
      ),
    );
  }

  Widget _buildOverview() {
    return Consumer2<AttendanceProvider, ClassProvider>(
      builder: (context, attProv, classProv, _) {
        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatsGrid(attProv.dashboardStats),
              const SizedBox(height: 20),
              const Text(
                'Today\'s Classes',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (classProv.todayClasses.isEmpty)
                const EmptyState(
                  icon: Icons.event_busy,
                  title: 'No classes today',
                )
              else
                ...classProv.todayClasses.map(
                  (c) => ClassCard(
                    classData: c,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AttendanceMonitorScreen(classId: c.id),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic>? stats) {
    final total = stats?['total'] ?? 0;
    final present = stats?['present'] ?? 0;
    final absent = stats?['absent'] ?? 0;
    final pending = stats?['pending'] ?? 0;
    final pendingVerification = stats?['pendingVerification'] ?? 0;

    final cards = [
      _StatCard('Total', '$total', Icons.people, Colors.blue),
      _StatCard('Verified', '$present', Icons.verified, Colors.green),
      _StatCard('Absent', '$absent', Icons.cancel, Colors.red),
      _StatCard('Pending', '$pending', Icons.hourglass_empty, Colors.orange),
      _StatCard(
          'To Verify', '$pendingVerification', Icons.photo, Colors.purple),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: cards.map((c) => c).toList(),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icon(icon, color: color, size: 28),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}