import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import 'package:device_vital_monitor_flutter_app/core/config/api_config.dart';
import 'package:device_vital_monitor_flutter_app/core/error/exceptions.dart';
import 'package:device_vital_monitor_flutter_app/data/models/request/vital_log_request.dart';
import 'package:device_vital_monitor_flutter_app/data/models/response/analytics_response.dart';
import 'package:device_vital_monitor_flutter_app/data/models/response/vital_log_response.dart';

@lazySingleton
class VitalsRemoteDatasource {
  VitalsRemoteDatasource() : _config = ApiConfig() {
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
      if (response.statusCode != null && response.statusCode! >= 400) {
        throw VitalsRepositoryException(
          _errorMessage(response),
          response.statusCode,
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
      throw VitalsRepositoryException(msg, e.response?.statusCode, e);
    }
  }

  Future<List<VitalLogResponse>> getHistory() async {
    try {
      final response = await _dio.get<List<dynamic>>(
        _config.vitalsPath,
        options: Options(
          validateStatus: (status) => status != null && status < 400,
        ),
      );
      if (response.statusCode != null && response.statusCode! >= 400) {
        throw VitalsRepositoryException(
          _errorMessage(response),
          response.statusCode,
          response,
        );
      }
      final list = response.data;
      if (list == null) return [];
      return list
          .whereType<Map<String, dynamic>>()
          .map((e) => VitalLogResponse.fromJson(e))
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

  Future<AnalyticsResponse> getAnalytics() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        _config.vitalsAnalyticsPath,
        options: Options(
          validateStatus: (status) => status != null && status < 400,
        ),
      );
      if (response.statusCode != null && response.statusCode! >= 400) {
        throw VitalsRepositoryException(
          _errorMessage(response),
          response.statusCode,
          response,
        );
      }
      final data = response.data;
      if (data == null) {
        return const AnalyticsResponse(
          rollingWindowLogs: 0,
          averageThermal: 0,
          averageBattery: 0,
          averageMemory: 0,
          totalLogs: 0,
        );
      }
      return AnalyticsResponse.fromJson(data);
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
