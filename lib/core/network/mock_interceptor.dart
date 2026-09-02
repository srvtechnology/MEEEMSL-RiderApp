import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';

/// MockInterceptor intercepts Dio HTTP calls in demo/mock mode
/// to return realistic mock JSON responses.
class MockInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Add artificial network latency for realistic feel (300ms)
    await Future.delayed(const Duration(milliseconds: 300));

    final path = options.path;

    if (path.contains(ApiEndpoints.loginWithPassword)) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'token': 'mock_jwt_token_meeem_rider_secure_2026',
          'refreshToken': 'mock_jwt_refresh_token_2026',
          'rider': {
            'id': 'rider_9082',
            'name': 'Alex Johnson',
            'phone': '+1 555 234 5678',
            'email': options.data?['email'] ?? 'alex.rider@meeem.com',
            'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
            'rating': 4.92,
            'totalTrips': 1420,
            'isOnline': true,
            'walletBalance': 184.50,
            'approvalStatus': 'approved',
            'vehicle': {
              'type': '2-Wheeler',
              'model': 'Honda CB500X',
              'licensePlate': 'RD-8842-NY',
              'color': 'Sapphire Blue',
              'year': '2023',
            },
            'payoutInfo': {
              'methodType': 'bank',
              'bankName': 'Chase Bank USA',
              'accountNumber': '9920184920',
              'accountHolderName': 'Alex Johnson',
              'routingNumber': '021000021',
            },
            'operatingZones': ['zone_1', 'zone_2', 'zone_4'],
          }
        },
      ));
    }

    if (path.contains(ApiEndpoints.forgotPassword)) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'message': 'Password reset verification code sent',
        },
      ));
    }

    if (path.contains(ApiEndpoints.resetPassword)) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'message': 'Password has been reset successfully',
        },
      ));
    }

    if (path.contains(ApiEndpoints.operatingZones)) {
      if (options.method == 'POST') {
        return handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {'success': true, 'message': 'Operating zones updated successfully'},
        ));
      }
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': [
            {'id': 'zone_1', 'name': 'Downtown District', 'district': 'Central Zone', 'isSelected': true, 'surgeMultiplier': 1.2, 'activeRiders': 45},
            {'id': 'zone_2', 'name': 'North Heights & Uptown', 'district': 'North Zone', 'isSelected': true, 'surgeMultiplier': 1.0, 'activeRiders': 28},
            {'id': 'zone_3', 'name': 'South Bay & Marina', 'district': 'South Zone', 'isSelected': false, 'surgeMultiplier': 1.15, 'activeRiders': 32},
            {'id': 'zone_4', 'name': 'Financial Hub & Market St', 'district': 'East Zone', 'isSelected': true, 'surgeMultiplier': 1.3, 'activeRiders': 56},
            {'id': 'zone_5', 'name': 'Airport Logistics Hub', 'district': 'Special Hub', 'isSelected': false, 'surgeMultiplier': 1.1, 'activeRiders': 19},
            {'id': 'zone_6', 'name': 'West Campus & University', 'district': 'West Zone', 'isSelected': false, 'surgeMultiplier': 1.05, 'activeRiders': 24},
          ]
        },
      ));
    }

    if (path.contains(ApiEndpoints.payoutInfo)) {
      if (options.method == 'POST') {
        return handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {'success': true, 'data': options.data},
        ));
      }
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'methodType': 'bank',
            'bankName': 'Chase Bank USA',
            'accountNumber': '9920184920',
            'accountHolderName': 'Alex Johnson',
            'routingNumber': '021000021',
          }
        },
      ));
    }

    if (path.contains(ApiEndpoints.updateLocation)) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {'success': true, 'message': 'Location updated'},
      ));
    }

    if (path.contains(ApiEndpoints.updateVehicle)) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {'success': true, 'data': options.data},
      ));
    }

    if (path.contains(ApiEndpoints.login)) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'message': 'OTP sent successfully',
          'data': {
            'phone': options.data?['phone'] ?? '+1234567890',
            'isRegistered': true,
          }
        },
      ));
    }

    if (path.contains(ApiEndpoints.verifyOtp)) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'token': 'mock_jwt_token_meeem_rider_secure_2026',
          'refreshToken': 'mock_jwt_refresh_token_2026',
          'rider': {
            'id': 'rider_9082',
            'name': 'Alex Johnson',
            'phone': options.data?['phone'] ?? '+1 555 234 5678',
            'email': 'alex.rider@meeem.com',
            'avatar': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
            'rating': 4.92,
            'totalTrips': 1420,
            'isOnline': true,
            'walletBalance': 184.50,
            'approvalStatus': 'approved',
            'vehicle': {
              'type': '2-Wheeler',
              'model': 'Honda CB500X',
              'licensePlate': 'RD-8842-NY',
              'color': 'Sapphire Blue',
              'year': '2023',
            },
            'payoutInfo': {
              'methodType': 'bank',
              'bankName': 'Chase Bank USA',
              'accountNumber': '9920184920',
              'accountHolderName': 'Alex Johnson',
              'routingNumber': '021000021',
            },
            'operatingZones': ['zone_1', 'zone_2', 'zone_4'],
          }
        },
      ));
    }

    if (path.contains(ApiEndpoints.dashboardSummary)) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'todayEarnings': 148.50,
            'todayDeliveries': 9,
            'acceptanceRate': 96.5,
            'rating': 4.92,
            'onlineHours': 5.8,
            'weeklyEarnings': 892.20,
            'hasActiveOrder': true,
          }
        },
      ));
    }

    if (path.contains(ApiEndpoints.toggleOnline)) {
      final isOnline = options.data?['isOnline'] ?? true;
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'isOnline': isOnline,
          'message': isOnline ? 'You are now online' : 'You are now offline',
        },
      ));
    }

    if (path.contains(ApiEndpoints.activeOrders)) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': [
            {
              'id': 'ord_102948',
              'orderNumber': '#MM-8839',
              'status': 'in_transit', // accepted, arrived_at_pickup, picked_up, in_transit, arrived_at_dropoff, delivered
              'customerName': 'Sarah Jenkins',
              'customerPhone': '+1 555 987 6543',
              'customerAvatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
              'pickupName': 'Artisan Burger Co.',
              'pickupAddress': '742 Evergreen Terrace, Downtown',
              'pickupPhone': '+1 555 111 2233',
              'dropoffAddress': '124 Conch Street, Apt 4B, Uptown',
              'pickupLat': 40.7128,
              'pickupLng': -74.0060,
              'dropoffLat': 40.7306,
              'dropoffLng': -73.9352,
              'items': [
                {'name': 'Double Truffle Burger', 'quantity': 2, 'notes': 'No onions'},
                {'name': 'Loaded Truffle Fries', 'quantity': 1, 'notes': 'Extra crispy'},
                {'name': 'Salted Caramel Shake', 'quantity': 2, 'notes': ''},
              ],
              'subtotal': 48.50,
              'riderEarnings': 14.80,
              'distanceKm': 3.4,
              'estimatedDurationMin': 16,
              'createdAt': DateTime.now().subtract(const Duration(minutes: 25)).toIso8601String(),
              'notes': 'Please ring the doorbell and leave at door 4B.',
              'deliveryOtp': '4829',
            }
          ]
        },
      ));
    }

    if (path.contains(ApiEndpoints.incomingOrder)) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'id': 'ord_${DateTime.now().millisecondsSinceEpoch}',
            'orderNumber': '#MM-${(DateTime.now().millisecondsSinceEpoch % 9000) + 1000}',
            'status': 'pending',
            'customerName': 'Michael Chang',
            'customerPhone': '+1 555 333 4455',
            'customerAvatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
            'pickupName': 'Tokyo Sushi Lounge',
            'pickupAddress': '120 West 42nd St, Midtown',
            'pickupPhone': '+1 555 444 8899',
            'dropoffAddress': '450 Lexington Ave, Fl 18',
            'pickupLat': 40.7589,
            'pickupLng': -73.9851,
            'dropoffLat': 40.7527,
            'dropoffLng': -73.9772,
            'items': [
              {'name': 'Salmon Nigiri Combo (12 pcs)', 'quantity': 1, 'notes': 'Extra wasabi'},
              {'name': 'Dragon Roll', 'quantity': 2, 'notes': ''},
              {'name': 'Miso Soup', 'quantity': 2, 'notes': ''},
            ],
            'subtotal': 62.00,
            'riderEarnings': 18.25,
            'distanceKm': 2.8,
            'estimatedDurationMin': 14,
            'createdAt': DateTime.now().toIso8601String(),
            'notes': 'Security desk will call customer for lobby pickup.',
            'deliveryOtp': '6192',
          }
        },
      ));
    }

    if (path.contains(ApiEndpoints.earningsBreakdown)) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'todayEarnings': 148.50,
            'weeklyEarnings': 892.20,
            'monthlyEarnings': 3420.00,
            'availablePayout': 642.50,
            'completedTrips': 42,
            'basePay': 598.00,
            'tips': 184.20,
            'surgeBonuses': 110.00,
            'dailyData': [
              {'day': 'Mon', 'amount': 135.0},
              {'day': 'Tue', 'amount': 142.5},
              {'day': 'Wed', 'amount': 120.0},
              {'day': 'Thu', 'amount': 168.2},
              {'day': 'Fri', 'amount': 178.0},
              {'day': 'Sat', 'amount': 148.5},
              {'day': 'Sun', 'amount': 0.0},
            ],
            'recentTransactions': [
              {
                'id': 'tx_991',
                'orderNumber': '#MM-8839',
                'amount': 14.80,
                'tip': 4.00,
                'date': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
                'type': 'trip_earnings',
                'status': 'completed',
              },
              {
                'id': 'tx_990',
                'orderNumber': '#MM-8835',
                'amount': 18.50,
                'tip': 5.00,
                'date': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
                'type': 'trip_earnings',
                'status': 'completed',
              },
              {
                'id': 'tx_989',
                'orderNumber': 'Payout #PO-221',
                'amount': -250.00,
                'tip': 0.0,
                'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
                'type': 'withdrawal',
                'status': 'completed',
              }
            ]
          }
        },
      ));
    }

    if (path.contains(ApiEndpoints.orderHistory)) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': [
            {
              'id': 'ord_102940',
              'orderNumber': '#MM-8835',
              'status': 'delivered',
              'customerName': 'David Miller',
              'customerPhone': '+1 555 444 1122',
              'pickupName': 'Bella Italia Pizzeria',
              'pickupAddress': '45 Grand Ave, Soho',
              'dropoffAddress': '88 Mercer St, Apt 2',
              'riderEarnings': 18.50,
              'distanceKm': 2.1,
              'estimatedDurationMin': 12,
              'createdAt': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
              'items': [{'name': 'Margherita Pizza', 'quantity': 1, 'notes': ''}],
            },
            {
              'id': 'ord_102939',
              'orderNumber': '#MM-8832',
              'status': 'delivered',
              'customerName': 'Emma Watson',
              'customerPhone': '+1 555 777 8899',
              'pickupName': 'Green Bowl Salad Bar',
              'pickupAddress': '12 Broadway St',
              'dropoffAddress': '220 Canal Street',
              'riderEarnings': 12.25,
              'distanceKm': 1.5,
              'estimatedDurationMin': 9,
              'createdAt': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
              'items': [{'name': 'Avocado Quinoa Bowl', 'quantity': 1, 'notes': ''}],
            },
          ]
        },
      ));
    }

    if (path.contains(ApiEndpoints.getDocuments)) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': [
            {
              'type': 'driver_license',
              'title': "Driver's License",
              'documentNumber': 'DL-NY-9920194',
              'expiryDate': '2028-11-30',
              'status': 'verified',
            },
            {
              'type': 'vehicle_insurance',
              'title': 'Vehicle Insurance Certificate',
              'documentNumber': 'POL-90234-GE',
              'expiryDate': '2027-04-15',
              'status': 'verified',
            },
            {
              'type': 'vehicle_registration',
              'title': 'Vehicle Registration',
              'documentNumber': 'REG-449102-NY',
              'expiryDate': '2027-08-20',
              'status': 'verified',
            },
            {
              'type': 'background_check',
              'title': 'Background Verification Check',
              'documentNumber': 'BGC-2025-OK',
              'expiryDate': '2027-01-01',
              'status': 'verified',
            }
          ]
        },
      ));
    }

    // Default fallback
    return handler.resolve(Response(
      requestOptions: options,
      statusCode: 200,
      data: {'success': true, 'message': 'Success'},
    ));
  }
}
