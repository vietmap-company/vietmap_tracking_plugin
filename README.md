# Vietmap Tracking Plugin

A comprehensive Flutter plugin for GPS tracking and location data transmission to Vietmap's tracking API. This plugin provides both native platform integration and pure Dart HTTP client functionality for maximum flexibility, including background location tracking support.

## Features

- ✅ **Easy Configuration**: Simple API key and endpoint setup
- ✅ **HTTP Integration**: Built-in HTTP functionality for sending GPS data
- ✅ **Automatic Retry**: Retry logic with exponential backoff for failed requests
- ✅ **Real-time Tracking**: Send individual locations immediately
- ✅ **Background Tracking**: Continue tracking when app is in background
- ✅ **Offline Support**: Queue locations when offline, send when connected
- ✅ **Native Integration**: Android and iOS platform implementations
- ✅ **Error Handling**: Comprehensive error reporting and automatic caching
- ✅ **Configurable**: Customizable timeouts and retry attempts

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  vietmap_tracking_plugin: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Platform Setup

### Android Configuration

1. **Update `android/app/build.gradle`:**
```kotlin
android {
    compileSdk 34

    defaultConfig {
        targetSdk 34
        minSdk 23
        // ... other config
    }
}
```

2. **Add permissions to `android/app/src/main/AndroidManifest.xml`:**
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Location permissions -->
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
    
    <!-- Background service permissions -->
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
    <uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    
    <!-- Network permissions -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <application>
        <!-- Your app configuration -->
    </application>
</manifest>
```

### iOS Configuration

Add the following to your `ios/Runner/Info.plist`:

```xml
<dict>
    <!-- Location permissions -->
    <key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
    <string>This app needs location access to track your position for navigation and delivery services.</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>This app needs location access to track your position for navigation and delivery services.</string>
    <key>NSLocationAlwaysUsageDescription</key>
    <string>This app needs location access to track your position in the background for delivery tracking.</string>
    
    <!-- Background modes -->
    <key>UIBackgroundModes</key>
    <array>
        <string>location</string>
        <string>background-processing</string>
        <string>background-fetch</string>
    </array>
    
    <!-- Flutter background service -->
    <key>BGTaskSchedulerPermittedIdentifiers</key>
    <array>
        <string>$(PRODUCT_BUNDLE_IDENTIFIER).background_service</string>
    </array>
    
    <!-- Other existing keys... -->
</dict>
```

## Quick Start

### 1. Initialize the SDK

```dart
import 'package:vietmap_tracking_plugin/vietmap_tracking_plugin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize background service first
  await VietmapTrackingPlugin.instance.initializeBackgroundService();
  
  // Initialize with basic configuration
  await VietmapTrackingPlugin.instance.initialize(
    VietmapTrackingConfig(
      apiKey: 'your-api-key-here',
      endpoint: 'https://api.vietmap.vn/tracking',
    ),
  );
  
  runApp(MyApp());
}
```

### 2. Send GPS Location

```dart
// Create a GPS location
final location = GpsLocation(
  latitude: 21.0285,
  longitude: 105.8542,
  accuracy: 10.0,
  speed: 5.0,
  timestamp: DateTime.now(),
  metadata: {'vehicle_id': 'truck_001'},
);

// Send immediately
final success = await VietmapTrackingPlugin.instance.sendLocation(location);
if (success) {
  print('Location sent successfully!');
}
```

### 3. Background Tracking

```dart
// Start background location tracking
await VietmapTrackingPlugin.instance.startLocationTracking();

// Check if tracking is running
bool isRunning = await VietmapTrackingPlugin.instance.isTrackingServiceRunning();

// Stop background tracking
await VietmapTrackingPlugin.instance.stopLocationTracking();
```

### 4. Test Connection

```dart
// Test connection before starting tracking
final response = await VietmapTrackingPlugin.instance.testConnection();
if (response['success']) {
  print('Connection test passed');
  // Start tracking
} else {
  print('Connection test failed: ${response['message']}');
}
```

// Or let it auto-send when batch is full or interval reached
```

