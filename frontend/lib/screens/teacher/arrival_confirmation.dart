import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/class_model.dart';
import '../../models/attendance.dart';
import '../../providers/attendance_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/common_widgets.dart';

class ArrivalConfirmationScreen extends StatefulWidget {
  final ClassModel classData;
  final Attendance attendance;

  const ArrivalConfirmationScreen({
    super.key,
    required this.classData,
    required this.attendance,
  });

  @override
  State<ArrivalConfirmationScreen> createState() =>
      _ArrivalConfirmationScreenState();
}

class _ArrivalConfirmationScreenState extends State<ArrivalConfirmationScreen> {
  bool _isLocating = false;
  String? _errorMessage;
  LocationResult? _location;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    setState(() {
      _isLocating = true;
      _errorMessage = null;
    });

    final result = await LocationService().getCurrentLocation();

    if (!mounted) return;
    setState(() {
      _isLocating = false;
      _location = result;
      if (!result.success) _errorMessage = result.message;
    });
  }

  Future<void> _confirmArrival() async {
    if (_location == null || !_location!.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location is required to confirm arrival'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final prov = context.read<AttendanceProvider>();
    final result = await prov.confirmArrival(
      attendanceId: widget.attendance.id,
      latitude: _location!.latitude!,
      longitude: _location!.longitude!,
      accuracy: _location!.accuracy,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      Navigator.pop(context, result);
    } else {
      setState(() => _errorMessage = result['message']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AttendanceProvider>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Arrival')),
      body: LoadingOverlay(
        isLoading: isLoading,
        message: 'Verifying location...',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        _location?.success == true
                            ? Icons.location_on
                            : Icons.location_off,
                        size: 64,
                        color: _location?.success == true
                            ? Colors.green
                            : Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.classData.subject,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.classData.room ?? '',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_isLocating)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Getting your current location...'),
                      ],
                    ),
                  ),
                )
              else if (_location?.success == true)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _detailRow(
                          'Latitude',
                          _location!.latitude!.toStringAsFixed(6),
                        ),
                        const Divider(),
                        _detailRow(
                          'Longitude',
                          _location!.longitude!.toStringAsFixed(6),
                        ),
                        const Divider(),
                        _detailRow(
                          'Accuracy',
                          '${_location!.accuracy?.toStringAsFixed(1)} m',
                        ),
                      ],
                    ),
                  ),
                )
              else if (_errorMessage != null)
                ErrorBanner(message: _errorMessage!, onRetry: _getLocation),
              const Spacer(),
              if (_location?.success == true)
                ElevatedButton.icon(
                  onPressed: _confirmArrival,
                  icon: const Icon(Icons.check_circle),
                  label: const Text('Confirm My Arrival'),
                )
              else if (!_isLocating)
                ElevatedButton.icon(
                  onPressed: _getLocation,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Location'),
                ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}