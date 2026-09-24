import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/attendance.dart';
import '../../providers/attendance_provider.dart';
import '../../utils/date_utils.dart';
import '../../widgets/common_widgets.dart';

class PhotoVerificationScreen extends StatefulWidget {
  const PhotoVerificationScreen({super.key});

  @override
  State<PhotoVerificationScreen> createState() =>
      _PhotoVerificationScreenState();
}

class _PhotoVerificationScreenState extends State<PhotoVerificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AttendanceProvider>().fetchPendingVerifications();
    });
  }

  Future<void> _verify(Attendance a, bool approve) async {
    final notes = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text(approve ? 'Approve Evidence' : 'Reject Evidence'),
          content: TextField(
            controller: controller,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Add notes (optional)',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: Text(approve ? 'Approve' : 'Reject'),
            ),
          ],
        );
      },
    );

    if (notes == null) return;

    final success = await context.read<AttendanceProvider>().verifyAttendance(
          attendanceId: a.id,
          verificationStatus: approve ? 'verified' : 'rejected',
          notes: notes,
        );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Verification saved' : 'Failed to save'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, prov, _) {
        if (prov.isLoading && prov.pendingVerifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (prov.pendingVerifications.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => prov.fetchPendingVerifications(),
            child: ListView(
              children: const [
                SizedBox(height: 120),
                EmptyState(
                  icon: Icons.verified_user,
                  title: 'No pending verifications',
                  subtitle: 'Submitted evidence will appear here',
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => prov.fetchPendingVerifications(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: prov.pendingVerifications.length,
            itemBuilder: (context, i) {
              final a = prov.pendingVerifications[i];
              final photoUrl = a.photo?['url'];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        a.classData?.subject ?? 'Class',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        a.teacherName ?? '',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      if (a.classData != null)
                        Text(
                          AppDateUtils.formatDateTime(a.classData!.startTime),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      const SizedBox(height: 12),
                      if (photoUrl != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            photoUrl,
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            loadingBuilder: (_, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                height: 220,
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            },
                            errorBuilder: (_, __, ___) => Container(
                              height: 220,
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(Icons.broken_image, size: 48),
                              ),
                            ),
                          ),
                        )
                      else
                        Container(
                          height: 100,
                          color: Colors.grey.shade100,
                          child: const Center(
                            child: Text('No photo available'),
                          ),
                        ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _verify(a, false),
                              icon: const Icon(Icons.close, color: Colors.red),
                              label: const Text('Reject'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _verify(a, true),
                              icon: const Icon(Icons.check),
                              label: const Text('Approve'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                              ),
                            ),
                          ),
                        ],
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