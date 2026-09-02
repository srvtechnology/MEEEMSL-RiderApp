import os

files = {}

# 1. lib/core/network/mock_interceptor.dart
files['lib/core/network/mock_interceptor.dart'] = '''import 'dart:convert';
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
              'type': 'Motorcycle',
              'model': 'Honda CB500X',
              'licensePlate': 'RD-8842-NY',
              'color': 'Sapphire Blue',
              'year': '2023',
            }
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
'''

# 2. lib/core/network/api_interceptor.dart
files['lib/core/network/api_interceptor.dart'] = '''import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../constants/app_constants.dart';

/// ApiInterceptor attaches Bearer auth tokens to outgoing requests
/// and formats Dio errors cleanly.
class ApiInterceptor extends Interceptor {
  final GetStorage _storage = GetStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _storage.read<String>(AppConstants.tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer \$token';
    }
    options.headers['Accept'] = 'application/json';
    options.headers['Content-Type'] = 'application/json';

    return super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Standardized error handling & logging
    return super.onError(err, handler);
  }
}
'''

# 3. lib/core/network/dio_client.dart
files['lib/core/network/dio_client.dart'] = '''import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../constants/app_constants.dart';
import 'api_interceptor.dart';
import 'mock_interceptor.dart';

/// DioClient configures and exposes the central Dio HTTP client.
class DioClient {
  late final Dio dio;

  DioClient() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(milliseconds: AppConstants.connectionTimeoutMs),
        receiveTimeout: const Duration(milliseconds: AppConstants.receiveTimeoutMs),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // If mock mode is enabled, intercept with realistic simulated backend
    if (AppConstants.useMockApi) {
      dio.interceptors.add(MockInterceptor());
    } else {
      dio.interceptors.add(ApiInterceptor());
    }

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
    ));
  }
}
'''

# 4. lib/core/widgets/custom_button.dart
files['lib/core/widgets/custom_button.dart'] = '''import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ButtonType { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;
  final Color? customColor;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 52,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (type == ButtonType.outline) {
      return SizedBox(
        width: width ?? double.infinity,
        height: height,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: customColor ?? (isDark ? AppColors.primaryLight : AppColors.primary),
            side: BorderSide(
              color: customColor ?? (isDark ? AppColors.primaryLight : AppColors.primary),
              width: 1.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _buildChild(customColor ?? (isDark ? AppColors.primaryLight : AppColors.primary)),
        ),
      );
    }

    if (type == ButtonType.text) {
      return SizedBox(
        width: width,
        height: height,
        child: TextButton(
          onPressed: isLoading ? null : onPressed,
          child: _buildChild(customColor ?? (isDark ? AppColors.primaryLight : AppColors.primary)),
        ),
      );
    }

    // Primary or Secondary
    final bgColor = customColor ??
        (type == ButtonType.secondary ? AppColors.secondary : AppColors.primary);

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _buildChild(Colors.white),
      ),
    );
  }

  Widget _buildChild(Color textColor) {
    if (isLoading) {
      return const SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: textColor),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
    );
  }
}
'''

# 5. lib/core/widgets/swipe_button.dart
files['lib/core/widgets/swipe_button.dart'] = '''import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

/// SwipeButton provides an intuitive swipe-to-confirm action
/// preventing accidental taps for critical rider steps (Pickup, Complete Delivery).
class SwipeButton extends StatefulWidget {
  final String text;
  final VoidCallback onSwiped;
  final Color activeColor;
  final Color backgroundColor;
  final IconData icon;
  final bool isCompleted;

  const SwipeButton({
    super.key,
    required this.text,
    required this.onSwiped,
    this.activeColor = AppColors.primary,
    this.backgroundColor = AppColors.primaryContainer,
    this.icon = Icons.arrow_forward_rounded,
    this.isCompleted = false,
  });

  @override
  State<SwipeButton> createState() => _SwipeButtonState();
}

class _SwipeButtonState extends State<SwipeButton> {
  double _dragPosition = 0.0;
  bool _isConfirmed = false;

  @override
  Widget build(BuildContext context) {
    const double height = 58.0;
    const double thumbSize = 48.0;
    const double padding = 5.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxDrag = constraints.maxWidth - thumbSize - (padding * 2);

        return Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: widget.activeColor.withAlpha(50),
              width: 1.5,
            ),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Center Label
              Center(
                child: Padding(
                  padding: const EdgeInsets.only(left: thumbSize),
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: widget.activeColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              // Active Swipe Trail
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: _dragPosition + thumbSize + padding * 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: widget.activeColor.withAlpha(40),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),

              // Draggable Thumb
              Positioned(
                left: padding + _dragPosition,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    if (_isConfirmed) return;
                    setState(() {
                      _dragPosition += details.delta.dx;
                      if (_dragPosition < 0) _dragPosition = 0;
                      if (_dragPosition > maxDrag) _dragPosition = maxDrag;
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_isConfirmed) return;
                    if (_dragPosition >= maxDrag * 0.75) {
                      // Trigger confirmation
                      setState(() {
                        _dragPosition = maxDrag;
                        _isConfirmed = true;
                      });
                      HapticFeedback.heavyImpact();
                      widget.onSwiped();
                    } else {
                      // Snap back
                      setState(() {
                        _dragPosition = 0.0;
                      });
                    }
                  },
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      color: widget.activeColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: widget.activeColor.withAlpha(100),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
'''

# 6. lib/core/widgets/custom_text_field.dart
files['lib/core/widgets/custom_text_field.dart'] = '''import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hintText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomTextField({
    super.key,
    this.controller,
    this.label,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.primary, size: 20)
                : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
'''

# 7. lib/core/widgets/status_badge.dart
files['lib/core/widgets/status_badge.dart'] = '''import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum BadgeType { success, warning, error, info, neutral }

class StatusBadge extends StatelessWidget {
  final String text;
  final BadgeType type;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.text,
    this.type = BadgeType.info,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case BadgeType.success:
        bg = AppColors.successLight;
        fg = AppColors.successDark;
        break;
      case BadgeType.warning:
        bg = AppColors.warningLight;
        fg = AppColors.warningDark;
        break;
      case BadgeType.error:
        bg = AppColors.errorLight;
        fg = AppColors.errorDark;
        break;
      case BadgeType.info:
        bg = AppColors.infoLight;
        fg = AppColors.infoDark;
        break;
      case BadgeType.neutral:
        bg = AppColors.lightSurfaceVariant;
        fg = AppColors.textSecondaryLight;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}
'''

# 8. lib/core/widgets/loading_overlay.dart
files['lib/core/widgets/loading_overlay.dart'] = '''import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LoadingOverlay extends StatelessWidget {
  final String? message;

  const LoadingOverlay({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 16,
                offset: Offset(0, 4),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              if (message != null) ...[
                const SizedBox(height: 16),
                Text(
                  message!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
'''

# 9. lib/core/widgets/empty_state_view.dart
files['lib/core/widgets/empty_state_view.dart'] = '''import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import 'custom_button.dart';

class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: AppColors.primary),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryLight,
                height: 1.4,
              ),
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              CustomButton(
                text: buttonText!,
                onPressed: onButtonPressed,
                width: 180,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
'''

# 10. lib/core/widgets/custom_card.dart
files['lib/core/widgets/custom_card.dart'] = '''import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Border? border;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.backgroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? (isDark ? AppColors.darkSurface : AppColors.lightSurface),
            borderRadius: BorderRadius.circular(16),
            border: border ??
                Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                  width: 1,
                ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(isDark ? 30 : 10),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
'''

for path, content in files.items():
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, 'w') as f:
        f.write(content)
    print(f"Created: {path}")

