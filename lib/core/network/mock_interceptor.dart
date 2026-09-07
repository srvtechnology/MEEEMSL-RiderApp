import 'dart:convert';
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
      return _resolve(handler, Response(
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
      return _resolve(handler, Response(
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
      return _resolve(handler, Response(
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
      return _resolve(handler, Response(
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

      return _resolve(handler, Response(
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
      return _resolve(handler, Response(
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
      return _resolve(handler, Response(
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
      return _resolve(handler, Response(
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
      Map<String, dynamic> incoming = {};
      if (options.data is FormData) {
        final fd = options.data as FormData;
        for (final entry in fd.fields) {
          try {
            incoming[entry.key] = jsonDecode(entry.value);
          } catch (_) {
            incoming[entry.key] = entry.value;
          }
        }
      } else if (options.data is Map<String, dynamic>) {
        incoming = options.data as Map<String, dynamic>;
      }

      final vType = incoming['vehicleType']?.toString() ?? '2_WHEELER';
      final vName = incoming['vehicleName']?.toString() ?? 'Honda CB Shine 125';
      final vNumber = incoming['vehicleNumber']?.toString() ?? 'SL-AA-9988';
      final dlNo = incoming['drivingLicenseNo']?.toString() ?? 'DL-10928374';

      List<String> parseList(dynamic raw, List<String> fallback) {
        if (raw is List) return raw.map((e) => e.toString()).toList();
        if (raw is String) {
          try {
            final decoded = jsonDecode(raw);
            if (decoded is List) return decoded.map((e) => e.toString()).toList();
          } catch (_) {}
        }
        return fallback;
      }

      final sZones = parseList(incoming['selectedZones'], ['ZONE 1', 'ZONE 2']);
      final sLocs = parseList(incoming['selectedLocations'], ['NO 2 RIVER', 'BAW BAW']);

      return _resolve(handler, Response(
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
              'vehicleType': vType,
              'vehicleTypes': [vType],
              'vehicleName': vName,
              'vehicleNumber': vNumber,
              'drivingLicenseNo': dlNo,
              'profileImage': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
              'drivingLicenseDoc': 'https://s3.amazonaws.com/meeem/docs/dl.png',
              'nationalIdDoc': 'https://s3.amazonaws.com/meeem/docs/id.png',
              'vehicleInsuranceDoc': 'https://s3.amazonaws.com/meeem/docs/ins.png',
              'selectedZones': sZones,
              'selectedLocations': sLocs,
            }
          }
        },
      ));
    }

    // 6.1 & 6.2 Profile GET and PATCH
    if (path.endsWith(ApiEndpoints.riderProfile)) {
      if (options.method == 'PATCH') {
        final patchData = options.data is Map ? options.data as Map : {};
        return _resolve(handler, Response(
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

      return _resolve(handler, Response(
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
        Map<String, dynamic> body = {};
        if (options.data is Map<String, dynamic>) {
          body = options.data as Map<String, dynamic>;
        } else if (options.data is FormData) {
          final fd = options.data as FormData;
          for (final f in fd.fields) {
            try {
              body[f.key] = jsonDecode(f.value);
            } catch (_) {
              body[f.key] = f.value;
            }
          }
        }

        // Validate password change if provided (Section 1 & 7.2 requirement: min 6 chars)
        final newPassword = body['newPassword']?.toString();
        if (newPassword != null && newPassword.isNotEmpty && newPassword.length < 6) {
          return _resolve(handler, Response(
            requestOptions: options,
            statusCode: 400,
            data: {
              'success': false,
              'error': 'Password must be at least 6 characters',
            },
          ));
        }

        final selectedZones = body['selectedZones'] is List
            ? (body['selectedZones'] as List).map((e) => e.toString()).toList()
            : ['ZONE 1', 'ZONE 2'];
        final selectedLocations = body['selectedLocations'] is List
            ? (body['selectedLocations'] as List).map((e) => e.toString()).toList()
            : ['NO 2 RIVER', 'BAW BAW'];

        return _resolve(handler, Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'success': true,
            'message': 'Settings updated successfully!',
            'data': {
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
                'selectedZones': selectedZones,
                'selectedLocations': selectedLocations,
              }
            }
          },
        ));
      }

      return _resolve(handler, Response(
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
            ],
            // Part 3 Section 4.1: Rider Settings & Stats
            'stats': {
              'totalEarnings': 640.00,
              'completedDeliveriesCount': 32,
              'activeDeliveriesCount': 1,
            }
          },
          'stats': {
            'totalEarnings': 640.00,
            'completedDeliveriesCount': 32,
            'activeDeliveriesCount': 1,
          }
        },
      ));
    }

    // 8.1 Delivery Zones & Hierarchical Locations
    if (path.endsWith(ApiEndpoints.zones)) {
      return _resolve(handler, Response(
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
        return _resolve(handler, Response(
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

      return _resolve(handler, Response(
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
      return _resolve(handler, Response(
        requestOptions: options,
        statusCode: 200,
        data: {'success': true, 'message': 'Logged out successfully'},
      ));
    }

    // Orders & Dashboard simulation fallback
    if (path.contains(ApiEndpoints.dashboardSummary)) {
      return _resolve(handler, Response(
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
      return _resolve(handler, Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'isOnline': isOnline,
          'message': isOnline ? 'You are now online' : 'You are now offline',
        },
      ));
    }

    // Part 2: 1.2 Fallback Background Telemetry (REST API)
    if (path.endsWith(ApiEndpoints.location) || path.endsWith('/mobileapi/rider/location')) {
      final lat = options.data is Map ? (options.data['latitude'] ?? 8.484245) : 8.484245;
      final lng = options.data is Map ? (options.data['longitude'] ?? -13.234125) : -13.234125;
      final isOnline = options.data is Map ? (options.data['isOnline'] ?? true) : true;
      return _resolve(handler, Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'message': 'Location updated successfully',
          'data': {
            'id': 'cuid_rider_id',
            'currentLatitude': lat,
            'currentLongitude': lng,
            'isOnline': isOnline,
            'lastLocationUpdate': DateTime.now().toUtc().toIso8601String(),
          }
        },
      ));
    }

    // Part 2: Delivery Orders (Section 3, 4, 5, 6)
    if (path.contains('/orders')) {
      return _resolve(handler, _handleOrdersEndpoint(options));
    }

    if (path.contains(ApiEndpoints.earningsBreakdown)) {
      return _resolve(handler, Response(
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

  void _resolve(RequestInterceptorHandler handler, Response response) {
    handler.resolve(response, true);
  }

  /// Generates a realistic mock response for any endpoint,
  /// used by ApiInterceptor to block non-Part 1 endpoints from making network calls.
  static Response getMockResponse(RequestOptions options) {
    final path = options.path;

    if (path.contains(ApiEndpoints.earningsBreakdown)) {
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'todayEarnings': 148.50,
            'weeklyEarnings': 892.20,
            'monthlyEarnings': 3420.00,
            'availablePayout': 240.00,
            'completedTrips': 45,
            'basePay': 720.00,
            'tips': 92.20,
            'surgeBonuses': 80.00,
            'dailyData': [
              {'day': 'Mon', 'amount': 45.0},
              {'day': 'Tue', 'amount': 62.5},
              {'day': 'Wed', 'amount': 38.0},
              {'day': 'Thu', 'amount': 84.0},
              {'day': 'Fri', 'amount': 95.0},
              {'day': 'Sat', 'amount': 120.0},
              {'day': 'Sun', 'amount': 80.0},
            ],
            'recentTransactions': [
              {
                'id': 'tx_1',
                'orderNumber': '#MM-8839',
                'amount': 14.80,
                'tip': 2.50,
                'date': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
                'type': 'trip_earnings',
                'status': 'completed',
              },
              {
                'id': 'tx_2',
                'orderNumber': '#MM-8831',
                'amount': 12.50,
                'tip': 3.00,
                'date': DateTime.now().subtract(const Duration(hours: 5)).toIso8601String(),
                'type': 'trip_earnings',
                'status': 'completed',
              },
            ]
          }
        },
      );
    }

    if (path.contains(ApiEndpoints.requestPayout) || path.contains(ApiEndpoints.payoutHistory)) {
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: {'success': true, 'message': 'Payout request processed successfully.'},
      );
    }

    if (path.contains(ApiEndpoints.payoutInfo)) {
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': {
            'methodType': 'bank',
            'bankName': 'Sierra Leone Commercial Bank',
            'accountNumber': '•••• 8829',
            'accountHolderName': 'Ibrahim Koroma',
            'routingNumber': '021000021',
          }
        },
      );
    }

    if (path.contains(ApiEndpoints.dashboardSummary)) {
      return Response(
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
            'hasActiveOrder': false,
          }
        },
      );
    }

    if (path.contains(ApiEndpoints.toggleOnline)) {
      final isOnline = options.data is Map ? (options.data['isOnline'] ?? true) : true;
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'isOnline': isOnline,
          'message': isOnline ? 'You are now online' : 'You are now offline',
        },
      );
    }

    // Part 2: Delivery Orders (Section 3, 4, 5, 6)
    if (path.contains('/orders')) {
      return _handleOrdersEndpoint(options);
    }

    // Part 2: 1.2 Fallback Background Telemetry (REST API)
    if (path.endsWith(ApiEndpoints.location) || path.endsWith('/mobileapi/rider/location')) {
      final lat = options.data is Map ? (options.data['latitude'] ?? 8.484245) : 8.484245;
      final lng = options.data is Map ? (options.data['longitude'] ?? -13.234125) : -13.234125;
      final isOnline = options.data is Map ? (options.data['isOnline'] ?? true) : true;
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'message': 'Location updated successfully',
          'data': {
            'id': 'cuid_rider_id',
            'currentLatitude': lat,
            'currentLongitude': lng,
            'isOnline': isOnline,
            'lastLocationUpdate': DateTime.now().toUtc().toIso8601String(),
          }
        },
      );
    }

    if (path.contains(ApiEndpoints.acceptOrder) ||
        path.contains(ApiEndpoints.declineOrder) ||
        path.contains(ApiEndpoints.updateOrderStatus) ||
        path.contains(ApiEndpoints.uploadProof) ||
        path.contains(ApiEndpoints.updateLocation) ||
        path.contains(ApiEndpoints.uploadDocument) ||
        path.contains(ApiEndpoints.operatingZones) ||
        path.contains(ApiEndpoints.updateVehicle) ||
        path.contains(ApiEndpoints.notifications) ||
        path.contains(ApiEndpoints.markNotificationRead) ||
        path.contains(ApiEndpoints.logout)) {
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: {'success': true, 'message': 'Operation processed locally.'},
      );
    }

    // Default safe fallback
    return Response(
      requestOptions: options,
      statusCode: 200,
      data: {'success': true, 'data': {}},
    );
  }

  /// Handles all Part 2 delivery order endpoints consistently for mock & demo modes.
  static Response _handleOrdersEndpoint(RequestOptions options) {
    final path = options.path;
    final method = options.method.toUpperCase();

    // 4.1 Accept Delivery Assignment: POST /orders/:id/accept
    if (path.endsWith('/accept')) {
      final assignmentId = path.split('/').reversed.skip(1).first;
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'message': 'Delivery assignment accepted successfully',
          'data': {
            'assignment': {
              'id': assignmentId.isEmpty ? 'cuid_assignment_id' : assignmentId,
              'status': 'ACCEPTED',
              'acceptedAt': DateTime.now().toUtc().toIso8601String(),
            },
            'deliveryOtp': '582910',
          },
        },
      );
    }

    // 4.2 Decline Delivery Offer: POST /orders/:id/reject
    if (path.endsWith('/reject')) {
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'message': 'Offer rejected. Cascaded to next available rider.',
        },
      );
    }

    // 5.1, 5.2, 6.1 Status Updates & Cancellation: POST /orders/:id/status
    if (path.endsWith('/status')) {
      final data = options.data is Map ? options.data as Map : {};
      final status = data['status']?.toString() ?? 'ACCEPTED';
      final assignmentId = path.split('/').reversed.skip(1).first;

      if (status == 'CANCELLED_BY_RIDER') {
        return Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'success': true,
            'cancelled': true,
            'message': 'Delivery cancelled and auto-reassigned to nearest available rider.',
          },
        );
      }

      if (status == 'DELIVERED') {
        final proofImage = data['proofImage']?.toString() ??
            'https://development.meeemsl.com/delivery-proofs/proof-123.jpg';
        return Response(
          requestOptions: options,
          statusCode: 200,
          data: {
            'success': true,
            'message': 'Delivery status updated to DELIVERED',
            'data': {
              'id': assignmentId.isEmpty ? 'cuid_assignment_id' : assignmentId,
              'status': 'DELIVERED',
              'deliveredAt': DateTime.now().toUtc().toIso8601String(),
              'deliveryProofImage': proofImage,
            },
          },
        );
      }

      return Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'message': 'Delivery status updated to $status',
          'data': {
            'id': assignmentId.isEmpty ? 'cuid_assignment_id' : assignmentId,
            'status': status,
            'updatedAt': DateTime.now().toUtc().toIso8601String(),
          },
        },
      );
    }

    // Legacy compatibility handlers
    if (path.contains('/orders/active')) {
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': [
            _buildPart2OrderAssignment(
              id: 'ord_102948',
              orderNumber: 'meeem00000042',
              status: 'ACCEPTED',
            ),
          ],
        },
      );
    }

    if (path.contains('/orders/history')) {
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': [
            _buildPart2OrderAssignment(
              id: 'ord_102940',
              orderNumber: 'meeem00000030',
              status: 'DELIVERED',
            ),
          ],
        },
      );
    }

    if (path.contains('/orders/incoming')) {
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: {'success': true, 'data': null},
      );
    }

    // 3.2 Single Delivery Order Snapshot: GET /orders/:id
    final uri = Uri.tryParse(path);
    final cleanPath = uri?.path ?? path;
    final segments = cleanPath.split('/').where((s) => s.isNotEmpty).toList();
    final ordersIdx = segments.indexOf('orders');
    if (ordersIdx != -1 &&
        segments.length > ordersIdx + 1 &&
        method == 'GET' &&
        !['active', 'history', 'incoming', 'details'].contains(segments[ordersIdx + 1])) {
      final orderOrAssignmentId = segments[ordersIdx + 1];
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'data': _buildPart2OrderAssignment(
            id: orderOrAssignmentId,
            orderNumber: 'meeem00000042',
            status: 'ACCEPTED',
          ),
        },
      );
    }

    // 3.1 Filtered Orders List: GET /orders?tab=active|offered|completed|all
    final tab = options.queryParameters['tab']?.toString() ?? 'active';
    if (tab == 'completed') {
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'tab': tab,
          'count': 2,
          'data': [
            _buildPart2OrderAssignment(
              id: 'ord_102940',
              orderNumber: 'meeem00000030',
              status: 'DELIVERED',
              pickupName: 'Tokeh Seafood Shack',
              dropoffAddress: 'Baw Baw Point #2',
              riderEarnings: 15.00,
              subtotal: 420000,
            ),
            _buildPart2OrderAssignment(
              id: 'ord_102935',
              orderNumber: 'meeem00000021',
              status: 'DELIVERED',
              pickupName: 'Lakka Ocean Grill',
              dropoffAddress: 'Hamilton Village Center',
              riderEarnings: 13.50,
              subtotal: 385000,
            ),
          ],
        },
      );
    }

    if (tab == 'offered') {
      return Response(
        requestOptions: options,
        statusCode: 200,
        data: {
          'success': true,
          'tab': tab,
          'count': 1,
          'data': [
            _buildPart2OrderAssignment(
              id: 'ord_offer_99',
              orderNumber: 'meeem00000042',
              status: 'OFFERED',
              pickupName: 'Electronics Hub',
              dropoffAddress: '14 Wilkinson Road, Freetown',
              riderEarnings: 18.50,
              subtotal: 450000,
            ),
          ],
        },
      );
    }

    // Default 'active'
    return Response(
      requestOptions: options,
      statusCode: 200,
      data: {
        'success': true,
        'tab': 'active',
        'count': 1,
        'data': [
          _buildPart2OrderAssignment(
            id: 'cuid_assignment_id',
            orderNumber: 'meeem00000042',
            status: 'ACCEPTED',
            pickupName: 'MEEEM Super Store',
            dropoffAddress: '14 Wilkinson Road, Freetown',
            riderEarnings: 14.80,
            subtotal: 450000,
          ),
        ],
      },
    );
  }

  static Map<String, dynamic> _buildPart2OrderAssignment({
    required String id,
    required String orderNumber,
    required String status,
    String pickupName = 'MEEEM Super Store',
    String dropoffAddress = '14 Wilkinson Road, Freetown',
    double riderEarnings = 14.80,
    double subtotal = 450000.0,
    double distanceKm = 2.1,
    String deliveryOtp = '582910',
  }) {
    return {
      'id': id,
      'orderId': 'order_$id',
      'status': status,
      'dispatchMode': 'AUTO_CASCADE',
      'distanceKm': distanceKm,
      'offeredAt': DateTime.now().subtract(const Duration(minutes: 5)).toUtc().toIso8601String(),
      'acceptedAt': DateTime.now().subtract(const Duration(minutes: 4)).toUtc().toIso8601String(),
      'deliveryOtp': deliveryOtp,
      'riderEarnings': riderEarnings,
      'estimatedDurationMin': 15,
      'order': {
        'id': 'order_$id',
        'orderNumber': orderNumber,
        'totalAmount': subtotal,
        'subtotal': subtotal - 20000,
        'shipping': 20000,
        'paymentMethod': 'COD',
        'paymentStatus': 'PENDING',
        'shippingFullName': 'Fatmata Koroma',
        'shippingPhone': '+23276123456',
        'shippingAddressLine1': dropoffAddress,
        'shippingCity': 'Freetown',
        'seller': {
          'store': {'name': pickupName},
          'businessInfo': {
            'businessName': '$pickupName Ltd',
            'pocContact': '+23277987654',
            'street': '25 Siaka Stevens St',
            'city': 'Freetown',
            'latitude': 8.484,
            'longitude': -13.234,
          },
        },
        'items': [
          {
            'id': 'cuid_item_1',
            'quantity': 1,
            'price': subtotal,
            'productNameSnapshot': 'Samsung Galaxy A54',
            'product': {
              'name': 'Samsung Galaxy A54',
              'images': ['https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=400'],
            },
          },
        ],
      },
    };
  }
}
