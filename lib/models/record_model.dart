import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceRecord {
  final String id;
  final String sessionId;
  final String studentEmail;
  final String studentName;
  final String status; // 'verified', 'flagged', 'rejected'
  final VerificationLayers verificationLayers;
  final String? selfieUrl;
  final LocationData? location;
  final DateTime checkedInAt;

  AttendanceRecord({
    this.id = '',
    required this.sessionId,
    required this.studentEmail,
    required this.studentName,
    this.status = 'verified',
    required this.verificationLayers,
    this.selfieUrl,
    this.location,
    required this.checkedInAt,
  });

  factory AttendanceRecord.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    DateTime checkedInTime;
    try {
      if (data['checked_in_at'] is Timestamp) {
        checkedInTime = (data['checked_in_at'] as Timestamp).toDate();
      } else if (data['checked_in_at'] is String) {
        checkedInTime = DateTime.parse(data['checked_in_at']);
      } else {
        checkedInTime = DateTime.now();
      }
    } catch (e) {
      checkedInTime = DateTime.now();
    }

    return AttendanceRecord(
      id: doc.id,
      sessionId: data['session_id'] ?? '',
      studentEmail: data['student_email'] ?? '',
      studentName: data['student_name'] ?? 'Unknown',
      status: data['status'] ?? 'verified',
      verificationLayers: VerificationLayers.fromMap(data['verification_layers'] ?? {}),
      selfieUrl: data['selfie_url'],
      location: data['location'] != null ? LocationData.fromMap(data['location']) : null,
      checkedInAt: checkedInTime,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'session_id': sessionId,
      'student_email': studentEmail,
      'student_name': studentName,
      'status': status,
      'verification_layers': verificationLayers.toMap(),
      'selfie_url': selfieUrl,
      'location': location?.toMap(),
      'checked_in_at': Timestamp.fromDate(checkedInAt),
    };
  }
}

class VerificationLayers {
  final bool optical;
  final bool geoFence;
  final bool wifiAnchor;
  final bool selfieCaptured;

  VerificationLayers({
    this.optical = false,
    this.geoFence = false,
    this.wifiAnchor = false,
    this.selfieCaptured = false,
  });

  factory VerificationLayers.fromMap(Map<String, dynamic> map) {
    return VerificationLayers(
      optical: map['optical'] ?? false,
      geoFence: map['geo_fence'] ?? false,
      wifiAnchor: map['wifi_anchor'] ?? false,
      selfieCaptured: map['selfie_captured'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'optical': optical,
      'geo_fence': geoFence,
      'wifi_anchor': wifiAnchor,
      'selfie_captured': selfieCaptured,
    };
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final double accuracy;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
  });

  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      accuracy: (map['accuracy'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
    };
  }
}
