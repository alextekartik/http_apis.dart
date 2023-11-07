import 'package:tekartik_stripe_api/src/format.dart';
import 'package:test/test.dart';

void main() {
  group('format', () {
    test('formatAmount', () {
      expect(formatAmount(1), '100');
      expect(formatAmount(123456789.987654321), '12345678999');
    });
  });
}
