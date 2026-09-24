import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/attendance_provider.dart';
import '../../utils/date_utils.dart';
import '../../widgets/common_widgets.dart';

class AttendanceHistory extends StatefulWidget {
  const AttendanceHistory({super.key});

  @override
  State<AttendanceHistory> createState() => _AttendanceHistoryState();
}

class _AttendanceHistoryState extends State<AttendanceHistory> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().fetchMyAttendance();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading && prov.myAttendance.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (prov.myAttendance.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => prov.fetchMyAttendance(),
            child: ListView(
              children: const [
                SizedBox(height: 120),
                EmptyState(
                  icon: Icons.history,
                  title: 'No attendance records',
                  subtitle: 'Your attendance history will appear here',
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => prov.fetchMyAttendance(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: prov.myAttendance.length,
            itemBuilder: (context, i) {
              final a = prov.myAttendance[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              a.classData?.subject ?? 'Class',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ),
                          StatusChip(status: a.status),
                        ],
                      ),
                      if (a.classData != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.schedule,
                                size: 15, color: Colors.grey.shade600),
                            const SizedBox(width: 6),
                            Text(
                              AppDateUtils.formatDateTime(
                                  a.classData!.startTime),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (a.createdAt != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Recorded ${AppDateUtils.timeAgo(a.createdAt!)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
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