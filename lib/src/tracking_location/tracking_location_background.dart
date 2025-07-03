import 'dart:io';

// Conditional import to handle background_location_2 package
import 'package:background_location_2/background_location.dart'
    if (dart.library.html) 'tracking_location_background_stub.dart';
import 'package:flutter/rendering.dart';

class TrackingLocationBackground {
  TrackingLocationBackground();

  static Future<void> startLocation() async {
    try {
      if (Platform.isIOS) {
        await BackgroundLocation.startLocationService(distanceFilter: 20);
      }
    } catch (e) {
      debugPrint('TrackingLocationBackground.startLocation error: $e');
      // Fallback to alternative location tracking if needed
    }
  }

  static Future<void> stopLocation() async {
    try {
      await BackgroundLocation.stopLocationService();
    } catch (e) {
      debugPrint('TrackingLocationBackground.stopLocation error: $e');
    }
  }
}
