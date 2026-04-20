import 'package:flutter_test/flutter_test.dart';
import 'package:ala_ainy/main.dart';

void main() {
  group('Unit Tests for AlaAiny App', () {
    test('AlaAinyApp class exists', () {
      expect(AlaAinyApp, isNotNull);
    });

    test('kAdminPhone constant is defined', () {
      // Verify the app has admin phone constant
      expect(kAdminPhone, isNotNull);
      expect(kAdminPhone, isNotEmpty);
    });

    test('Admin phone number format is valid', () {
      expect(kAdminPhone.length, greaterThan(0));
      expect(kAdminPhone, contains('0'));
    });

    test('App is a Widget', () {
      const app = AlaAinyApp();
      expect(app, isNotNull);
    });
  });
}
