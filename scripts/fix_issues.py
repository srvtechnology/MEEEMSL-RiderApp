import os

# 1. lib/core/theme/app_theme.dart
with open('lib/core/theme/app_theme.dart', 'r') as f:
    content = f.read()
content = content.replace('cardTheme: CardTheme(', 'cardTheme: CardThemeData(')
with open('lib/core/theme/app_theme.dart', 'w') as f:
    f.write(content)

# 2. lib/core/error/failures.dart
with open('lib/core/error/failures.dart', 'r') as f:
    content = f.read()
content = content.replace('Either<Failure, T>', '`Either<Failure, T>`')
with open('lib/core/error/failures.dart', 'w') as f:
    f.write(content)

# 3. lib/core/network/mock_interceptor.dart
with open('lib/core/network/mock_interceptor.dart', 'r') as f:
    content = f.read()
content = content.replace("import 'dart:convert';\n", "")
with open('lib/core/network/mock_interceptor.dart', 'w') as f:
    f.write(content)

# 4. lib/core/utils/formatters.dart
with open('lib/core/utils/formatters.dart', 'r') as f:
    content = f.read()
old_dur = '''  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '\$minutes mins';
    }
    final hours = minutes ~/ 60;
    final remainingMins = minutes % 60;
    if (remainingMins == 0) return '\$hours hrs';
    return '\${hours}h \${remainingMins}m';
  }'''
new_dur = '''  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes mins';
    }
    final hours = minutes ~/ 60;
    final remainingMins = minutes % 60;
    if (remainingMins == 0) return '${hours} hrs';
    return '${hours}h ${remainingMins}m';
  }'''
content = content.replace(old_dur, new_dur)
with open('lib/core/utils/formatters.dart', 'w') as f:
    f.write(content)

# 5. lib/data/datasources/profile_remote_datasource.dart
with open('lib/data/datasources/profile_remote_datasource.dart', 'r') as f:
    content = f.read()
if "import '../../domain/entities/document_entity.dart';" not in content:
    content = "import '../../domain/entities/document_entity.dart';\n" + content
with open('lib/data/datasources/profile_remote_datasource.dart', 'w') as f:
    f.write(content)

# 6. lib/presentation/modules/auth/controllers/auth_controller.dart
with open('lib/presentation/modules/auth/controllers/auth_controller.dart', 'r') as f:
    content = f.read()
content = content.replace("import '../../../../domain/entities/rider_entity.dart';\n", "")
with open('lib/presentation/modules/auth/controllers/auth_controller.dart', 'w') as f:
    f.write(content)

# 7. lib/presentation/modules/dashboard/views/dashboard_view.dart
with open('lib/presentation/modules/dashboard/views/dashboard_view.dart', 'r') as f:
    content = f.read()
content = content.replace("activeColor: AppColors.success,", "activeTrackColor: AppColors.success,")
with open('lib/presentation/modules/dashboard/views/dashboard_view.dart', 'w') as f:
    f.write(content)

# 8. lib/presentation/modules/earnings/views/earnings_view.dart
with open('lib/presentation/modules/earnings/views/earnings_view.dart', 'r') as f:
    content = f.read()
content = content.replace("import '../../../../core/widgets/status_badge.dart';\n", "")
content = content.replace("90 * heightFactor,", "(90 * heightFactor).toDouble(),")
with open('lib/presentation/modules/earnings/views/earnings_view.dart', 'w') as f:
    f.write(content)

# 9. lib/presentation/modules/earnings/widgets/payout_request_bottom_sheet.dart
with open('lib/presentation/modules/earnings/widgets/payout_request_bottom_sheet.dart', 'r') as f:
    content = f.read()
content = content.replace("import '../../../../core/constants/app_strings.dart';\n", "")
content = content.replace("import '../../../../core/utils/formatters.dart';\n", "")
with open('lib/presentation/modules/earnings/widgets/payout_request_bottom_sheet.dart', 'w') as f:
    f.write(content)

# 10. lib/presentation/modules/main_layout/views/main_layout_view.dart
with open('lib/presentation/modules/main_layout/views/main_layout_view.dart', 'r') as f:
    content = f.read()
content = content.replace("import '../../../../core/theme/app_colors.dart';\n", "")
with open('lib/presentation/modules/main_layout/views/main_layout_view.dart', 'w') as f:
    f.write(content)

# 11. lib/presentation/modules/navigation/controllers/navigation_controller.dart
with open('lib/presentation/modules/navigation/controllers/navigation_controller.dart', 'r') as f:
    content = f.read()
content = content.replace(
    "final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=\$lat,\$lng');",
    "final url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=${lat},${lng}');"
)
with open('lib/presentation/modules/navigation/controllers/navigation_controller.dart', 'w') as f:
    f.write(content)

# 12. lib/presentation/modules/notifications/views/notifications_view.dart
with open('lib/presentation/modules/notifications/views/notifications_view.dart', 'r') as f:
    content = f.read()
content = content.replace("import '../../../../core/theme/app_colors.dart';\n", "")
with open('lib/presentation/modules/notifications/views/notifications_view.dart', 'w') as f:
    f.write(content)

# 13. lib/presentation/modules/orders/views/active_order_view.dart
with open('lib/presentation/modules/orders/views/active_order_view.dart', 'r') as f:
    content = f.read()
content = content.replace("import '../../../../core/utils/formatters.dart';\n", "")
with open('lib/presentation/modules/orders/views/active_order_view.dart', 'w') as f:
    f.write(content)

# 14. lib/presentation/modules/orders/views/order_details_view.dart
with open('lib/presentation/modules/orders/views/order_details_view.dart', 'r') as f:
    content = f.read()
content = content.replace("import 'package:get/get.dart';\n", "")
with open('lib/presentation/modules/orders/views/order_details_view.dart', 'w') as f:
    f.write(content)

# 15. lib/presentation/modules/orders/views/order_history_view.dart
with open('lib/presentation/modules/orders/views/order_history_view.dart', 'r') as f:
    content = f.read()
content = content.replace("import '../../../../core/constants/app_strings.dart';\n", "")
if "import '../../../../domain/entities/order_entity.dart';" not in content:
    content = "import '../../../../domain/entities/order_entity.dart';\n" + content
with open('lib/presentation/modules/orders/views/order_history_view.dart', 'w') as f:
    f.write(content)

# 16. lib/presentation/modules/profile/controllers/profile_controller.dart
with open('lib/presentation/modules/profile/controllers/profile_controller.dart', 'r') as f:
    content = f.read()
if "import '../../../../core/theme/app_colors.dart';" not in content:
    content = "import '../../../../core/theme/app_colors.dart';\n" + content
with open('lib/presentation/modules/profile/controllers/profile_controller.dart', 'w') as f:
    f.write(content)

print("Fixes applied.")
