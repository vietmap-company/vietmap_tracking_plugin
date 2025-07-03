import 'package:flutter_test/flutter_test.dart';
import 'package:vietmap_tracking_plugin/src/models/gps_location.dart';

void main() {
  group('GpsLocation', () {
    test('should create GpsLocation with required fields', () {
      final timestamp = DateTime.now();
      final location = GpsLocation(
        latitude: 21.0285,
        longitude: 105.8542,
        timestamp: timestamp,
      );

      expect(location.latitude, 21.0285);
      expect(location.longitude, 105.8542);
      expect(location.timestamp, timestamp);
      expect(location.altitude, isNull);
      expect(location.accuracy, isNull);
      expect(location.speed, isNull);
      expect(location.heading, isNull);
      expect(location.metadata, isNull);
    });

    test('should create GpsLocation with all fields', () {
      final timestamp = DateTime.now();
      final metadata = {'test': true, 'vehicle_id': 'truck_001'};

      final location = GpsLocation(
        latitude: 21.0285,
        longitude: 105.8542,
        altitude: 100.0,
        accuracy: 10.0,
        speed: 5.0,
        heading: 45.0,
        timestamp: timestamp,
        metadata: metadata,
      );

      expect(location.latitude, 21.0285);
      expect(location.longitude, 105.8542);
      expect(location.altitude, 100.0);
      expect(location.accuracy, 10.0);
      expect(location.speed, 5.0);
      expect(location.heading, 45.0);
      expect(location.timestamp, timestamp);
      expect(location.metadata, metadata);
    });

    test('should convert to JSON correctly', () {
      final timestamp = DateTime.now();
      final metadata = {'test': true};

      final location = GpsLocation(
        latitude: 21.0285,
        longitude: 105.8542,
        altitude: 100.0,
        accuracy: 10.0,
        speed: 5.0,
        heading: 45.0,
        timestamp: timestamp,
        metadata: metadata,
      );

      final json = location.toJson();

      expect(json['latitude'], 21.0285);
      expect(json['longitude'], 105.8542);
      expect(json['altitude'], 100.0);
      expect(json['accuracy'], 10.0);
      expect(json['speed'], 5.0);
      expect(json['heading'], 45.0);
      expect(json['timestamp'], timestamp.millisecondsSinceEpoch);
      expect(json['metadata'], metadata);
    });

    test('should convert from JSON correctly', () {
      final timestamp = DateTime.now();
      final timestampMs = timestamp.millisecondsSinceEpoch;
      final metadata = {'test': true};

      final json = {
        'latitude': 21.0285,
        'longitude': 105.8542,
        'altitude': 100.0,
        'accuracy': 10.0,
        'speed': 5.0,
        'heading': 45.0,
        'timestamp': timestampMs,
        'metadata': metadata,
      };

      final location = GpsLocation.fromJson(json);
      final expectedTimestamp = DateTime.fromMillisecondsSinceEpoch(
        timestampMs,
      );

      expect(location.latitude, 21.0285);
      expect(location.longitude, 105.8542);
      expect(location.altitude, 100.0);
      expect(location.accuracy, 10.0);
      expect(location.speed, 5.0);
      expect(location.heading, 45.0);
      expect(location.timestamp, expectedTimestamp);
      expect(location.metadata, metadata);
    });

    test('should handle JSON without optional fields', () {
      final timestamp = DateTime.now();
      final timestampMs = timestamp.millisecondsSinceEpoch;

      final json = {
        'latitude': 21.0285,
        'longitude': 105.8542,
        'timestamp': timestampMs,
      };

      final location = GpsLocation.fromJson(json);
      final expectedTimestamp = DateTime.fromMillisecondsSinceEpoch(
        timestampMs,
      );

      expect(location.latitude, 21.0285);
      expect(location.longitude, 105.8542);
      expect(location.timestamp, expectedTimestamp);
      expect(location.altitude, isNull);
      expect(location.accuracy, isNull);
      expect(location.speed, isNull);
      expect(location.heading, isNull);
      expect(location.metadata, isNull);
    });

    test('should create copy with modified values', () {
      final timestamp = DateTime.now();
      final newTimestamp = timestamp.add(Duration(minutes: 1));

      final original = GpsLocation(
        latitude: 21.0285,
        longitude: 105.8542,
        timestamp: timestamp,
      );

      final copy = original.copyWith(
        latitude: 21.0300,
        timestamp: newTimestamp,
      );

      expect(copy.latitude, 21.0300);
      expect(copy.longitude, 105.8542); // unchanged
      expect(copy.timestamp, newTimestamp);
    });

    test('should implement equality correctly', () {
      final timestamp = DateTime.now();

      final location1 = GpsLocation(
        latitude: 21.0285,
        longitude: 105.8542,
        timestamp: timestamp,
      );

      final location2 = GpsLocation(
        latitude: 21.0285,
        longitude: 105.8542,
        timestamp: timestamp,
      );

      final location3 = GpsLocation(
        latitude: 21.0300, // different
        longitude: 105.8542,
        timestamp: timestamp,
      );

      expect(location1, equals(location2));
      expect(location1, isNot(equals(location3)));
      expect(location1.hashCode, equals(location2.hashCode));
    });

    test('should have proper toString implementation', () {
      final timestamp = DateTime.now();

      final location = GpsLocation(
        latitude: 21.0285,
        longitude: 105.8542,
        timestamp: timestamp,
      );

      final string = location.toString();
      expect(string, contains('21.0285'));
      expect(string, contains('105.8542'));
      expect(string, contains(timestamp.toString()));
    });
  });
}
