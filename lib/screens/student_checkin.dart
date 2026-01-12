import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:animate_do/animate_do.dart';
import '../components/qr_scanner.dart';
import '../components/location_verifier.dart';
import '../components/selfie_capture.dart';
import '../components/app_background.dart';
import '../models/record_model.dart';
import '../services/db_service.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'student_checkin_components.dart'; // Added
import 'package:firebase_auth/firebase_auth.dart';

class StudentCheckIn extends StatefulWidget {
  const StudentCheckIn({super.key});

  @override
  State<StudentCheckIn> createState() => _StudentCheckInState();
}

class _StudentCheckInState extends State<StudentCheckIn> {
  int step = 0;
  String? sessionId;
  Position? location;
  String? selfiePath;
  final _db = DbService();
  final _authService = AuthService(); // Use Service

  void _onScan(String data) {
    final parts = data.split(':');
    if (parts.length >= 2 && parts[0] == 'FLASH') {
      setState(() {
        sessionId = parts[1];
        step = 1;
      });
    }
  }

  void _onLocationVerified(Position pos) {
    setState(() {
      location = pos;
      step = 2;
    });
  }

  void _onSelfieCaptured(String path) async {
    setState(() => selfiePath = path);
    final user = _authService.currentUser;
    if (user != null && sessionId != null && location != null) {
      final record = AttendanceRecord(
        sessionId: sessionId!,
        studentEmail: user.email!,
        studentName: user.displayName ?? "Student",
        verificationLayers: VerificationLayers(
          optical: true,
          geoFence: true,
          selfieCaptured: true,
        ),
        location: LocationData(
          latitude: location!.latitude,
          longitude: location!.longitude,
          accuracy: location!.accuracy,
        ),
        checkedInAt: DateTime.now(),
        selfieUrl: "https://placeholder.com/selfie.jpg",
      );

      final success = await _db.submitAttendance(record);
      if (success) {
        setState(() => step = 3);
      } else {
        // Already checked in - show message and go back
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("You've already checked in for this session!"),
              backgroundColor: Colors.orange,
            ),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Student Check-In",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                if (step < 3)
                  CheckInStepper(
                    currentStep: step,
                    steps: const ["Scan", "Location", "Selfie"],
                  ),
                const SizedBox(height: 32),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) {
                      final curvedAnimation = CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      );
                      return FadeTransition(
                        opacity: curvedAnimation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.05, 0),
                            end: Offset.zero,
                          ).animate(curvedAnimation),
                          child: child,
                        ),
                      );
                    },
                    layoutBuilder: (currentChild, previousChildren) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          ...previousChildren,
                          if (currentChild != null) currentChild,
                        ],
                      );
                    },
                    child: KeyedSubtree(
                      key: ValueKey<int>(step),
                      child: _buildBody(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    switch (step) {
      case 0:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Scan to Join",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "Point your camera at the teacher's screen",
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => QRScanner(
                      onScan: (val) {
                        Navigator.pop(context);
                        _onScan(val);
                      },
                      onClose: () => Navigator.pop(context),
                    ),
                  ),
                ),
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.indigo,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.withOpacity(0.4),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.white.withOpacity(0.2),
                        blurRadius: 0,
                        spreadRadius: 5,
                        offset: Offset.zero,
                      ), // Inner ring effect
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.qr_code_scanner_rounded,
                        size: 80,
                        color: Colors.white,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "TAP TO SCAN",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      case 1:
        return CheckInStepCard(
          title: "Verify Location",
          icon: Icons.location_on_outlined,
          description: "We need to ensure you are in the classroom.",
          content: LocationVerifier(onVerified: _onLocationVerified),
        );
      case 2:
        // Render SelfieCapture DIRECTLY without CheckInStepCard wrapper
        // The wrapper was blocking touch events on mobile web
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.face, size: 48, color: Colors.indigo),
                const SizedBox(height: 16),
                const Text(
                  "Quick Selfie",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "One last check to prove it's you!",
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 24),
                SelfieCapture(onCapture: _onSelfieCaptured),
              ],
            ),
          ),
        );
      case 3:
        return CheckInSuccessView(onDismiss: () => Navigator.pop(context));
      default:
        return const SizedBox();
    }
  }

  ButtonStyle _btnStyle() {
    return ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      backgroundColor: Colors.indigo,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }
}
