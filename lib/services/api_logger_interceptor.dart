import 'dart:convert';
import 'dart:developer' as developer;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiLoggerInterceptor extends Interceptor {
  final JsonEncoder _encoder = const JsonEncoder.withIndent('  ');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      final startTime = DateTime.now().millisecondsSinceEpoch;
      options.extra['request_start_time'] = startTime;

      final buffer = StringBuffer();
      buffer.writeln('\n┌─── 🚀 [API REQUEST] ──────────────────────────────────────────');
      buffer.writeln('│ URL:     ${options.method.toUpperCase()} ${options.uri}');

      if (options.headers.isNotEmpty) {
        buffer.writeln('│ HEADERS:');
        options.headers.forEach((key, value) {
          buffer.writeln('│   • $key: $value');
        });
      }

      if (options.queryParameters.isNotEmpty) {
        buffer.writeln('│ QUERY PARAMS:');
        options.queryParameters.forEach((key, value) {
          buffer.writeln('│   • $key: $value');
        });
      }

      if (options.data != null) {
        buffer.writeln('│ REQUEST BODY:');
        buffer.writeln('│ ${_formatData(options.data)}');
      }

      buffer.write('└───────────────────────────────────────────────────────────────');
      _log(buffer.toString());
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      final startTime =
          response.requestOptions.extra['request_start_time'] as int?;
      final duration = startTime != null
          ? '${DateTime.now().millisecondsSinceEpoch - startTime}ms'
          : 'N/A';

      final buffer = StringBuffer();
      buffer.writeln(
          '\n┌─── 🟢 [API RESPONSE: ${response.statusCode}] ──────────────────────');
      buffer.writeln(
          '│ URL:       ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.uri}');
      buffer.writeln(
          '│ STATUS:    ${response.statusCode} ${response.statusMessage ?? ''}');
      buffer.writeln('│ DURATION:  $duration');
      buffer.writeln('│ RESPONSE BODY:');
      buffer.writeln('│ ${_formatData(response.data)}');
      buffer.write('└───────────────────────────────────────────────────────────────');
      _log(buffer.toString());
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      final startTime =
          err.requestOptions.extra['request_start_time'] as int?;
      final duration = startTime != null
          ? '${DateTime.now().millisecondsSinceEpoch - startTime}ms'
          : 'N/A';

      final buffer = StringBuffer();
      buffer.writeln(
          '\n┌─── 🔴 [API ERROR: ${err.response?.statusCode ?? 'FAILED'}] ──────────────────');
      buffer.writeln(
          '│ URL:       ${err.requestOptions.method.toUpperCase()} ${err.requestOptions.uri}');
      buffer.writeln('│ TYPE:      ${err.type}');
      buffer.writeln('│ DURATION:  $duration');
      buffer.writeln('│ MESSAGE:   ${err.message}');

      if (err.response?.data != null) {
        buffer.writeln('│ ERROR DATA:');
        buffer.writeln('│ ${_formatData(err.response?.data)}');
      }

      buffer.write('└───────────────────────────────────────────────────────────────');
      _log(buffer.toString());
    }
    super.onError(err, handler);
  }

  String _formatData(dynamic data) {
    try {
      if (data is Map || data is List) {
        return _encoder.convert(data).replaceAll('\n', '\n│ ');
      } else if (data is String) {
        try {
          final decoded = jsonDecode(data);
          return _encoder.convert(decoded).replaceAll('\n', '\n│ ');
        } catch (_) {
          return data.replaceAll('\n', '\n│ ');
        }
      } else if (data is FormData) {
        final map = <String, dynamic>{};
        for (final field in data.fields) {
          map[field.key] = field.value;
        }
        for (final file in data.files) {
          map[file.key] =
              'File: ${file.value.filename} (${file.value.length} bytes)';
        }
        return _encoder.convert(map).replaceAll('\n', '\n│ ');
      }
      return data.toString().replaceAll('\n', '\n│ ');
    } catch (_) {
      return data.toString();
    }
  }

  void _log(String message) {
    developer.log(message, name: 'SuchiGo-API');
    debugPrint(message);
  }
}
