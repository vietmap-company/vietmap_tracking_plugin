import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'vietmap_tracking_plugin_method_channel.dart';

abstract class VietmapTrackingPluginPlatform extends PlatformInterface {
  /// Constructs a VietmapTrackingPluginPlatform.
  VietmapTrackingPluginPlatform() : super(token: _token);

  static final Object _token = Object();

  static VietmapTrackingPluginPlatform _instance =
      MethodChannelVietmapTrackingPlugin();

  /// The default instance of [VietmapTrackingPluginPlatform] to use.
  ///
  /// Defaults to [MethodChannelVietmapTrackingPlugin].
  static VietmapTrackingPluginPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [VietmapTrackingPluginPlatform] when
  /// they register themselves.
  static set instance(VietmapTrackingPluginPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  /// Initialize the SDK with configuration
  Future<void> initialize({
    required String apiKey,
    required String endpoint,
    Map<String, dynamic>? additionalConfig,
  }) {
    throw UnimplementedError('initialize() has not been implemented.');
  }

  /// Update the API key
  Future<void> setApiKey(String apiKey) {
    throw UnimplementedError('setApiKey() has not been implemented.');
  }

  /// Update the endpoint URL
  Future<void> setEndpoint(String endpoint) {
    throw UnimplementedError('setEndpoint() has not been implemented.');
  }

  /// Get current configuration
  Future<Map<String, dynamic>?> getConfiguration() {
    throw UnimplementedError('getConfiguration() has not been implemented.');
  }

  /// Check if SDK is initialized
  Future<bool> isInitialized() {
    throw UnimplementedError('isInitialized() has not been implemented.');
  }
}
