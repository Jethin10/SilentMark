import 'dart:async';
import 'package:flutter/foundation.dart';

/// Service to handle integration with NIET's Juno ERP.
/// Currently mocks data, but structured to be replaced with real API calls.
class JunoService {
  // Base URL would go here if we had the real API
  // final String baseUrl = 'https://api.juno.one/niet';

  /// Simulates fetching a student's profile from the ERP using their email.
  Future<Map<String, dynamic>?> fetchStudentProfile(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // MOCK LOGIC: 
    // If email contains 'niet.co.in', we assume it's a valid student.
    // In a real app, this would be an HTTP GET request.
    if (email.contains('niet.co.in') || email.contains('test')) {
      return {
        'juno_id': 'NIET-${DateTime.now().millisecondsSinceEpoch}',
        'name': email.split('@')[0].toUpperCase(),
        'class_name': 'CSE-Batch-2025-A', // The "73 students" group
        'role': 'student',
      };
    }
    
    // Simulating a teacher
    if (email.contains('teacher')) {
      return {
        'juno_id': 'FAC-${DateTime.now().millisecondsSinceEpoch}',
        'name': 'Prof. ${email.split('@')[0]}',
        'class_name': null,
        'role': 'teacher',
      };
    }

    return null;
  }

  /// Syncs daily attendance to Juno ERP
  Future<bool> postAttendanceToJuno(String junoId, String status) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Real logic: HTTP POST to Juno API
    if (kDebugMode) {
      print('Synced attendance for $junoId: $status');
    }
    return true;
  }
}
