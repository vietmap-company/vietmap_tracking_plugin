# Background Tracking Service - Usage Guide

## Tích hợp Background Service vào ứng dụng

### 1. Khởi tạo trong main()

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize background tracking service
  await VietmapTrackingPlugin.instance.initializeBackgroundService();
  
  runApp(const MyApp());
}
```

### 2. Sử dụng Background Tracking

#### Khởi tạo SDK trước khi start tracking:

```dart
// Initialize SDK first
await VietmapTrackingPlugin.instance.initialize(
  VietmapTrackingConfig(
    apiKey: 'your-api-key',
    endpoint: 'https://api.vietmap.vn/tracking',
  ),
);
```

#### Start Background Tracking:

```dart
try {
  await VietmapTrackingPlugin.instance.startLocationTracking();
  print('Background tracking started');
} catch (e) {
  print('Failed to start: $e');
}
```

#### Stop Background Tracking:

```dart
try {
  await VietmapTrackingPlugin.instance.stopLocationTracking();
  print('Background tracking stopped');
} catch (e) {
  print('Failed to stop: $e');
}
```

#### Kiểm tra trạng thái:

```dart
// Check if service is running
bool isRunning = await VietmapTrackingPlugin.instance.isTrackingServiceRunning();

// Check if currently tracking location
bool isTracking = VietmapTrackingPlugin.instance.isCurrentlyTracking;

print('Service running: $isRunning, Tracking: $isTracking');
```

### 3. Xử lý dữ liệu offline

```dart
// Handle async data processing (sync offline data)
await VietmapTrackingPlugin.instance.handleAsyncData();
```

## Cấu hình Android

### AndroidManifest.xml

Thêm vào `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_LOCATION" />
<uses-permission android:name="android.permission.WAKE_LOCK" />

<application>
    <!-- Foreground service for background location -->
    <service
        android:name="id.flutter.flutter_background_service.BackgroundService"
        android:exported="false"
        android:foregroundServiceType="location" />
</application>
```

### Gradle dependencies

Đảm bảo `compileSdk` và `targetSdk` >= 33 trong `android/app/build.gradle`:

```gradle
android {
    compileSdk 34
    defaultConfig {
        targetSdk 34
    }
}
```

## Cấu hình iOS

### Info.plist

Thêm vào `ios/Runner/Info.plist`:

```xml
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs location access to track your movement in the background.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs location access to track your current position.</string>
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>background-fetch</string>
    <string>background-processing</string>
</array>
```

### Background capability

Trong Xcode, enable Background Modes capability với:
- Location updates
- Background fetch 
- Background processing

## Example Implementation

```dart
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

  Future<void> _toggleTracking() async {
    if (_isTracking) {
      await VietmapTrackingPlugin.instance.stopLocationTracking();
    } else {
      await VietmapTrackingPlugin.instance.startLocationTracking();
    }
    await _checkTrackingStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Background Tracking')),
      body: Center(
        child: Column(
          children: [
            Text('Status: ${_isTracking ? 'Tracking' : 'Stopped'}'),
            ElevatedButton(
              onPressed: _toggleTracking,
              child: Text(_isTracking ? 'Stop Tracking' : 'Start Tracking'),
            ),
            ElevatedButton(
              onPressed: _checkTrackingStatus,
              child: Text('Refresh Status'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Important Notes

1. **Permissions**: Đảm bảo app có permission location trước khi start tracking
2. **Battery Optimization**: User có thể cần disable battery optimization cho app
3. **Background Limits**: iOS có limit chặt chẽ hơn cho background location
4. **Testing**: Test kỹ trên device thực, không chỉ simulator
5. **Notification**: Background service sẽ hiện notification trên Android

## Troubleshooting

### Service không start:
- Kiểm tra permissions
- Kiểm tra SDK đã initialize chưa
- Xem logs để debug

### Location không update:
- Kiểm tra GPS settings
- Kiểm tra app có bị kill bởi system không
- Verify background modes configuration

### Battery drain:
- Tối ưu tracking interval
- Sử dụng appropriate location accuracy
- Implement geofencing nếu có thể
