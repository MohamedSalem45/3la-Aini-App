import 'package:cloud_firestore/cloud_firestore.dart';

class TrackingData {
  final String orderId;
  final double latitude;
  final double longitude;
  final String status;
  final DateTime timestamp;
  final String driverName;
  final String driverPhone;
  final String vehicleInfo;
  final double estimatedTimeMinutes;

  TrackingData({
    required this.orderId,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.timestamp,
    required this.driverName,
    required this.driverPhone,
    required this.vehicleInfo,
    required this.estimatedTimeMinutes,
  });

  // تحويل من Firestore
  factory TrackingData.fromMap(Map<String, dynamic> map) {
    return TrackingData(
      orderId: map['orderId'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'in_progress',
      timestamp: (map['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      driverName: map['driverName'] ?? '',
      driverPhone: map['driverPhone'] ?? '',
      vehicleInfo: map['vehicleInfo'] ?? '',
      estimatedTimeMinutes: (map['estimatedTimeMinutes'] ?? 0.0).toDouble(),
    );
  }

  // تحويل إلى Firestore
  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'timestamp': Timestamp.fromDate(timestamp),
      'driverName': driverName,
      'driverPhone': driverPhone,
      'vehicleInfo': vehicleInfo,
      'estimatedTimeMinutes': estimatedTimeMinutes,
    };
  }
}
