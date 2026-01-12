import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/constants.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'student' or 'teacher'
  final String? className; // e.g., 'CSE-A', 'Batch-73'
  final int currentStreak;
  final DateTime? lastCheckIn;
  final String? junoId; // ID from the ERP system

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.role = AppConstants.roleStudent,
    this.className,
    this.currentStreak = 0,
    this.lastCheckIn,
    this.junoId,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? 'Unknown',
      role: data['role'] ?? AppConstants.roleStudent,
      className: data['class_name'],
      currentStreak: data['current_streak'] ?? 0,
      lastCheckIn: data['last_check_in'] != null 
          ? (data['last_check_in'] as Timestamp).toDate() 
          : null,
      junoId: data['juno_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'class_name': className,
      'current_streak': currentStreak,
      'last_check_in': lastCheckIn != null ? Timestamp.fromDate(lastCheckIn!) : null,
      'juno_id': junoId,
    };
  }

  bool get isTeacher => role == AppConstants.roleTeacher;

  /// Calculates the new streak based on the last check-in date.
  /// Returns a map with 'streak' and 'lastCheckIn' to be updated.
  Map<String, dynamic> calculateNewStreak() {
    final now = DateTime.now();
    int newStreak = currentStreak;

    if (lastCheckIn == null) {
      newStreak = 1;
    } else {
      final difference = DateTime(now.year, now.month, now.day)
          .difference(DateTime(lastCheckIn!.year, lastCheckIn!.month, lastCheckIn!.day))
          .inDays;

      if (difference == 1) {
        newStreak++; // Consecutive day
      } else if (difference > 1) {
        newStreak = 1; // Broken streak
      }
      // If difference == 0 (same day), keep streak same
    }
    
    return {
      'current_streak': newStreak,
      'last_check_in': Timestamp.fromDate(now),
    };
  }
}

