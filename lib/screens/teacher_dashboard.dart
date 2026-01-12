import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import '../services/db_service.dart';
import '../models/session_model.dart';
import '../models/record_model.dart';
import '../components/qr_code_display.dart';
import '../components/app_background.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class TeacherDashboard extends StatefulWidget {
  const TeacherDashboard({super.key});

  @override
  State<TeacherDashboard> createState() => _TeacherDashboardState();
}

class _TeacherDashboardState extends State<TeacherDashboard> {
  final _db = DbService();
  String? currentSessionId;
  String? currentSecret;

  void _createSession() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final session = AttendanceSession(
      title: "CS101 - Lecture 1",
      courseCode: "CS101",
      teacherEmail: user.email!,
      secretKey: DateTime.now().toIso8601String(),
      startedAt: DateTime.now(),
    );

    final id = await _db.createSession(session);
    setState(() {
      currentSessionId = id;
      currentSecret = session.secretKey;
    });
  }

  void _logout() {
    AuthService().signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Teacher Dashboard",
          style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: _logout,
          ),
        ],
      ),
      body: AppBackground(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Check if we are on a "Smart Board" or Tablet (Wide Screen)
            bool isWideScreen = constraints.maxWidth > 900;

            return SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isWideScreen ? 40 : 24),
                child: currentSessionId == null
                    ? _buildStartSessionView(isWideScreen)
                    : _buildActiveSessionView(isWideScreen),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStartSessionView(bool isWideScreen) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 600,
        ), // Limit width on big screens
        child: FadeInDown(
          duration: const Duration(milliseconds: 600),
          child: Container(
            padding: EdgeInsets.all(isWideScreen ? 48 : 32),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.indigo.withOpacity(0.1),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.withOpacity(0.15),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(isWideScreen ? 32 : 24),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.class_rounded,
                    size: isWideScreen ? 80 : 64,
                    color: Colors.indigo,
                  ),
                ),
                SizedBox(height: isWideScreen ? 40 : 32),
                Text(
                  "Ready to start?",
                  style: TextStyle(
                    fontSize: isWideScreen ? 32 : 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "Create a new session to generate a secure QR code for your students to scan.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    height: 1.5,
                    fontSize: isWideScreen ? 20 : 16,
                  ),
                ),
                SizedBox(height: isWideScreen ? 48 : 40),
                SizedBox(
                  width: double.infinity,
                  height: isWideScreen ? 70 : 56,
                  child: ElevatedButton.icon(
                    onPressed: _createSession,
                    icon: Icon(
                      Icons.play_arrow_rounded,
                      size: isWideScreen ? 36 : 28,
                    ),
                    label: Text(
                      "Start Session",
                      style: TextStyle(
                        fontSize: isWideScreen ? 24 : 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      elevation: 5,
                      shadowColor: Colors.indigo.withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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

  Widget _buildActiveSessionView(bool isWideScreen) {
    if (isWideScreen) {
      // --- SMART BOARD LAYOUT (Split View) ---
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Side: QR Code (Fixed Width)
          Expanded(flex: 2, child: _buildQrCard(isWideScreen)),
          const SizedBox(width: 40),
          // Right Side: Live Attendance List
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLiveHeader(isWideScreen),
                const SizedBox(height: 24),
                _buildLiveList(isWideScreen),
              ],
            ),
          ),
        ],
      );
    } else {
      // --- MOBILE LAYOUT (Stacked) ---
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQrCard(isWideScreen),
          const SizedBox(height: 40),
          _buildLiveHeader(isWideScreen),
          const SizedBox(height: 20),
          _buildLiveList(isWideScreen),
        ],
      );
    }
  }

  Widget _buildQrCard(bool isWideScreen) {
    return FadeInUp(
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(isWideScreen ? 40 : 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              "Scan to Join",
              style: TextStyle(
                fontSize: isWideScreen ? 28 : 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: isWideScreen ? 32 : 16),
            QRCodeDisplay(
              sessionId: currentSessionId!,
              secretKey: currentSecret!,
            ),
            SizedBox(height: isWideScreen ? 32 : 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.circle, size: 10, color: Colors.green),
                  const SizedBox(width: 8),
                  Text(
                    "Session Active",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: isWideScreen ? 18 : 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: isWideScreen ? 24 : 16),
            // End Session Button
            SizedBox(
              width: double.infinity,
              height: isWideScreen ? 56 : 48,
              child: OutlinedButton.icon(
                onPressed: _confirmEndSession,
                icon: const Icon(Icons.stop_circle_outlined, color: Colors.red),
                label: Text(
                  "End Session",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: isWideScreen ? 18 : 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmEndSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("End Session?"),
        content: const Text(
          "This will close the attendance session. Students will no longer be able to check in.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _db.endSession(currentSessionId!);
              setState(() {
                currentSessionId = null;
                currentSecret = null;
              });
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Session ended successfully!"),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("End Session"),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveHeader(bool isWideScreen) {
    return FadeInLeft(
      delay: const Duration(milliseconds: 200),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Live Attendance",
            style: TextStyle(
              fontSize: isWideScreen ? 32 : 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          Container(
            padding: EdgeInsets.all(isWideScreen ? 12 : 8),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.people_outline,
              color: Colors.indigo,
              size: isWideScreen ? 32 : 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveList(bool isWideScreen) {
    return StreamBuilder<List<AttendanceRecord>>(
      stream: _db.getLiveRecords(currentSessionId!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
        final records = snapshot.data!;

        // Sort client-side to ensure latest are top without Firestore indexes
        records.sort((a, b) => b.checkedInAt.compareTo(a.checkedInAt));

        if (records.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    size: isWideScreen ? 64 : 48,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Waiting for students...",
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: isWideScreen ? 20 : 16,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return ListView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(), // Scroll handled by parent
          itemCount: records.length,
          itemBuilder: (context, index) {
            // Removed FadeInLeft to prevent list rebuilding flicker/lag
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: isWideScreen ? 32 : 20,
                  vertical: isWideScreen ? 16 : 8,
                ),
                leading: CircleAvatar(
                  radius: isWideScreen ? 30 : 20,
                  backgroundColor: Colors.green.shade100,
                  child: Icon(
                    Icons.check,
                    color: Colors.green,
                    size: isWideScreen ? 30 : 24,
                  ),
                ),
                title: Text(
                  records[index].studentName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isWideScreen ? 20 : 16,
                  ),
                ),
                subtitle: Text(
                  records[index].studentEmail,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: isWideScreen ? 16 : 14,
                  ),
                ),
                trailing: Text(
                  "${records[index].checkedInAt.hour}:${records[index].checkedInAt.minute.toString().padLeft(2, '0')}",
                  style: TextStyle(
                    color: Colors.indigo.shade300,
                    fontWeight: FontWeight.w600,
                    fontSize: isWideScreen ? 18 : 14,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