## Advanced Configuration

```dart
await VietmapTrackingPlugin.instance.initialize(
  VietmapTrackingConfig(
    apiKey: 'your-api-key',
    endpoint: 'https://api.vietmap.vn/tracking',
    batchSize: 10,                              // Send when 10 locations queued
    batchInterval: Duration(minutes: 2),        // Send every 2 minutes
    httpTimeout: Duration(seconds: 30),         // HTTP timeout
    maxRetryAttempts: 3,                        // Retry failed requests
    trackingInterval: Duration(seconds: 30),    // Location tracking interval (default: 30s)
    additionalConfig: {
      'debug': true,
      'compression': 'gzip',
    },
  ),
);
```

### Dynamic Tracking Interval

You can update the tracking interval at runtime:

```dart
// Update to 15 seconds
await VietmapTrackingPlugin.instance.setTrackingInterval(Duration(seconds: 15));

// Update to 1 minute
await VietmapTrackingPlugin.instance.setTrackingInterval(Duration(minutes: 1));

// Get current interval
final currentInterval = await VietmapTrackingPlugin.instance.getTrackingInterval();
print('Current tracking interval: ${currentInterval.inSeconds}s');
```

## Error Handling & Callbacks

The tracking functionality now handles errors automatically through the `TrackingLocation` class. Failed locations are cached locally and retried when connectivity is restored.

```dart
// Send location with automatic error handling
final success = await VietmapTrackingPlugin.instance.sendLocation(location);
if (!success) {
  print('Location will be cached and retried later');
}

// Check cached locations
final cachedCount = await VietmapTrackingPlugin.instance.getCachedLocationsCount();
print('Cached locations waiting to be sent: $cachedCount');

// Manually clear cached locations if needed
await VietmapTrackingPlugin.instance.clearCachedLocations();

// Test connection before starting tracking
try {
  final testResponse = await VietmapTrackingPlugin.instance.testConnection();
  if (testResponse['success']) {
    print('🌐 Connection test passed');
    // Start tracking
  } else {
    print('🔌 Connection test failed: ${testResponse['message']}');
  }
} catch (e) {
  print('❌ Connection error: $e');
}
```

## Background Tracking

### Setup Background Service

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tracking App',
      home: TrackingScreen(),
    );
  }
}

class TrackingScreen extends StatefulWidget {
  @override
  _TrackingScreenState createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _checkTrackingStatus();
  }

  Future<void> _checkTrackingStatus() async {
    final isRunning = await VietmapTrackingPlugin.instance.isTrackingServiceRunning();
    setState(() {
      _isTracking = isRunning;
    });
  }

  Future<void> _startTracking() async {
    try {
      await VietmapTrackingPlugin.instance.startLocationTracking();
      setState(() {
        _isTracking = true;
      });
      print('📍 Background tracking started');
    } catch (e) {
      print('❌ Failed to start tracking: $e');
    }
  }

  Future<void> _stopTracking() async {
    try {
      await VietmapTrackingPlugin.instance.stopLocationTracking();
      setState(() {
        _isTracking = false;
      });
      print('⏹️ Background tracking stopped');
    } catch (e) {
      print('❌ Failed to stop tracking: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vietmap Tracking')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Tracking Status: ${_isTracking ? "Running" : "Stopped"}'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isTracking ? _stopTracking : _startTracking,
              child: Text(_isTracking ? 'Stop Tracking' : 'Start Tracking'),
            ),
          ],
        ),
      ),
    );
  }
}
```
});

VietmapTrackingService.instance.onError((error) {
  print('❌ Error: ${error.message}');
  // Handle error (show notification, retry, etc.)
});
```

## Troubleshooting

### Common Issues

