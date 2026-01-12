import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/session_model.dart';
import '../models/record_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'juno_service.dart';

class DbService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final JunoService _junoService = JunoService();

  // --- SESSIONS ---

  // Stream of active sessions for Students
  Stream<List<AttendanceSession>> getActiveSessions() {
    return _db
        .collection(AppConstants.sessionsCollection)
        .where('status', isEqualTo: AppConstants.statusActive)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AttendanceSession.fromFirestore(doc))
              .toList(),
        );
  }

  // Create a new session (Teacher)
  Future<String> createSession(AttendanceSession session) async {
    DocumentReference docRef = await _db
        .collection(AppConstants.sessionsCollection)
        .add(session.toMap());
    return docRef.id;
  }

  // End a session (Teacher)
  Future<void> endSession(String sessionId) async {
    await _db.collection(AppConstants.sessionsCollection).doc(sessionId).update(
      {'status': 'ended', 'ended_at': Timestamp.fromDate(DateTime.now())},
    );
  }

  // --- RECORDS ---

  // Check if student already checked in for this session
  Future<bool> hasAlreadyCheckedIn(
    String sessionId,
    String studentEmail,
  ) async {
    final query = await _db
        .collection(AppConstants.recordsCollection)
        .where('session_id', isEqualTo: sessionId)
        .where('student_email', isEqualTo: studentEmail)
        .limit(1)
        .get();
    return query.docs.isNotEmpty;
  }

  // Submit Attendance (Student) - with duplicate prevention
  Future<bool> submitAttendance(AttendanceRecord record) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    // Check for duplicate
    final alreadyCheckedIn = await hasAlreadyCheckedIn(
      record.sessionId,
      record.studentEmail,
    );
    if (alreadyCheckedIn) {
      return false; // Already checked in
    }

    // 1. Save Record
    await _db.collection(AppConstants.recordsCollection).add(record.toMap());

    // 2. Update Streak & Last Check-In
    final userRef = _db.collection(AppConstants.usersCollection).doc(user.uid);
    String? junoIdToSync;

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) return;

      final userModel = UserModel.fromFirestore(snapshot);
      junoIdToSync = userModel.junoId; // Capture ID for post-transaction sync

      final streakUpdate = userModel.calculateNewStreak();

      transaction.update(userRef, streakUpdate);
    });

    // 3. Sync to Juno ERP (Mock) - EXECUTED AFTER TRANSACTION COMMITS
    // This prevents multiple API calls if the transaction retries.
    if (junoIdToSync != null) {
      // We don't await this so the UI doesn't hang, unless strict consistency is required
      _junoService.postAttendanceToJuno(junoIdToSync!, 'PRESENT');
    }

    return true; // Successfully checked in
  }

  // Stream live attendance for a specific session (Teacher)
  Stream<List<AttendanceRecord>> getLiveRecords(String sessionId) {
    return _db
        .collection(AppConstants.recordsCollection)
        .where('session_id', isEqualTo: sessionId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => AttendanceRecord.fromFirestore(doc))
              .toList(),
        );
  }
}
