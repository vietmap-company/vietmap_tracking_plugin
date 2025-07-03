// Stub implementation for web/unsupported platforms
class BackgroundLocation {
  static Future<void> startLocationService({double? distanceFilter}) async {
    throw UnsupportedError(
      'BackgroundLocation is not supported on this platform',
    );
  }

  static Future<void> stopLocationService() async {
    throw UnsupportedError(
      'BackgroundLocation is not supported on this platform',
    );
  }
}
