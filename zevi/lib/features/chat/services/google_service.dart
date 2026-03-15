import 'package:dio/dio.dart';
import '../../../core/services/api_service.dart';

class GoogleService {
  final Dio _dio = apiServiceProvider.dio;

  Future<dynamic> getCalendarEvents() async {
    return _handleRequest(() => _dio.get('/api/calendar/events'));
  }

  Future<dynamic> createCalendarEvent(Map<String, dynamic> data) async {
    return _handleRequest(() => _dio.post('/api/calendar/events', data: data));
  }

  Future<dynamic> getInboxSummary() async {
    return _handleRequest(() => _dio.get('/api/gmail/inbox'));
  }

  Future<dynamic> sendEmail(Map<String, dynamic> data) async {
    return _handleRequest(() => _dio.post('/api/gmail/send', data: data));
  }

  Future<dynamic> searchContacts(String query) async {
    return _handleRequest(() => _dio.get('/api/contacts/search', queryParameters: {'q': query}));
  }

  Future<dynamic> createDocument(Map<String, dynamic> data) async {
    return _handleRequest(() => _dio.post('/api/docs/create', data: data));
  }

  Future<dynamic> getNearbyPlaces(Map<String, dynamic> data) async {
    return _handleRequest(() => _dio.get('/api/maps/nearby', queryParameters: data));
  }

  Future<dynamic> webSearch(String query) async {
    return _handleRequest(() => _dio.post('/api/search', data: {'q': query}));
  }

  Future<T> _handleRequest<T>(Future<Response<T>> Function() request) async {
    try {
      final response = await request();
      return response.data as T;
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw NetworkException('Connection timed out');
      }
      if (e.response?.statusCode == 401) {
        throw AuthException('Session expired');
      }
      throw ApiException('API error: ${e.message}');
    } catch (e) {
      throw ApiException('Unknown error: $e');
    }
  }
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  @override
  String toString() => message;
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}
