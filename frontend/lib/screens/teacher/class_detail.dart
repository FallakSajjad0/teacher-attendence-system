import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:teacher_attendance_app/screens/teacher/arrival_confirmation.dart';
import '../../models/class_model.dart';
import '../../models/attendance.dart';
import '../../providers/attendance_provider.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import '../../utils/date_utils.dart';
import '../../widgets/common_widgets.dart';
import 'photo_capture.dart';

class ClassDetailScreen extends StatefulWidget {
  final ClassModel classData;
  final Attendance? attendance;

  const ClassDetailScreen({
    super.key,
    required this.classData,
    this.attendance,
  });

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  Attendance? _attendance;

  @override
  void initState() {
    super.initState();
    _attendance = widget.attendance;
    _loadAttendance();
  }

  Future<void> _loadAttendance() async {
    final api = ApiService();
    final response = await api.get('/attendance/class/${widget.classData.id}');
    if (response.success && response.data != null) {
      final list = (response.data['records'] as List);
      if (list.isNotEmpty) {
        setState(() {
          _attendance = Attendance.fromJson(list.first);
        });
      }
    }
  }

  Future<void> _respondAvailability(bool isAvailable) async {
    if (_attendance == null) return;
    final prov = context.read<AttendanceProvider>();
    final result = await prov.respondAvailability(_attendance!.id, isAvailable);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['message']),
        backgroundColor: result['success'] == true ? Colors.green : Colors.red,
      ),
    );
    if (result['success'] == true) _loadAttendance();
  }

  Future<void> _confirmArrival() async {
    if (_attendance == null) return;
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => ArrivalConfirmationScreen(
          classData: widget.classData,
          attendance: _attendance!,
        ),
      ),
    );

    if (result != null && result['success'] == true && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PhotoCaptureScreen(
            classData: widget.classData,
            attendance: Attendance.fromJson(result['attendance']),
          ),
        ),
      ).then((_) => _loadAttendance());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.classData.subject)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildInfoCard(),
          const SizedBox(height: 16),
          _buildStatusCard(),
          const SizedBox(height: 16),
          _buildActionSection(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
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
                    widget.classData.subject,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_attendance != null) StatusChip(status: _attendance!.status),
              ],
            ),
            if (widget.classData.courseCode != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.classData.courseCode!,
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
            const Divider(height: 24),
            _row(Icons.schedule, 'Start',
                AppDateUtils.formatDateTime(widget.classData.startTime)),
            const SizedBox(height: 8),
            _row(Icons.schedule_outlined, 'End',
                AppDateUtils.formatDateTime(widget.classData.endTime)),
            if (widget.classData.room != null) ...[
              const SizedBox(height: 8),
              _row(Icons.room_outlined, 'Room', widget.classData.room!),
            ],
            const SizedBox(height: 8),
            _row(Icons.today, 'Day', widget.classData.dayOfWeek),
          ],
        ),
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Text(
          '$label: ',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    if (_attendance == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Attendance record will appear when class is scheduled.'),
        ),
      );
    }

    final a = _attendance!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Attendance Status',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 12),
            StatusChip(status: a.status),
            if (a.availabilityResponseAt != null) ...[
              const SizedBox(height: 12),
              _row(Icons.event_available, 'Availability',
                  AppDateUtils.formatDateTime(a.availabilityResponseAt!)),
            ],
            if (a.arrivalConfirmedAt != null) ...[
              const SizedBox(height: 8),
              _row(Icons.location_on, 'Arrival',
                  AppDateUtils.formatDateTime(a.arrivalConfirmedAt!)),
            ],
            if (a.location?.isWithinRadius != null) ...[
              const SizedBox(height: 8),
              _row(
                a.location!.isWithinRadius!
                    ? Icons.check_circle
                    : Icons.warning_amber,
                'Location',
                a.location!.isWithinRadius!
                    ? 'Within classroom radius (${a.location!.distanceFromClassroom?.toInt()}m)'
                    : 'Outside radius (${a.location!.distanceFromClassroom?.toInt()}m)',
              ),
            ],
            if (a.verificationStatus == 'verified') ...[
              const SizedBox(height: 8),
              _row(Icons.verified, 'Verification', 'Verified by management'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionSection() {
    if (_attendance == null) return const SizedBox.shrink();
    final status = _attendance!.status;

    if (status == AppConstants.statusPending) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Are you available for this class?',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _respondAvailability(true),
                      icon: const Icon(Icons.check),
                      label: const Text('Available'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _respondAvailability(false),
                      icon: const Icon(Icons.close),
                      label: const Text('Not Available'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    if (status == AppConstants.statusAvailable) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.location_on,
                  size: 48, color: Color(0xFF1E88E5)),
              const SizedBox(height: 12),
              const Text(
                'Confirm your arrival',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                'Your location will be captured for verification',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _confirmArrival,
                icon: const Icon(Icons.location_searching),
                label: const Text('Confirm Arrival'),
              ),
            ],
          ),
        ),
      );
    }

    if (status == AppConstants.statusArrived) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.camera_alt,
                  size: 48, color: Color(0xFF8E24AA)),
              const SizedBox(height: 12),
              const Text(
                'Capture classroom photo',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 6),
              Text(
                'Take a photo of your classroom as evidence',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PhotoCaptureScreen(
                        classData: widget.classData,
                        attendance: _attendance!,
                      ),
                    ),
                  ).then((_) => _loadAttendance());
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture Photo'),
              ),
            ],
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}