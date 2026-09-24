import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/class_model.dart';
import '../../models/attendance.dart';
import '../../providers/class_provider.dart';
import '../../providers/attendance_provider.dart';
import '../../utils/date_utils.dart';
import '../../widgets/common_widgets.dart';

class AttendanceMonitorScreen extends StatefulWidget {
  final String? classId;

  const AttendanceMonitorScreen({super.key, this.classId});

  @override
  State<AttendanceMonitorScreen> createState() =>
      _AttendanceMonitorScreenState();
}

class _AttendanceMonitorScreenState extends State<AttendanceMonitorScreen> {
  String? _selectedClassId;

  @override
  void initState() {
    super.initState();
    _selectedClassId = widget.classId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final classProv = context.read<ClassProvider>();
      if (classProv.classes.isEmpty) {
        classProv.fetchClasses();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ClassProvider>(
      builder: (context, classProv, _) {
        if (classProv.isLoading && classProv.classes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedClassId,
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: 'Select Class',
                  prefixIcon: Icon(Icons.class_outlined),
                ),
                items: classProv.classes
                    .map(
                      (c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(
                          '${c.subject} • ${AppDateUtils.formatTime(c.startTime)}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedClassId = v),
              ),
            ),
            Expanded(
              child: _selectedClassId == null
                  ? const EmptyState(
                      icon: Icons.class_outlined,
                      title: 'Select a class',
                      subtitle: 'Choose a class to view attendance records',
                    )
                  : _buildRecords(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecords() {
    return FutureBuilder<List<Attendance>>(
      future: context
          .read<AttendanceProvider>()
          .getAttendanceByClass(_selectedClassId!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final records = snapshot.data ?? [];

        if (records.isEmpty) {
          return const EmptyState(
            icon: Icons.inbox,
            title: 'No records yet',
            subtitle: 'Attendance records will appear as teachers respond',
          );
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() {}),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: records.length,
            itemBuilder: (context, i) {
              final r = records[i];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            child: Text(
                              _initials(r.teacherName ?? 'T'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  r.teacherName ?? 'Teacher',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                if (r.teacherEmail != null)
                                  Text(
                                    r.teacherEmail!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          StatusChip(status: r.status),
                        ],
                      ),
                      if (r.location?.distanceFromClassroom != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              r.location!.isWithinRadius == true
                                  ? Icons.check_circle
                                  : Icons.warning_amber,
                              size: 16,
                              color: r.location!.isWithinRadius == true
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${r.location!.distanceFromClassroom!.toInt()}m from classroom',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
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

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
  }
}