import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'vietmap_tracking_plugin_platform_interface.dart';

/// An implementation of [VietmapTrackingPluginPlatform] that uses method channels.
class MethodChannelVietmapTrackingPlugin extends VietmapTrackingPluginPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('vietmap_tracking_plugin');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>(
      'getPlatformVersion',
    );
    return version;
  }

  @override
  Future<void> initialize({
    required String apiKey,
    required String endpoint,
    Map<String, dynamic>? additionalConfig,
  }) async {
    await methodChannel.invokeMethod('initialize', {
      'apiKey': apiKey,
      'endpoint': endpoint,
      'additionalConfig': additionalConfig ?? {},
    });
  }

  @override
  Future<void> setApiKey(String apiKey) async {
    await methodChannel.invokeMethod('setApiKey', {'apiKey': apiKey});
  }

  @override
  Future<void> setEndpoint(String endpoint) async {
    await methodChannel.invokeMethod('setEndpoint', {'endpoint': endpoint});
  }

  @override
  Future<Map<String, dynamic>?> getConfiguration() async {
    final config = await methodChannel.invokeMethod<Map<Object?, Object?>>(
      'getConfiguration',
    );
    return config?.cast<String, dynamic>();
  }

  @override
  Future<bool> isInitialized() async {
    final initialized = await methodChannel.invokeMethod<bool>('isInitialized');
    return initialized ?? false;
  }
}
