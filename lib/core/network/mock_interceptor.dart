import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';

/// MockInterceptor intercepts Dio HTTP calls in demo/mock mode
/// to return realistic mock JSON responses conforming to
/// MEEEM Delivery Network — Rider Mobile App API Doc (Part 1).
class MockInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Add artificial network latency for realistic feel (250ms)
    await Future.delayed(const Duration(milliseconds: 250));

    final path = options.path;

    // 2.1 Rider Self-Registration
    if (path.endsWith(ApiEndpoints.register)) {
      final name = options.data?['name'] ?? 'Ibrahim Koroma';
      final email = options.data?['email'] ?? 'rider.ibrahim@example.com';
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 201,
        data: {
          'success': true,
          'message': 'Registration successful. Please verify your email with the 6-digit OTP sent.',
          'data': {
            'userId': 'cm7user_${DateTime.now().millisecondsSinceEpoch}',
            'email': email,
            'name': name,
            'role': 'RIDER',
            'requiresVerification': true,
            'verificationDetails': {
              'method': 'OTP',
              'expiresIn': 600,
              'resendCooldown': 60,
            },
            'verifyUrl': '/mobileapi/rider/auth/verify-otp',
          }
        },
      ));
    }

    // 2.2 Verify Registration OTP
    if (path.endsWith(ApiEndpoints.verifyRegistrationOtp)) {
      final email = options.data?['email'] ?? 'rider.ibrahim@example.com';
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'message': 'Email verified successfully! You can now log in to complete your rider onboarding.',
          'data': {
            'email': email,
            'isEmailVerified': true,
            'loginAvailable': true,
            'onboardingCompleted': false,
          }
        },
      ));
    }

    // 2.3 Resend Registration OTP
    if (path.endsWith(ApiEndpoints.resendRegistrationOtp)) {
      final email = options.data?['email'] ?? 'rider.ibrahim@example.com';
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'message': 'New verification code has been sent.',
          'data': {
            'email': email,
            'expiresIn': 600,
            'resendCooldown': 60,
          }
        },
      ));
    }

    // 3.2 A) Phone OTP Send
    if (path.endsWith(ApiEndpoints.phoneOtpSend)) {
      final phone = options.data?['phone'] ?? '+23276123456';
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'message': 'Login OTP sent to your phone.',
          'data': {
            'phone': phone,
            'expiresIn': 600,
            'resendCooldown': 60,
          }
        },
      ));
    }

    // 3.1 Email & Password Login OR 3.2 B) Phone OTP Verify
    if (path.endsWith(ApiEndpoints.login) || path.endsWith(ApiEndpoints.phoneOtpVerify)) {
      final email = options.data?['email'] ?? 'rider.ibrahim@example.com';
      final phone = options.data?['phone'] ?? '76123456';

      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'message': 'Login successful',
          'data': {
            'user': {
              'id': 'cm7abc123000',
              'email': email,
              'name': 'Ibrahim Koroma',
              'role': 'RIDER',
              'phone': phone,
              'phoneCountryCode': '+232',
              'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
              'isEmailVerified': true,
              'createdAt': '2026-08-26T10:00:00.000Z',
            },
            'rider': {
              'id': 'cm7rider0001',
              'isApproved': true,
              'isSuspended': false,
              'status': 'APPROVED',
              'onboardingCompleted': true,
              'isFirstLogin': false,
              'vehicleType': '2_WHEELER',
              'vehicleTypes': ['2_WHEELER'],
              'vehicleName': 'Honda CB Shine 125',
              'vehicleNumber': 'SL-AA-9988',
              'drivingLicenseNo': 'DL-10928374',
              'profileImage': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
              'selectedZones': ['ZONE 1', 'ZONE 2'],
              'selectedLocations': ['NO 2 RIVER', 'BAW BAW', 'HAMILTON', 'LAKKA'],
            },
            'tokens': {
              'accessToken': 'mock_jwt_access_token_meeem_rider_2026',
              'refreshToken': 'mock_jwt_refresh_token_meeem_rider_2026',
              'expiresIn': 172800,
            },
            'sessionInfo': {
              'expiresIn': 172800,
              'tokenType': 'Bearer',
            }
          }
        },
      ));
    }

    // 3.3 Refresh JWT Tokens
    if (path.endsWith(ApiEndpoints.refreshToken)) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'accessToken': 'mock_refreshed_access_token_${DateTime.now().millisecondsSinceEpoch}',
            'expiresIn': 172800,
            'tokenType': 'Bearer',
          }
        },
      ));
    }

    // 4.1 Forgot Password Send OTP
    if (path.endsWith(ApiEndpoints.forgotPasswordSendOtp)) {
      final email = options.data?['email'] ?? 'rider.ibrahim@example.com';
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'message': 'If an active rider account exists, a reset OTP has been sent.',
          'data': {
            'email': email,
            'expiresIn': 600,
            'resendCooldown': 60,
          }
        },
      ));
    }

    // 4.2 Reset Password
    if (path.endsWith(ApiEndpoints.forgotPasswordReset)) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'message': 'Password reset successful. You can now log in with your new password.',
          'data': {
            'loginAvailable': true,
          }
        },
      ));
    }

    // 5.1 First-Time Onboarding
    if (path.endsWith(ApiEndpoints.onboarding)) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'message': 'Rider onboarding completed successfully!',
          'data': {
            'onboardingCompleted': true,
            'rider': {
              'id': 'cm7rider0001',
              'isApproved': true,
              'status': 'APPROVED',
              'onboardingCompleted': true,
              'isFirstLogin': false,
              'vehicleType': '2_WHEELER',
              'vehicleTypes': ['2_WHEELER'],
              'vehicleName': 'Honda CB Shine 125',
              'vehicleNumber': 'SL-AA-9988',
              'drivingLicenseNo': 'DL-10928374',
              'profileImage': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
              'drivingLicenseDoc': 'https://s3.amazonaws.com/meeem/docs/dl.png',
              'nationalIdDoc': 'https://s3.amazonaws.com/meeem/docs/id.png',
              'vehicleInsuranceDoc': 'https://s3.amazonaws.com/meeem/docs/ins.png',
              'selectedZones': ['ZONE 1', 'ZONE 2'],
              'selectedLocations': ['NO 2 RIVER', 'BAW BAW'],
            }
          }
        },
      ));
    }

    // 6.1 & 6.2 Profile GET and PATCH
    if (path.endsWith(ApiEndpoints.riderProfile)) {
      if (options.method == 'PATCH') {
        final patchData = options.data is Map ? options.data as Map : {};
        return handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'success': true,
            'message': 'Profile updated successfully.',
            'data': {
              'rider': {
                'id': 'cm7rider0001',
                'isApproved': true,
                'isSuspended': false,
                'status': 'APPROVED',
                'vehicleType': patchData['vehicleType'] ?? '2_WHEELER',
                'vehicleTypes': [patchData['vehicleType'] ?? '2_WHEELER'],
                'vehicleName': patchData['vehicleName'] ?? 'Honda CB Shine 125 Super',
                'vehicleNumber': patchData['vehicleNumber'] ?? 'SL-AA-9988-NEW',
                'drivingLicenseNo': 'DL-10928374',
              }
            }
          },
        ));
      }

      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'user': {
              'id': 'cm7abc123000',
              'email': 'rider.ibrahim@example.com',
              'name': 'Ibrahim Koroma',
              'phone': '76123456',
              'phoneCountryCode': '+232',
              'image': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
              'isEmailVerified': true,
            },
            'rider': {
              'id': 'cm7rider0001',
              'isApproved': true,
              'isSuspended': false,
              'status': 'APPROVED',
              'vehicleType': '2_WHEELER',
              'vehicleTypes': ['2_WHEELER'],
              'vehicleName': 'Honda CB Shine 125',
              'vehicleNumber': 'SL-AA-9988',
              'drivingLicenseNo': 'DL-10928374',
              'profileImage': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
              'selectedZones': ['ZONE 1', 'ZONE 2'],
              'selectedLocations': ['NO 2 RIVER', 'BAW BAW', 'HAMILTON', 'LAKKA'],
            }
          }
        },
      ));
    }

    // 7.1 & 7.2 Settings GET and POST
    if (path.endsWith(ApiEndpoints.settings)) {
      if (options.method == 'POST') {
        return handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'success': true,
            'message': 'Settings updated successfully!',
            'data': {
              'rider': {
                'id': 'cm7rider0001',
                'selectedZones': options.data?['selectedZones'] ?? ['ZONE 1'],
                'selectedLocations': options.data?['selectedLocations'] ?? ['NO 2 RIVER'],
              }
            }
          },
        ));
      }

      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'user': {
              'id': 'cm7abc123000',
              'email': 'rider.ibrahim@example.com',
              'name': 'Ibrahim Koroma',
              'phone': '76123456',
              'phoneCountryCode': '+232',
            },
            'rider': {
              'id': 'cm7rider0001',
              'isApproved': true,
              'isSuspended': false,
              'status': 'APPROVED',
              'selectedZones': ['ZONE 1', 'ZONE 2'],
              'selectedLocations': ['NO 2 RIVER', 'BAW BAW', 'HAMILTON', 'LAKKA'],
            },
            'registeredDevices': [
              {
                'token': 'mock_fcm_token_1',
                'deviceId': 'android-uuid-1',
                'platform': 'android',
                'deviceModel': 'Samsung Galaxy S22',
                'lastActiveAt': '2026-08-26T12:00:00.000Z',
              },
              {
                'token': 'mock_fcm_token_2',
                'deviceId': 'iphone-uuid-2',
                'platform': 'ios',
                'deviceModel': 'iPhone 15 Pro',
                'lastActiveAt': '2026-08-27T10:30:00.000Z',
              }
            ]
          }
        },
      ));
    }

    // 8.1 Delivery Zones & Hierarchical Locations
    if (path.endsWith(ApiEndpoints.zones)) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'totalZones': 4,
            'totalLocations': 15,
            'zones': [
              {
                'id': 'ZONE 1',
                'name': 'ZONE 1 (Western Rural)',
                'regions': [
                  {'name': 'NO 2 RIVER'},
                  {'name': 'BAW BAW'},
                  {'name': 'BIG WATER'},
                  {'name': 'JOHN OBEY'},
                  {'name': 'MAMA BEACH'},
                  {'name': 'TOKEH'},
                  {'name': 'YORK'},
                ]
              },
              {
                'id': 'ZONE 2',
                'name': 'ZONE 2 (Peninsula Area)',
                'regions': [
                  {'name': 'HAMILTON'},
                  {'name': 'LAKKA'},
                  {'name': 'SUSSEX'},
                  {'name': 'KIMBO VILLAGE'},
                ]
              },
              {
                'id': 'ZONE 3',
                'name': 'ZONE 3 (Central Business)',
                'regions': [
                  {'name': 'COTTON TREE'},
                  {'name': 'SIAKA STEVENS ST'},
                  {'name': 'CONNAUGHT'},
                ]
              },
              {
                'id': 'ZONE 4',
                'name': 'ZONE 4 (East End)',
                'regions': [
                  {'name': 'CLINE TOWN'},
                  {'name': 'KISSY'},
                  {'name': 'WELLINGTON'},
                ]
              }
            ]
          }
        },
      ));
    }

    // 9.1 & 9.2 Push Token Management
    if (path.endsWith(ApiEndpoints.deviceToken)) {
      if (options.method == 'DELETE') {
        return handler.resolve(Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'success': true,
            'message': 'Device token unregistered successfully.',
            'data': {
              'remainingDevicesCount': 0,
            }
          },
        ));
      }

      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'message': 'Device token registered successfully for push notifications.',
          'data': {
            'registeredTokensCount': 1,
            'devices': [
              {
                'token': options.data?['token'] ?? 'mock_fcm_token_device',
                'deviceId': options.data?['deviceId'] ?? 'mock_device_uuid',
                'platform': options.data?['platform'] ?? 'android',
                'deviceModel': options.data?['deviceModel'] ?? 'Generic Phone',
                'lastActiveAt': DateTime.now().toIso8601String(),
                'createdAt': DateTime.now().toIso8601String(),
              }
            ]
          }
        },
      ));
    }

    // Logout
    if (path.endsWith(ApiEndpoints.logout)) {
      return handler.resolve(Response(
        requestOptions: options,
        statusCode: 200,
        data: {'success': true, 'message': 'Logged out successfully'},
      ));
    }

    // Orders & Dashboard simulation fallback
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
              'status': 'in_transit',
              'customerName': 'Sarah Jenkins',
              'customerPhone': '+232 76 998877',
              'customerAvatar': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=200',
              'pickupName': 'Mama Beach Grill',
              'pickupAddress': 'Mama Beach, Zone 1',
              'pickupPhone': '+232 76 112233',
              'dropoffAddress': 'No 2 River Beach House #4',
              'pickupLat': 8.484,
              'pickupLng': -13.234,
              'dropoffLat': 8.460,
              'dropoffLng': -13.250,
              'items': [
                {'name': 'Grilled Barracuda & Plantain', 'quantity': 2, 'notes': 'Extra spicy sauce'},
                {'name': 'Ginger Beer (Cold)', 'quantity': 2, 'notes': ''},
              ],
              'subtotal': 48.50,
              'riderEarnings': 14.80,
              'distanceKm': 3.4,
              'estimatedDurationMin': 16,
              'createdAt': DateTime.now().subtract(const Duration(minutes: 25)).toIso8601String(),
              'notes': 'Please call when arriving at the gate.',
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
            'customerName': 'Michael Koroma',
            'customerPhone': '+232 76 443322',
            'customerAvatar': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200',
            'pickupName': 'Lakka Ocean Bites',
            'pickupAddress': 'Lakka Beach Road',
            'pickupPhone': '+232 76 887766',
            'dropoffAddress': 'Hamilton Junction',
            'pickupLat': 8.470,
            'pickupLng': -13.240,
            'dropoffLat': 8.455,
            'dropoffLng': -13.255,
            'items': [
              {'name': 'Cassava Leaf Stew with Rice', 'quantity': 1, 'notes': ''},
              {'name': 'Star Beer', 'quantity': 1, 'notes': 'Chilled'},
            ],
            'subtotal': 35.00,
            'riderEarnings': 12.50,
            'distanceKm': 2.8,
            'estimatedDurationMin': 14,
            'createdAt': DateTime.now().toIso8601String(),
            'notes': 'Call on arrival.',
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
            'totalBalance': 284.50,
            'availableForPayout': 240.00,
            'pendingPayout': 44.50,
            'todayTips': 18.00,
            'weeklyBreakdown': [
              {'day': 'Mon', 'amount': 45.0, 'deliveries': 3},
              {'day': 'Tue', 'amount': 62.5, 'deliveries': 4},
              {'day': 'Wed', 'amount': 38.0, 'deliveries': 2},
              {'day': 'Thu', 'amount': 84.0, 'deliveries': 5},
              {'day': 'Fri', 'amount': 95.0, 'deliveries': 6},
              {'day': 'Sat', 'amount': 120.0, 'deliveries': 8},
              {'day': 'Sun', 'amount': 80.0, 'deliveries': 5},
            ]
          }
        },
      ));
    }

    // Default passthrough fallback
    return handler.next(options);
  }
}
