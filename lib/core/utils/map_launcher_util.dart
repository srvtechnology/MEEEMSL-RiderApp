import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_strings.dart';
import '../theme/app_colors.dart';

/// MapLauncherUtil handles 1-tap navigation opening Google Maps, Apple Maps, or Waze.
class MapLauncherUtil {
  MapLauncherUtil._();

  /// Opens Google Maps with destination coordinates and optional address label.
  static Future<bool> openGoogleMaps({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final encodedLabel = Uri.encodeComponent(label ?? 'Destination');
    // Universal Google Maps navigation URL
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude&destination_place_id=$encodedLabel',
    );

    // Native Android/iOS Google Maps URI scheme
    final nativeUri = Uri.parse(
      Platform.isIOS
          ? 'comgooglemaps://?daddr=$latitude,$longitude&directionsmode=driving'
          : 'google.navigation:q=$latitude,$longitude&mode=d',
    );

    try {
      if (await canLaunchUrl(nativeUri)) {
        return await launchUrl(nativeUri, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(googleMapsUrl)) {
        return await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}

    Get.snackbar('Maps', 'Could not open Google Maps. Lat: $latitude, Lng: $longitude');
    return false;
  }

  /// Opens Apple Maps (iOS standard) with destination coordinates.
  static Future<bool> openAppleMaps({
    required double latitude,
    required double longitude,
    String? label,
  }) async {
    final encodedLabel = Uri.encodeComponent(label ?? 'Destination');
    final appleMapsUrl = Uri.parse(
      'https://maps.apple.com/?daddr=$latitude,$longitude&q=$encodedLabel',
    );

    try {
      if (await canLaunchUrl(appleMapsUrl)) {
        return await launchUrl(appleMapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}

    Get.snackbar('Maps', 'Could not open Apple Maps.');
    return false;
  }

  /// Displays a modal sheet to choose between Google Maps and Apple Maps.
  static void showMapOptionsModal({
    required BuildContext context,
    required double latitude,
    required double longitude,
    required String title,
    String? address,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.chooseMapApp,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                Text(
                  'To: $title\n${address ?? ''}',
                  style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.map, color: AppColors.primary),
                  ),
                  title: const Text(AppStrings.openInGoogleMaps, style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Turn-by-turn driving directions'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.pop(ctx);
                    openGoogleMaps(latitude: latitude, longitude: longitude, label: title);
                  },
                ),
                const Divider(),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.navigation_rounded, color: AppColors.secondary),
                  ),
                  title: const Text(AppStrings.openInAppleMaps, style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Apple Maps Navigation'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {
                    Navigator.pop(ctx);
                    openAppleMaps(latitude: latitude, longitude: longitude, label: title);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }
}
