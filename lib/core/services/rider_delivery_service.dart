import 'dart:convert';
import 'package:http/http.dart' as http;

/// Complete standalone Delivery Rider service conforming to
/// MOBILE_RIDER_DISPATCH_AND_TRIP_CANCELLATION_API_DOC_PART_8.md (Section 6).
class RiderDeliveryService {
  static const String baseUrl = 'https://www.meeemsl.com/mobileapi/rider';

  // 1. Accept Delivery Offer (Within 60s countdown)
  static Future<Map<String, dynamic>> acceptOffer({
    required String orderId,
    required String token,
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    try {
      final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';
      final res = await httpClient.post(
        Uri.parse('$baseUrl/orders/$orderId/accept'),
        headers: {
          'Authorization': formattedToken,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }

  // 2. Reject Delivery Offer
  static Future<Map<String, dynamic>> rejectOffer({
    required String orderId,
    String? reason,
    required String token,
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    try {
      final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';
      final res = await httpClient.post(
        Uri.parse('$baseUrl/orders/$orderId/reject'),
        headers: {
          'Authorization': formattedToken,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          if (reason != null) 'reason': reason,
        }),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }

  // 3. Update Status (AT_PICKUP, PICKED_UP, OUT_FOR_DELIVERY)
  static Future<Map<String, dynamic>> updateStatus({
    required String orderId,
    required String status,
    required String token,
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    try {
      final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';
      final res = await httpClient.post(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: {
          'Authorization': formattedToken,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': status}),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }

  // 4. Complete Delivery (Verify Customer OTP + Upload Photo Proof)
  static Future<Map<String, dynamic>> completeDelivery({
    required String orderId,
    required String otp,
    required String proofImageBase64,
    required String token,
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    try {
      final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';
      final res = await httpClient.post(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: {
          'Authorization': formattedToken,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': 'DELIVERED',
          'otp': otp,
          'proofImage': proofImageBase64,
        }),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }

  // 5. Emergency Cancel Delivery Trip (Vehicle breakdown, emergency, etc.)
  static Future<Map<String, dynamic>> cancelTrip({
    required String orderId,
    required String cancellationReason,
    required String token,
    http.Client? client,
  }) async {
    final httpClient = client ?? http.Client();
    try {
      final formattedToken = token.startsWith('Bearer ') ? token : 'Bearer $token';
      final res = await httpClient.post(
        Uri.parse('$baseUrl/orders/$orderId/status'),
        headers: {
          'Authorization': formattedToken,
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'status': 'CANCELLED_BY_RIDER',
          'cancellationReason': cancellationReason,
        }),
      );
      return jsonDecode(res.body) as Map<String, dynamic>;
    } finally {
      if (client == null) {
        httpClient.close();
      }
    }
  }
}
