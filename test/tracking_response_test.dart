import 'package:flutter_test/flutter_test.dart';
import 'package:vietmap_tracking_plugin/src/models/tracking_response.dart';

void main() {
  group('TrackingResponse', () {
    test('should create success response from JSON', () {
      final json = {
        'success': true,
        'message': 'Location sent successfully',
        'data': {'id': '123'},
      };

      final response = TrackingResponse.fromJson(json, 200);

      expect(response.success, isTrue);
      expect(response.message, 'Location sent successfully');
      expect(response.data, {'id': '123'});
      expect(response.statusCode, 200);
    });

    test('should create error response from JSON', () {
      final json = {'success': false, 'message': 'Invalid API key'};

      final response = TrackingResponse.fromJson(json, 401);

      expect(response.success, isFalse);
      expect(response.message, 'Invalid API key');
      expect(response.statusCode, 401);
    });

    test('should infer success from status code when not provided', () {
      final json = {'message': 'OK'};

      final successResponse = TrackingResponse.fromJson(json, 200);
      final errorResponse = TrackingResponse.fromJson(json, 500);

      expect(successResponse.success, isTrue);
      expect(errorResponse.success, isFalse);
    });

    test('should create success response using factory', () {
      final response = TrackingResponse.success(
        message: 'Data sent',
        data: {'count': 5},
        statusCode: 201,
      );

      expect(response.success, isTrue);
      expect(response.message, 'Data sent');
      expect(response.data, {'count': 5});
      expect(response.statusCode, 201);
    });

    test('should create error response using factory', () {
      final response = TrackingResponse.error(
        message: 'Network error',
        statusCode: 500,
        data: {'error_code': 'NETWORK_TIMEOUT'},
      );

      expect(response.success, isFalse);
      expect(response.message, 'Network error');
      expect(response.statusCode, 500);
      expect(response.data, {'error_code': 'NETWORK_TIMEOUT'});
    });

    test('should have proper toString implementation', () {
      final response = TrackingResponse.success(
        message: 'Test message',
        statusCode: 200,
      );

      final string = response.toString();
      expect(string, contains('true'));
      expect(string, contains('Test message'));
      expect(string, contains('200'));
    });
  });

  group('TrackingException', () {
    test('should create exception with message only', () {
      final exception = TrackingException(message: 'Test error');

      expect(exception.message, 'Test error');
      expect(exception.statusCode, isNull);
      expect(exception.details, isNull);
    });

    test('should create exception with all fields', () {
      final details = {'error_type': 'validation'};
      final exception = TrackingException(
        message: 'Validation failed',
        statusCode: 400,
        details: details,
      );

      expect(exception.message, 'Validation failed');
      expect(exception.statusCode, 400);
      expect(exception.details, details);
    });

    test('should have proper toString implementation', () {
      final exception1 = TrackingException(message: 'Simple error');
      final exception2 = TrackingException(
        message: 'HTTP error',
        statusCode: 500,
      );

      expect(exception1.toString(), 'TrackingException: Simple error');
      expect(
        exception2.toString(),
        'TrackingException: HTTP error (status: 500)',
      );
    });

    test('should implement Exception interface', () {
      final exception = TrackingException(message: 'Test');
      expect(exception, isA<Exception>());
    });
  });
}
