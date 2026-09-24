import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/class_model.dart';
import '../../models/attendance.dart';
import '../../providers/attendance_provider.dart';
import '../../services/camera_service.dart';
import '../../widgets/common_widgets.dart';

class PhotoCaptureScreen extends StatefulWidget {
  final ClassModel classData;
  final Attendance attendance;

  const PhotoCaptureScreen({
    super.key,
    required this.classData,
    required this.attendance,
  });

  @override
  State<PhotoCaptureScreen> createState() => _PhotoCaptureScreenState();
}

class _PhotoCaptureScreenState extends State<PhotoCaptureScreen> {
  File? _photo;
  bool _isUploading = false;

  Future<void> _takePhoto() async {
    final file = await CameraService().takePhoto();
    if (file != null && mounted) {
      setState(() => _photo = file);
    }
  }

  Future<void> _uploadPhoto() async {
    if (_photo == null) return;

    setState(() => _isUploading = true);

    final prov = context.read<AttendanceProvider>();
    final result = await prov.submitEvidence(
      attendanceId: widget.attendance.id,
      photo: _photo!,
    );

    if (!mounted) return;
    setState(() => _isUploading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evidence submitted successfully'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Upload failed'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Classroom Photo')),
      body: LoadingOverlay(
        isLoading: _isUploading,
        message: 'Uploading photo...',
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.camera_alt,
                          size: 56, color: Color(0xFF8E24AA)),
                      const SizedBox(height: 12),
                      Text(
                        widget.classData.subject,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Capture a photo of your classroom as evidence',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _photo == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.image_outlined,
                                size: 100, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'No photo captured yet',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _photo!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _isUploading ? null : _takePhoto,
                      icon: const Icon(Icons.camera_alt),
                      label: Text(_photo == null ? 'Take Photo' : 'Retake'),
                    ),
                  ),
                  if (_photo != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isUploading ? null : _uploadPhoto,
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Submit'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}