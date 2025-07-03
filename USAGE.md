# Vietmap Tracking SDK - Usage Guide

## Cài đặt

Thêm dependency vào `pubspec.yaml`:

```yaml
dependencies:
  vietmap_tracking_plugin: ^1.0.0
```

## Khởi tạo SDK

### 1. Cách khởi tạo cơ bản

```dart
import 'package:vietmap_tracking_plugin/vietmap_tracking_plugin.dart';

// Khởi tạo SDK với API key và endpoint
await VietmapTrackingPlugin.instance.initialize(
  VietmapTrackingConfig(
    apiKey: 'your-api-key-here',
    endpoint: 'https://api.vietmap.vn/tracking',
  ),
);
```

### 2. Khởi tạo với cấu hình bổ sung

```dart
await VietmapTrackingPlugin.instance.initialize(
  VietmapTrackingConfig(
    apiKey: 'your-api-key-here',
    endpoint: 'https://api.vietmap.vn/tracking',
    additionalConfig: {
      'timeout': 30000,
      'retryCount': 3,
      'debug': true,
    },
  ),
);
```

## Quản lý cấu hình

### Kiểm tra trạng thái khởi tạo

```dart
bool isInitialized = await VietmapTrackingPlugin.instance.isInitialized();
if (isInitialized) {
  print('SDK đã được khởi tạo');
} else {
  print('SDK chưa được khởi tạo');
}
```

### Lấy cấu hình hiện tại

```dart
Map<String, dynamic>? config = await VietmapTrackingPlugin.instance.getConfiguration();
if (config != null) {
  print('API Key: ${config['apiKey']}');
  print('Endpoint: ${config['endpoint']}');
}
```

### Cập nhật API Key

```dart
await VietmapTrackingPlugin.instance.setApiKey('new-api-key');
```

### Cập nhật Endpoint

```dart
await VietmapTrackingPlugin.instance.setEndpoint('https://new-api.vietmap.vn/tracking');
```

## Xử lý lỗi

```dart
try {
  await VietmapTrackingPlugin.instance.initialize(
    VietmapTrackingConfig(
      apiKey: 'your-api-key',
      endpoint: 'https://api.vietmap.vn/tracking',
    ),
  );
  print('Khởi tạo thành công');
} catch (e) {
  print('Lỗi khởi tạo: $e');
}
```

## Ví dụ hoàn chỉnh

```dart
import 'package:flutter/material.dart';
import 'package:vietmap_tracking_plugin/vietmap_tracking_plugin.dart';

class TrackingSetup extends StatefulWidget {
  @override
  _TrackingSetupState createState() => _TrackingSetupState();
}

class _TrackingSetupState extends State<TrackingSetup> {
  final _apiKeyController = TextEditingController();
  final _endpointController = TextEditingController();
  String _status = 'Chưa khởi tạo';

  @override
  void initState() {
    super.initState();
    checkStatus();
  }

  Future<void> checkStatus() async {
    bool isInitialized = await VietmapTrackingPlugin.instance.isInitialized();
    setState(() {
      _status = isInitialized ? 'Đã khởi tạo' : 'Chưa khởi tạo';
    });
  }

  Future<void> initializeSDK() async {
    try {
      await VietmapTrackingPlugin.instance.initialize(
        VietmapTrackingConfig(
          apiKey: _apiKeyController.text,
          endpoint: _endpointController.text,
        ),
      );
      setState(() {
        _status = 'Khởi tạo thành công';
      });
    } catch (e) {
      setState(() {
        _status = 'Lỗi: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Vietmap Tracking Setup')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Trạng thái: $_status'),
            TextField(
              controller: _apiKeyController,
              decoration: InputDecoration(labelText: 'API Key'),
            ),
            TextField(
              controller: _endpointController,
              decoration: InputDecoration(labelText: 'Endpoint'),
            ),
            ElevatedButton(
              onPressed: initializeSDK,
              child: Text('Khởi tạo SDK'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Các tính năng sắp tới

- [ ] GPS tracking
- [ ] Batch upload
- [ ] Offline mode
- [ ] Real-time tracking
- [ ] Geofencing

## Hỗ trợ

Để được hỗ trợ, vui lòng tạo issue trên GitHub repository.
