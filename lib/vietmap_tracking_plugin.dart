import 'vietmap_tracking_plugin_platform_interface.dart';
import 'src/services/vietmap_preference.dart';
import 'src/tracking_location/tracking_service.dart';
import 'src/tracking_location/tracking_location.dart';
import 'src/models/gps_location.dart';
import 'package:http/http.dart' as http;

// Export tracking core components
export 'src/tracking_core.dart';
export 'src/tracking_location/tracking_service.dart';

/// Configuration class for VietmapTrackingPlugin
class VietmapTrackingConfig {
  final String apiKey;
  final String endpoint;
  final Map<String, dynamic>? additionalConfig;

  // Tracking service specific settings
  final int? batchSize;
  final Duration? batchInterval;
  final Duration? httpTimeout;
  final int? maxRetryAttempts;
  final int?
  trackingIntervalSeconds; // Tracking interval in seconds (default: 30)

  const VietmapTrackingConfig({
    required this.apiKey,
    required this.endpoint,
    this.additionalConfig,
    this.batchSize,
    this.batchInterval,
    this.httpTimeout,
    this.maxRetryAttempts,
    this.trackingIntervalSeconds, // Default will be 30 seconds
  });

  Map<String, dynamic> toMap() {
    return {
      'apiKey': apiKey,
      'endpoint': endpoint,
      'additionalConfig': additionalConfig ?? {},
      if (batchSize != null) 'batchSize': batchSize,
      if (batchInterval != null) 'batchInterval': batchInterval!.inMilliseconds,
      if (httpTimeout != null) 'httpTimeout': httpTimeout!.inMilliseconds,
      if (maxRetryAttempts != null) 'maxRetryAttempts': maxRetryAttempts,
      if (trackingIntervalSeconds != null)
        'trackingIntervalSeconds': trackingIntervalSeconds,
    };
  }
}

/// Main plugin class for Vietmap Tracking SDK
class VietmapTrackingPlugin {
  static VietmapTrackingPlugin? _instance;

  /// Singleton instance
  static VietmapTrackingPlugin get instance {
    _instance ??= VietmapTrackingPlugin._();
    return _instance!;
  }

  VietmapTrackingPlugin._();

  /// Initialize the SDK with configuration
  ///
  /// Example:
  /// ```dart
  /// await VietmapTrackingPlugin.instance.initialize(
  ///   VietmapTrackingConfig(
  ///     apiKey: 'your-api-key',
  ///     endpoint: 'https://api.vietmap.vn/tracking',
  ///   ),
  /// );
  /// ```
  Future<void> initialize(VietmapTrackingConfig config) async {
    await VietmapTrackingPluginPlatform.instance.initialize(
      apiKey: config.apiKey,
      endpoint: config.endpoint,
      additionalConfig: config.additionalConfig,
    );

    // Store configuration in preferences for TrackingLocation to use
    await VietMapPreference().setApiKey(config.apiKey);
    await VietMapPreference().setEndPoint(config.endpoint);

    // Store tracking interval (default 30 seconds if not specified)
    final trackingIntervalSeconds = config.trackingIntervalSeconds ?? 30;
    await VietMapPreference().setTrackingInterval(trackingIntervalSeconds);
  }

  /// Update the API key
  Future<void> setApiKey(String apiKey) {
    return VietmapTrackingPluginPlatform.instance.setApiKey(apiKey);
  }

  /// Update the endpoint URL
  Future<void> setEndpoint(String endpoint) {
    return VietmapTrackingPluginPlatform.instance.setEndpoint(endpoint);
  }

  /// Get current configuration
  Future<Map<String, dynamic>?> getConfiguration() {
    return VietmapTrackingPluginPlatform.instance.getConfiguration();
  }

  /// Check if SDK is initialized
  Future<bool> isInitialized() {
    return VietmapTrackingPluginPlatform.instance.isInitialized();
  }

  /// Get platform version (for debugging)
  Future<String?> getPlatformVersion() {
    return VietmapTrackingPluginPlatform.instance.getPlatformVersion();
  }

  // ============ Background Tracking Service Methods ============

  /// Initialize background tracking service
  /// Call this once during app initialization, preferably in main()
  Future<void> initializeBackgroundService() async {
    await TrackingService.initializeService();
  }

  /// Start background location tracking
  /// This will start the background service and begin collecting GPS data
  Future<void> startLocationTracking() async {
    final isInitialized = await this.isInitialized();
    if (!isInitialized) {
      throw Exception(
        'SDK must be initialized before starting location tracking. Call initialize() first.',
      );
    }

    await TrackingService.start();
  }

  /// Stop background location tracking
  /// This will stop the background service and GPS collection
  Future<void> stopLocationTracking() async {
    await TrackingService.stop();
  }

  /// Check if background tracking service is currently running
  Future<bool> isTrackingServiceRunning() async {
    return await TrackingService.checkServiceStart();
  }

  /// Get current tracking status
  bool get isCurrentlyTracking => TrackingService.trackingLocation;

  /// Handle async data processing (for offline data sync)
  Future<void> handleAsyncData() async {
    TrackingService.handleAsyncData();
  }

  /// Send a single GPS location
  Future<bool> sendLocation(GpsLocation location) async {
    try {
      await TrackingLocation.sendDataToServer(location);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Test connection to the tracking server
  Future<Map<String, dynamic>> testConnection() async {
    try {
      var baseUrl = await VietMapPreference().getEndPoint();
      var apiKey = await VietMapPreference().getApiKey();

      if (baseUrl == null || apiKey == null) {
        return {
          'success': false,
          'message': 'Configuration not found',
          'statusCode': 0,
        };
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/health'),
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Accept': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 10));

      return {
        'success': response.statusCode >= 200 && response.statusCode < 300,
        'message': response.statusCode >= 200 && response.statusCode < 300
            ? 'Connection successful'
            : 'Connection failed',
        'statusCode': response.statusCode,
        'data': response.body,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
        'statusCode': 0,
      };
    }
  }

  /// Get cached/failed locations count
  Future<int> getCachedLocationsCount() async {
    final cachedLocations = await VietMapPreference().getListGPSCache();
    return cachedLocations?.length ?? 0;
  }

  /// Clear cached/failed locations
  Future<void> clearCachedLocations() async {
    await VietMapPreference().setListGPS([]);
  }

  /// Update tracking interval
  Future<void> setTrackingInterval(int seconds) async {
    await TrackingLocation.updateTrackingInterval(seconds);
  }

  /// Get current tracking interval in seconds
  Future<int> getTrackingInterval() async {
    return await VietMapPreference().getTrackingInterval();
  }
}
