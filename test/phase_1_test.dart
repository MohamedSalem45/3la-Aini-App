import 'package:flutter_test/flutter_test.dart';
import 'package:ala_ainy/features/orders/models/tracking_model.dart';
import 'package:ala_ainy/features/orders/models/rating_model.dart';

void main() {
  group('Phase 1 Implementation Tests', () {
    group('Tracking Model Tests', () {
      test('TrackingData can be created with required fields', () {
        final tracking = TrackingData(
          orderId: '123',
          latitude: 24.7136,
          longitude: 46.6753,
          status: 'in_progress',
          timestamp: DateTime.now(),
          driverName: 'محمد أحمد',
          driverPhone: '0501234567',
          vehicleInfo: 'تويوتا - أحمر',
          estimatedTimeMinutes: 15.0,
        );

        expect(tracking.orderId, equals('123'));
        expect(tracking.latitude, equals(24.7136));
        expect(tracking.longitude, equals(46.6753));
        expect(tracking.driverName, equals('محمد أحمد'));
      });

      test('TrackingData can be converted to and from Map', () {
        final tracking = TrackingData(
          orderId: '123',
          latitude: 24.7136,
          longitude: 46.6753,
          status: 'in_progress',
          timestamp: DateTime(2024, 1, 1, 12, 0),
          driverName: 'محمد أحمد',
          driverPhone: '0501234567',
          vehicleInfo: 'تويوتا - أحمر',
          estimatedTimeMinutes: 15.0,
        );

        final map = tracking.toMap();
        expect(map['orderId'], equals('123'));
        expect(map['latitude'], equals(24.7136));
        expect(map['driverName'], equals('محمد أحمد'));
      });
    });

    group('Rating Model Tests', () {
      test('RatingModel can be created with required fields', () {
        final rating = RatingModel(
          id: 'rating_1',
          orderId: '123',
          userId: 'user_456',
          storeId: 'store_789',
          rating: 5,
          comment: 'خدمة ممتازة',
          images: [],
          createdAt: DateTime.now(),
          driverName: 'محمد أحمد',
          driverRating: 5,
        );

        expect(rating.id, equals('rating_1'));
        expect(rating.rating, equals(5));
        expect(rating.comment, equals('خدمة ممتازة'));
      });

      test('RatingModel can be converted to and from Map', () {
        final rating = RatingModel(
          id: 'rating_1',
          orderId: '123',
          userId: 'user_456',
          storeId: 'store_789',
          rating: 4,
          comment: 'جيد جداً',
          images: ['url1', 'url2'],
          createdAt: DateTime(2024, 1, 1, 12, 0),
          driverName: 'محمد أحمد',
          driverRating: 5,
        );

        final map = rating.toMap();
        expect(map['rating'], equals(4));
        expect(map['comment'], equals('جيد جداً'));
        expect(map['images'], equals(['url1', 'url2']));
      });

      test('RatingModel copyWith works correctly', () {
        final rating = RatingModel(
          id: 'rating_1',
          orderId: '123',
          userId: 'user_456',
          storeId: 'store_789',
          rating: 5,
          comment: 'خدمة ممتازة',
          images: [],
          createdAt: DateTime.now(),
          driverName: 'محمد أحمد',
          driverRating: 5,
        );

        final updatedRating = rating.copyWith(rating: 4);
        expect(updatedRating.rating, equals(4));
        expect(updatedRating.id, equals('rating_1'));
      });
    });

    group('Integration Tests', () {
      test('TrackingData has valid coordinates', () {
        final tracking = TrackingData(
          orderId: '123',
          latitude: 24.7136,
          longitude: 46.6753,
          status: 'in_progress',
          timestamp: DateTime.now(),
          driverName: 'محمد أحمد',
          driverPhone: '0501234567',
          vehicleInfo: 'تويوتا - أحمر',
          estimatedTimeMinutes: 15.0,
        );

        expect(tracking.latitude, greaterThanOrEqualTo(-90));
        expect(tracking.latitude, lessThanOrEqualTo(90));
        expect(tracking.longitude, greaterThanOrEqualTo(-180));
        expect(tracking.longitude, lessThanOrEqualTo(180));
      });

      test('RatingModel has valid rating value', () {
        final rating = RatingModel(
          id: 'rating_1',
          orderId: '123',
          userId: 'user_456',
          storeId: 'store_789',
          rating: 3,
          comment: 'عادي',
          images: [],
          createdAt: DateTime.now(),
          driverName: 'محمد أحمد',
          driverRating: 4,
        );

        expect(rating.rating, greaterThanOrEqualTo(1));
        expect(rating.rating, lessThanOrEqualTo(5));
        expect(rating.driverRating, greaterThanOrEqualTo(1));
        expect(rating.driverRating, lessThanOrEqualTo(5));
      });
    });
  });
}
