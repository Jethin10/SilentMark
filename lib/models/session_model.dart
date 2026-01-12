import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceSession {
  final String id;
  final String title;
  final String courseCode;
  final String teacherEmail;
  final String status; // 'active' or 'ended'
  final String secretKey;
  final GeoFenceData? geoFence;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int expectedStudents;

  AttendanceSession({
    this.id = '',
    required this.title,
    required this.courseCode,
    required this.teacherEmail,
    this.status = 'active',
    required this.secretKey,
    this.geoFence,
    required this.startedAt,
    this.endedAt,
    this.expectedStudents = 0,
  });

  // Convert Firebase Document to Dart Object
  factory AttendanceSession.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AttendanceSession(
      id: doc.id,
      title: data['title'] ?? 'Untitled Session',
      courseCode: data['course_code'] ?? '',
      teacherEmail: data['teacher_email'] ?? '',
      status: data['status'] ?? 'active',
      secretKey: data['secret_key'] ?? '',
      geoFence: data['geo_fence'] != null
          ? GeoFenceData.fromMap(data['geo_fence'])
          : null,
      startedAt: (data['started_at'] as Timestamp).toDate(),
      endedAt: data['ended_at'] != null 
          ? (data['ended_at'] as Timestamp).toDate() 
          : null,
      expectedStudents: data['expected_students'] ?? 0,
    );
  }

  // Convert Dart Object to Firebase Map
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'course_code': courseCode,
      'teacher_email': teacherEmail,
      'status': status,
      'secret_key': secretKey,
      'geo_fence': geoFence?.toMap(),
      'started_at': Timestamp.fromDate(startedAt),
      'ended_at': endedAt != null ? Timestamp.fromDate(endedAt!) : null,
      'expected_students': expectedStudents,
    };
  }
}

class GeoFenceData {
  final double latitude;
  final double longitude;
  final double radiusMeters;

  GeoFenceData({
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
  });

  factory GeoFenceData.fromMap(Map<String, dynamic> map) {
    return GeoFenceData(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      radiusMeters: (map['radius_meters'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'radius_meters': radiusMeters,
    };
  }
}
