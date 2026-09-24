import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../utils/date_utils.dart';
import '../../widgets/common_widgets.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading && prov.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (prov.notifications.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => prov.fetchNotifications(),
            child: ListView(
              children: const [
                SizedBox(height: 120),
                EmptyState(
                  icon: Icons.notifications_none,
                  title: 'No alerts',
                  subtitle: 'Alerts will appear here when teachers are late or absent',
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => prov.fetchNotifications(),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: prov.notifications.length,
            itemBuilder: (context, i) {
              final n = prov.notifications[i];
              final isAbsence = n.type.contains('absent') ||
                  n.type.contains('absence') ||
                  n.type.contains('late');
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        (isAbsence ? Colors.red : Colors.blue).withValues(alpha: 0.12),
                    child: Icon(
                      isAbsence ? Icons.warning_amber : Icons.info_outline,
                      color: isAbsence ? Colors.red : Colors.blue,
                    ),
                  ),
                  title: Text(
                    n.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(n.body, style: const TextStyle(fontSize: 13)),
                      const SizedBox(height: 4),
                      Text(
                        AppDateUtils.timeAgo(n.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}