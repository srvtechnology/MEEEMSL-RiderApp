import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:meeem_rider/core/services/rider_delivery_service.dart';

void main() {
  group('RiderDeliveryService Part 8 Reference Tests', () {
    const testOrderId = 'cuid_order_123';
    const testToken = 'test_rider_jwt_token';

    test('1. acceptOffer posts to /orders/:id/accept with Authorization Bearer header', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/mobileapi/rider/orders/$testOrderId/accept');
        expect(request.method, 'POST');
        expect(request.headers['Authorization'], 'Bearer $testToken');
        expect(request.headers['Content-Type'], 'application/json');

        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Delivery offer accepted successfully',
            'data': {
              'id': 'cuid_assignment_123',
              'orderId': testOrderId,
              'status': 'ACCEPTED',
              'acceptedAt': '2026-09-10T11:00:00.000Z',
            }
          }),
          200,
        );
      });

      final result = await RiderDeliveryService.acceptOffer(
        orderId: testOrderId,
        token: testToken,
        client: mockClient,
      );

      expect(result['success'], isTrue);
      expect(result['message'], 'Delivery offer accepted successfully');
      expect(result['data']['status'], 'ACCEPTED');
    });

    test('2. rejectOffer posts to /orders/:id/reject with reason', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/mobileapi/rider/orders/$testOrderId/reject');
        expect(request.method, 'POST');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['reason'], 'Too far from current location');

        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Delivery offer rejected',
          }),
          200,
        );
      });

      final result = await RiderDeliveryService.rejectOffer(
        orderId: testOrderId,
        reason: 'Too far from current location',
        token: testToken,
        client: mockClient,
      );

      expect(result['success'], isTrue);
      expect(result['message'], 'Delivery offer rejected');
    });

    test('3. updateStatus posts milestone progression to /orders/:id/status', () async {
      for (final milestone in ['AT_PICKUP', 'PICKED_UP', 'OUT_FOR_DELIVERY']) {
        final mockClient = MockClient((request) async {
          expect(request.url.path, '/mobileapi/rider/orders/$testOrderId/status');
          expect(request.method, 'POST');
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['status'], milestone);

          return http.Response(
            jsonEncode({
              'success': true,
              'message': 'Delivery status updated to $milestone',
            }),
            200,
          );
        });

        final result = await RiderDeliveryService.updateStatus(
          orderId: testOrderId,
          status: milestone,
          token: testToken,
          client: mockClient,
        );

        expect(result['success'], isTrue);
        expect(result['message'], 'Delivery status updated to $milestone');
      }
    });

    test('4. completeDelivery posts DELIVERED with OTP and proofImage to /orders/:id/status', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/mobileapi/rider/orders/$testOrderId/status');
        expect(request.method, 'POST');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['status'], 'DELIVERED');
        expect(body['otp'], '582910');
        expect(body['proofImage'], startsWith('data:image/jpeg;base64,'));

        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Delivery status updated to DELIVERED',
            'data': {
              'status': 'DELIVERED',
              'deliveredAt': '2026-09-10T11:45:00.000Z',
            }
          }),
          200,
        );
      });

      final result = await RiderDeliveryService.completeDelivery(
        orderId: testOrderId,
        otp: '582910',
        proofImageBase64: 'data:image/jpeg;base64,samplebase64',
        token: testToken,
        client: mockClient,
      );

      expect(result['success'], isTrue);
      expect(result['data']['status'], 'DELIVERED');
    });

    test('5. cancelTrip posts CANCELLED_BY_RIDER with cancellationReason to /orders/:id/status', () async {
      final mockClient = MockClient((request) async {
        expect(request.url.path, '/mobileapi/rider/orders/$testOrderId/status');
        expect(request.method, 'POST');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['status'], 'CANCELLED_BY_RIDER');
        expect(body['cancellationReason'], 'Vehicle breakdown');

        return http.Response(
          jsonEncode({
            'success': true,
            'message': 'Delivery status updated to CANCELLED_BY_RIDER',
            'data': {
              'status': 'CANCELLED_BY_RIDER',
            }
          }),
          200,
        );
      });

      final result = await RiderDeliveryService.cancelTrip(
        orderId: testOrderId,
        cancellationReason: 'Vehicle breakdown',
        token: testToken,
        client: mockClient,
      );

      expect(result['success'], isTrue);
      expect(result['message'], 'Delivery status updated to CANCELLED_BY_RIDER');
    });
  });
}
