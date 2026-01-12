import 'package:flutter/material.dart';

import 'package:camera/camera.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:typed_data';

class SelfieCapture extends StatefulWidget {
  final Function(String) onCapture;
  const SelfieCapture({super.key, required this.onCapture});

  @override
  State<SelfieCapture> createState() => _SelfieCaptureState();
}

class _SelfieCaptureState extends State<SelfieCapture> {
  CameraController? _controller;
  XFile? capturedImage;
  Uint8List? capturedImageBytes; // For web compatibility
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      // Some devices might not have a front camera, or cameras might be empty on simulators
      if (cameras.isNotEmpty) {
        try {
          final frontCam = cameras.firstWhere(
            (c) => c.lensDirection == CameraLensDirection.front,
          );
          _controller = CameraController(
            frontCam,
            ResolutionPreset.medium,
            enableAudio: false,
          );
          await _controller!.initialize();
          if (mounted) setState(() {});
        } catch (e) {
          // Fallback to first available if no front camera
          _controller = CameraController(
            cameras.first,
            ResolutionPreset.medium,
            enableAudio: false,
          );
          await _controller!.initialize();
          if (mounted) setState(() {});
        }
      } else {
        setState(() => errorMessage = "No camera available");
      }
    } catch (e) {
      setState(() => errorMessage = "Camera error: $e");
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      final img = await _controller!.takePicture();
      // Read bytes for web compatibility
      final bytes = await img.readAsBytes();
      setState(() {
        capturedImage = img;
        capturedImageBytes = bytes;
      });
    } catch (e) {
      setState(() => errorMessage = "Failed to capture: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildCapturedImagePreview() {
    if (capturedImageBytes != null) {
      // Works on both web and mobile
      return Image.memory(capturedImageBytes!, height: 300, fit: BoxFit.cover);
    }
    return const SizedBox(height: 300, child: Center(child: Text("No image")));
  }

  @override
  Widget build(BuildContext context) {
    // Show error if camera failed
    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(LucideIcons.cameraOff, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            Text(errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() => errorMessage = null);
                _initCamera();
              },
              child: const Text("Retry"),
            ),
          ],
        ),
      );
    }

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (capturedImage != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: _buildCapturedImagePreview(),
          ),
          const SizedBox(height: 24),
          // Use Photo button - BIG and prominent
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () => widget.onCapture(capturedImage!.path),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                elevation: 6,
                shadowColor: Colors.green.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(LucideIcons.check, size: 28),
                  SizedBox(width: 12),
                  Text(
                    "USE THIS PHOTO",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Retake button - secondary style
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: () => setState(() {
                capturedImage = null;
                capturedImageBytes = null;
              }),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey.shade700,
                side: BorderSide(color: Colors.grey.shade400, width: 2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(LucideIcons.refreshCw, size: 22),
                  SizedBox(width: 10),
                  Text(
                    "RETAKE",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Camera preview with BIG capture button - simple layout for mobile web
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Camera Preview - smaller to ensure button is visible
        Container(
          height: 180,
          width: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.indigo, width: 3),
          ),
          child: ClipOval(child: CameraPreview(_controller!)),
        ),
        const SizedBox(height: 30),
        // BIG Capture Button - using ElevatedButton for mobile web compatibility
        SizedBox(
          width: double.infinity,
          height: 70,
          child: ElevatedButton(
            onPressed: _takePicture,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              elevation: 8,
              shadowColor: Colors.indigo.withOpacity(0.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(LucideIcons.camera, size: 32),
                SizedBox(width: 16),
                Text(
                  "TAP TO CAPTURE",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
