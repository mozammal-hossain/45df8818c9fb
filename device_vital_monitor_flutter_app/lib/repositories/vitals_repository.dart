import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../core/config/api_config.dart';
import '../models/analytics_result.dart';
import '../models/vital_log.dart';
import '../models/vital_log_request.dart';

/// Thrown when the backend returns a non-2xx or when the request fails.
class VitalsRepositoryException implements Exception {
  VitalsRepositoryException(this.message, [this.statusCode, this.cause]);
  final String message;
  final int? statusCode;
  final dynamic cause;
  @override
  String toString() =>
      'VitalsRepositoryException: $message${statusCode != null ? ' (status: $statusCode)' : ''}';
}

/// Repository for vitals API: log vitals, fetch history, fetch analytics.
@lazySingleton
class VitalsRepository {
  VitalsRepository() : _config = ApiConfig() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _config.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
        contentType: Headers.jsonContentType,
      ),
    );
  }

  final ApiConfig _config;
  late final Dio _dio;

  /// POST /api/vitals. Throws [VitalsRepositoryException] on validation/HTTP error.
  Future<void> logVital(VitalLogRequest request) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        _config.vitalsPath,
        data: request.toJson(),
        options: Options(
          contentType: Headers.jsonContentType,
          validateStatus: (status) => status != null && status < 400,
        ),
      );
      final statusCode = response.statusCode;
      if (statusCode != null && statusCode >= 400) {
        throw VitalsRepositoryException(
          _errorMessage(response),
          statusCode,
          response,
        );
      }
    } on DioException catch (e) {
      final msg = switch (e.type) {
        DioExceptionType.connectionTimeout ||
        DioExceptionType.sendTimeout ||
        DioExceptionType.receiveTimeout =>
          'Request timed out. Is the backend running at ${_config.baseUrl}?',
        DioExceptionType.connectionError =>
          'Cannot reach the backend. Check that the server is running.',
        _ => e.response != null
            ? _errorMessage(e.response!)
            : (e.message ?? 'Network error'),
      };
      throw VitalsRepositoryException(
        msg,
        e.response?.statusCode,
        e,
      );
    }
  }

  /// GET /api/vitals. Returns latest 100 logs. Empty list on parse/network error is acceptable per spec “handle unreachable”.
  Future<List<VitalLog>> getHistory() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        _config.vitalsPath,
        options: Options(
          validateStatus: (status) => status != null && status < 400,
        ),
      );
      final statusCode = response.statusCode;
      if (statusCode != null && statusCode >= 400) {
        throw VitalsRepositoryException(
          _errorMessage(response),
          statusCode,
          response,
        );
      }
      final list = response.data;
      if (list == null) return [];
      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => VitalLog.fromJson(e))
          .toList();
    } on DioException catch (e) {
      throw VitalsRepositoryException(
        e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.connectionError
            ? 'Cannot reach the backend.'
            : (e.response != null
                ? _errorMessage(e.response!)
                : (e.message ?? 'Network error')),
        e.response?.statusCode,
        e,
      );
    }
  }

  /// GET /api/vitals/analytics.
  Future<AnalyticsResult> getAnalytics() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _config.vitalsAnalyticsPath,
        options: Options(
          validateStatus: (status) => status != null && status < 400,
        ),
      );
      final statusCode = response.statusCode;
      if (statusCode != null && statusCode >= 400) {
        throw VitalsRepositoryException(
          _errorMessage(response),
          statusCode,
          response,
        );
      }
      final data = response.data;
      if (data == null) {
        return const AnalyticsResult(
          rollingWindowLogs: 0,
          averageThermal: 0,
          averageBattery: 0,
          averageMemory: 0,
          totalLogs: 0,
        );
      }
      return AnalyticsResult.fromJson(data);
    } on DioException catch (e) {
      throw VitalsRepositoryException(
        e.type == DioExceptionType.connectionTimeout ||
                e.type == DioExceptionType.connectionError
            ? 'Cannot reach the backend.'
            : (e.response != null
                ? _errorMessage(e.response!)
                : (e.message ?? 'Network error')),
        e.response?.statusCode,
        e,
      );
    }
  }

  static String _errorMessage(Response<dynamic> response) {
    final data = response.data;
    if (data is Map<String, dynamic> && data['message'] != null) {
      return data['message'] as String;
    }
    if (data is String) return data;
    return 'Request failed (${response.statusCode})';
  }
}
