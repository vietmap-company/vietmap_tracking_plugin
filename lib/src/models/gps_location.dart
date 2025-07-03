/// Model class representing GPS location data
class GpsLocation {
  final double? latitude;
  final double? longitude;
  final double? altitude;
  final double? accuracy;
  final double? speed;
  final double? heading;
  final DateTime? timestamp;
  final Map<String, dynamic>? metadata;
  String? displayAddress;

  GpsLocation({
    this.latitude,
    this.longitude,
    this.altitude,
    this.accuracy,
    this.speed,
    this.heading,
    this.timestamp,
    this.metadata,
    this.displayAddress,
  });

  /// Create GpsLocation from JSON
  factory GpsLocation.fromJson(Map<String, dynamic> json) {
    return GpsLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      altitude: json['altitude'] != null
          ? (json['altitude'] as num).toDouble()
          : null,
      accuracy: json['accuracy'] != null
          ? (json['accuracy'] as num).toDouble()
          : null,
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
      heading: json['heading'] != null
          ? (json['heading'] as num).toDouble()
          : null,
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      metadata: json['metadata'] as Map<String, dynamic>?,
      displayAddress: json['displayAddress'] as String?,
    );
  }

  /// Convert GpsLocation to JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
      if (accuracy != null) 'accuracy': accuracy,
      if (speed != null) 'speed': speed,
      if (heading != null) 'heading': heading,
      'timestamp': timestamp?.millisecondsSinceEpoch,
      if (metadata != null) 'metadata': metadata,
      if (displayAddress != null) 'displayAddress': displayAddress,
    };
  }

  /// Create a copy with modified values
  GpsLocation copyWith({
    double? latitude,
    double? longitude,
    double? altitude,
    double? accuracy,
    double? speed,
    double? heading,
    DateTime? timestamp,
    String? displayAddress,
    Map<String, dynamic>? metadata,
  }) {
    return GpsLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      accuracy: accuracy ?? this.accuracy,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
      displayAddress: displayAddress ?? this.displayAddress,
    );
  }

  @override
  String toString() {
    return 'GpsLocation(lat: $latitude, lng: $longitude, timestamp: $timestamp)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GpsLocation &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return latitude.hashCode ^ longitude.hashCode ^ timestamp.hashCode;
  }
}
