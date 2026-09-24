import 'package:flutter/material.dart';
import '../models/class_model.dart';
import '../config/app_theme.dart';
import '../utils/date_utils.dart';

class ClassCard extends StatelessWidget {
  final ClassModel classData;
  final VoidCallback? onTap;
  final bool showStatus;

  const ClassCard({
    super.key,
    required this.classData,
    this.onTap,
    this.showStatus = true,
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (showStatus) _buildStatusBadge(),
                ],
              ),
              const SizedBox(height: 8),
              if (classData.courseCode != null)
                Text(
                  classData.courseCode!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _infoItem(
                    Icons.access_time,
                    '${AppDateUtils.formatTime(classData.startTime)} - ${AppDateUtils.formatTime(classData.endTime)}',
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (classData.room != null)
                _infoItem(Icons.room_outlined, classData.room!),
              if (classData.teacherName != null) ...[
                const SizedBox(height: 6),
                _infoItem(Icons.person_outline, classData.teacherName!),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String label;

    if (classData.isOngoing) {
      color = AppTheme.secondaryColor;
      label = 'In Progress';
    } else if (classData.hasEnded) {
      color = Colors.grey;
      label = 'Completed';
    } else {
      color = AppTheme.primaryColor;
      label = AppDateUtils.countdown(classData.startTime);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}