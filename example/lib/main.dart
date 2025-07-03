import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:vietmap_tracking_plugin/vietmap_tracking_plugin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background tracking service
  await VietmapTrackingPlugin.instance.initializeBackgroundService();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  String _status = 'Not initialized';
  bool _isInitialized = false;
  Map<String, dynamic>? _currentConfig;
  String _trackingStatus = 'Not configured';
  bool _isBackgroundTracking = false;

  final _apiKeyController = TextEditingController(text: 'your-api-key-here');
  final _endpointController = TextEditingController(
    text: 'https://api.vietmap.vn/tracking',
  );

  @override
  void initState() {
    super.initState();
    initPlatformState();
    checkInitializationStatus();
    _setupTrackingCallbacks();
  }

  void _setupTrackingCallbacks() {
    // Callbacks are now handled directly in TrackingLocation
    // No need for separate callback setup
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion =
          await VietmapTrackingPlugin.instance.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  Future<void> checkInitializationStatus() async {
    try {
      final isInitialized = await VietmapTrackingPlugin.instance
          .isInitialized();
      final config = await VietmapTrackingPlugin.instance.getConfiguration();
      final isBackgroundRunning = await VietmapTrackingPlugin.instance
          .isTrackingServiceRunning();

      setState(() {
        _isInitialized = isInitialized;
        _currentConfig = config;
        _status = isInitialized ? 'Initialized' : 'Not initialized';
        _isBackgroundTracking = isBackgroundRunning;

        if (isInitialized) {
          _trackingStatus = 'SDK initialized and ready';
        } else {
          _trackingStatus = 'SDK not initialized';
        }
      });
    } catch (e) {
      setState(() {
        _status = 'Error checking status: $e';
      });
    }
  }

  Future<void> initializeSDK() async {
    try {
      final config = VietmapTrackingConfig(
        apiKey: _apiKeyController.text,
        endpoint: _endpointController.text,
        batchSize: 5,
        batchInterval: const Duration(seconds: 30),
        httpTimeout: const Duration(seconds: 15),
        maxRetryAttempts: 3,
        trackingIntervalSeconds: 10, // Tracking interval in seconds
      );

      await VietmapTrackingPlugin.instance.initialize(config);

      setState(() {
        _status = 'SDK initialized successfully';
        _trackingStatus = 'Tracking service configured with 30s interval';
      });

      checkInitializationStatus();
    } catch (e) {
      setState(() {
        _status = 'Failed to initialize: $e';
      });
    }
  }

  Future<void> testConnection() async {
    try {
      final response = await VietmapTrackingPlugin.instance.testConnection();
      setState(() {
        _trackingStatus =
            'Connection test: ${response['success'] ? 'SUCCESS' : 'FAILED'} - ${response['message'] ?? ''}';
      });
    } catch (e) {
      setState(() {
        _trackingStatus = 'Connection test failed: $e';
      });
    }
  }

  Future<void> sendTestLocation() async {
    try {
      final testLocation = GpsLocation(
        latitude: 21.0285, // Hanoi coordinates
        longitude: 105.8542,
        accuracy: 10.0,
        speed: 0.0,
        timestamp: DateTime.now(),
        metadata: {'test': true, 'source': 'example_app'},
      );

      final response = await VietmapTrackingPlugin.instance.sendLocation(
        testLocation,
      );
      setState(() {
        _trackingStatus =
            'Test location sent: ${response ? 'SUCCESS' : 'FAILED'}';
      });
    } catch (e) {
      setState(() {
        _trackingStatus = 'Failed to send location: $e';
      });
    }
  }

  Future<void> startBackgroundTracking() async {
    try {
      await VietmapTrackingPlugin.instance.startLocationTracking();
      final isRunning = await VietmapTrackingPlugin.instance
          .isTrackingServiceRunning();
      setState(() {
        _isBackgroundTracking = isRunning;
        _trackingStatus = 'Background tracking started';
      });
    } catch (e) {
      setState(() {
        _trackingStatus = 'Failed to start background tracking: $e';
      });
    }
  }

  Future<void> stopBackgroundTracking() async {
    try {
      await VietmapTrackingPlugin.instance.stopLocationTracking();
      setState(() {
        _isBackgroundTracking = false;
        _trackingStatus = 'Background tracking stopped';
      });
    } catch (e) {
      setState(() {
        _trackingStatus = 'Failed to stop background tracking: $e';
      });
    }
  }

  Future<void> checkBackgroundTrackingStatus() async {
    try {
      final isRunning = await VietmapTrackingPlugin.instance
          .isTrackingServiceRunning();
      final isCurrentlyTracking =
          VietmapTrackingPlugin.instance.isCurrentlyTracking;
      final currentIntervalSeconds = await VietmapTrackingPlugin.instance
          .getTrackingInterval();
      setState(() {
        _isBackgroundTracking = isRunning;
        _trackingStatus =
            'Service running: $isRunning, Currently tracking: $isCurrentlyTracking, Interval: ${currentIntervalSeconds}s';
      });
    } catch (e) {
      setState(() {
        _trackingStatus = 'Failed to check background status: $e';
      });
    }
  }

  Future<void> setTrackingInterval15s() async {
    try {
      await VietmapTrackingPlugin.instance.setTrackingInterval(15);
      setState(() {
        _trackingStatus = 'Tracking interval updated to 15 seconds';
      });
      checkBackgroundTrackingStatus();
    } catch (e) {
      setState(() {
        _trackingStatus = 'Failed to update interval: $e';
      });
    }
  }

  Future<void> setTrackingInterval60s() async {
    try {
      await VietmapTrackingPlugin.instance.setTrackingInterval(60);
      setState(() {
        _trackingStatus = 'Tracking interval updated to 60 seconds';
      });
      checkBackgroundTrackingStatus();
    } catch (e) {
      setState(() {
        _trackingStatus = 'Failed to update interval: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Vietmap Tracking SDK Demo'),
          backgroundColor: Colors.blue,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Platform: $_platformVersion'),
                        const SizedBox(height: 8),
                        Text('Status: $_status'),
                        const SizedBox(height: 8),
                        Text('Initialized: $_isInitialized'),
                        const SizedBox(height: 8),
                        Text('Tracking: $_trackingStatus'),
                        const SizedBox(height: 8),
                        Text('Background Tracking: $_isBackgroundTracking'),
                        if (_currentConfig != null) ...[
                          const SizedBox(height: 8),
                          Text('Current Config:'),
                          Text('API Key: ${_currentConfig!['apiKey']}'),
                          Text('Endpoint: ${_currentConfig!['endpoint']}'),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _apiKeyController,
                  decoration: const InputDecoration(
                    labelText: 'API Key',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _endpointController,
                  decoration: const InputDecoration(
                    labelText: 'Endpoint URL',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: initializeSDK,
                  child: const Text('Initialize SDK'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: testConnection,
                  child: const Text('Test Connection'),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Background Tracking:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isBackgroundTracking
                            ? null
                            : startBackgroundTracking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isBackgroundTracking
                              ? Colors.grey
                              : Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Start Background'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isBackgroundTracking
                            ? stopBackgroundTracking
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _isBackgroundTracking
                              ? Colors.red
                              : Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Stop Background'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: checkBackgroundTrackingStatus,
                  child: const Text('Check Background Status'),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _endpointController.dispose();
    super.dispose();
  }
}
