import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import '../models/tracking_model.dart';

class TrackingService {
  static final TrackingService _instance = TrackingService._internal();

  factory TrackingService() {
    return _instance;
  }

  TrackingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<Position>? _positionStream;
  final StreamController<TrackingData> _trackingController =
      StreamController<TrackingData>.broadcast();

  Stream<TrackingData> get trackingStream => _trackingController.stream;

  // طلب أذونات الموقع
  Future<bool> requestLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final result = await Geolocator.requestPermission();
      return result != LocationPermission.denied &&
          result != LocationPermission.deniedForever;
    } else if (permission == LocationPermission.deniedForever) {
      await Geolocator.openLocationSettings();
      return false;
    }
    return true;
  }

  // بدء تتبع الموقع الحي
  Future<void> startTracking(
    String orderId,
    String driverName,
    String driverPhone,
    String vehicleInfo,
  ) async {
    final hasPermission = await requestLocationPermission();
    if (!hasPermission) {
      throw Exception('لم يتم منح أذونات الموقع');
    }

    // التحديث كل 10 ثوانٍ
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10,
      timeLimit: Duration(seconds: 10),
    );

    _positionStream = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((Position position) async {
      await _updateTracking(
        orderId,
        position.latitude,
        position.longitude,
        driverName,
        driverPhone,
        vehicleInfo,
      );
    });
  }

  // إيقاف التتبع
  Future<void> stopTracking(String orderId) async {
    await _positionStream?.cancel();
    _positionStream = null;

    await _firestore
        .collection('orders')
        .doc(orderId)
        .collection('tracking')
        .add({
      'status': 'completed',
      'timestamp': Timestamp.now(),
    });
  }

  // تحديث بيانات التتبع
  Future<void> _updateTracking(
    String orderId,
    double latitude,
    double longitude,
    String driverName,
    String driverPhone,
    String vehicleInfo,
  ) async {
    final tracking = TrackingData(
      orderId: orderId,
      latitude: latitude,
      longitude: longitude,
      status: 'in_progress',
      timestamp: DateTime.now(),
      driverName: driverName,
      driverPhone: driverPhone,
      vehicleInfo: vehicleInfo,
      estimatedTimeMinutes: 15, // يمكن حسابها بناءً على المسافة
    );

    try {
      // حفظ في Firestore
      await _firestore
          .collection('orders')
          .doc(orderId)
          .collection('tracking')
          .add(tracking.toMap());

      // إرسال عبر Stream
      _trackingController.add(tracking);
    } catch (e) {
      // Error updating tracking
    }
  }

  // الحصول على بيانات التتبع الحالية
  Stream<TrackingData> getOrderTracking(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .collection('tracking')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        throw Exception('لا توجد بيانات تتبع');
      }
      return TrackingData.fromMap(snapshot.docs.first.data());
    });
  }

  // الحصول على سجل التتبع الكامل
  Stream<List<TrackingData>> getOrderTrackingHistory(String orderId) {
    return _firestore
        .collection('orders')
        .doc(orderId)
        .collection('tracking')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TrackingData.fromMap(doc.data()))
          .toList();
    });
  }

  void dispose() {
    _positionStream?.cancel();
    _trackingController.close();
  }
}
