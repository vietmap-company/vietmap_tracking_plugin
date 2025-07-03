/// Response from tracking API
class TrackingResponse {
  final bool success;
  final String? message;
  final Map<String, dynamic>? data;
  final int statusCode;

  const TrackingResponse({
    required this.success,
    this.message,
    this.data,
    required this.statusCode,
  });

  /// Create TrackingResponse from JSON
  factory TrackingResponse.fromJson(Map<String, dynamic> json, int statusCode) {
    return TrackingResponse(
      success:
          json['success'] as bool? ?? (statusCode >= 200 && statusCode < 300),
      message: json['message'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      statusCode: statusCode,
    );
  }

  /// Create success response
  factory TrackingResponse.success({
    String? message,
    Map<String, dynamic>? data,
    int statusCode = 200,
  }) {
    return TrackingResponse(
      success: true,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  /// Create error response
  factory TrackingResponse.error({
    required String message,
    Map<String, dynamic>? data,
    int statusCode = 400,
  }) {
    return TrackingResponse(
      success: false,
      message: message,
      data: data,
      statusCode: statusCode,
    );
  }

  @override
  String toString() {
    return 'TrackingResponse(success: $success, message: $message, statusCode: $statusCode)';
  }
}

/// Exception thrown by tracking operations
class TrackingException implements Exception {
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  const TrackingException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() {
    return 'TrackingException: $message${statusCode != null ? ' (status: $statusCode)' : ''}';
  }
}