#### 1. Location Permission Denied
```dart
// Check and request permissions
import 'package:geolocator/geolocator.dart';

bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
if (!serviceEnabled) {
  throw Exception('Location services are disabled.');
}

LocationPermission permission = await Geolocator.checkPermission();
if (permission == LocationPermission.denied) {
  permission = await Geolocator.requestPermission();
  if (permission == LocationPermission.denied) {
    throw Exception('Location permissions are denied');
  }
}

if (permission == LocationPermission.deniedForever) {
  throw Exception('Location permissions are permanently denied');
}
```

#### 2. Background Service Not Starting
- Ensure you've called `initializeBackgroundService()` before other operations
- Check that battery optimization is disabled for your app
- Verify background permissions are granted on Android

#### 3. Network Connection Issues
```dart
// Test connection before starting tracking
final response = await VietmapTrackingService.instance.testConnection();
if (!response.success) {
  print('Connection failed: ${response.message}');
  // Handle accordingly
}
```

#### 4. Batch Not Sending
- Check batch size configuration (default: 5 locations)
- Verify batch interval settings (default: 30 seconds)
- Ensure network connectivity

### Performance Tips

1. **Optimize Batch Settings:**
   ```dart
   VietmapTrackingConfig(
     batchSize: 20,  // Larger batches for less frequent network calls
     batchInterval: Duration(minutes: 5),  // Longer intervals
   )
   ```

2. **Adjust Location Accuracy:**
   ```dart
   // In background service configuration
   // Lower accuracy = better battery life
   distanceFilter: 50,  // Only send when moved 50 meters
   ```

3. **Handle Offline Scenarios:**
   ```dart
   VietmapTrackingService.instance.onLocationFailed((error, location) {
     // Store failed locations locally
     await saveLocationLocally(location);
   });
   ```

## API Reference

### VietmapTrackingPlugin

Main plugin class for SDK initialization and tracking operations.

#### Methods

- `initialize(VietmapTrackingConfig config)` - Initialize the SDK
- `initializeBackgroundService()` - Initialize background service
- `startLocationTracking()` - Start background tracking
- `stopLocationTracking()` - Stop background tracking
- `isTrackingServiceRunning()` - Check if tracking is active
- `sendLocation(GpsLocation location)` - Send single location
- `testConnection()` - Test API connectivity
- `getCachedLocationsCount()` - Get count of cached/failed locations
- `clearCachedLocations()` - Clear cached locations
- `setTrackingInterval(Duration interval)` - Update tracking interval dynamically
- `getTrackingInterval()` - Get current tracking interval
- `getCurrentConfig()` - Get current configuration
- `setApiKey(String apiKey)` - Update API key
- `setEndpoint(String endpoint)` - Update endpoint URL

### TrackingLocation

Static class that handles location processing and HTTP transmission.

#### Methods

- `sendDataToServer(GpsLocation data)` - Send location to server with retry logic
- `startTracking()` - Start periodic location collection
- `stopTracking()` - Stop location collection
- `handleFollowUser()` - Process current location

### Models

#### GpsLocation
```dart
GpsLocation({
  required double latitude,
  required double longitude,
  required double accuracy,
  required double speed,
  required DateTime timestamp,
  double? altitude,
  double? bearing,
  Map<String, dynamic>? metadata,
})
```

#### VietmapTrackingConfig
```dart
VietmapTrackingConfig({
  required String apiKey,
  required String endpoint,
  int batchSize = 5,
  Duration batchInterval = const Duration(seconds: 30),
  Duration httpTimeout = const Duration(seconds: 15),
  int maxRetryAttempts = 3,
  Duration trackingInterval = const Duration(seconds: 30), // Location tracking interval
  Map<String, dynamic>? additionalConfig,
})
```

#### TrackingResponse
```dart
TrackingResponse({
  required bool success,
  String? message,
  Map<String, dynamic>? data,
  int? statusCode,
})
```

## Examples

See the [example](example/) directory for a complete sample app that demonstrates:

- SDK initialization
- Background tracking setup
- Real-time location sending
- Batch processing
- Error handling
- UI integration

## Support

For issues and questions:

1. Check the [troubleshooting](#troubleshooting) section
2. Review the [example app](example/)
3. Open an issue on GitHub

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

