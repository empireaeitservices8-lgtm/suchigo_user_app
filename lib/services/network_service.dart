import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

/// Centralized singleton service that monitors internet connectivity status
/// in real-time across the entire application.
class NetworkService with ChangeNotifier {
  static final NetworkService _instance = NetworkService._internal();
  static NetworkService get instance => _instance;

  final InternetConnectionChecker _checker = InternetConnectionChecker.instance;
  StreamSubscription<InternetConnectionStatus>? _subscription;

  bool _isOnline = true;
  bool _wasOffline = false;
  bool _hasInitialCheck = false;

  bool get isOnline => _isOnline;
  bool get wasOffline => _wasOffline;
  bool get hasInitialCheck => _hasInitialCheck;

  NetworkService._internal();

  /// Initialize real-time network monitoring.
  void initialize() {
    _subscription?.cancel();

    // Perform initial connectivity check
    _checker.hasConnection.then((hasNet) {
      _isOnline = hasNet;
      _hasInitialCheck = true;
      if (!hasNet) _wasOffline = true;
      notifyListeners();
    }).catchError((_) {
      _isOnline = true;
      _hasInitialCheck = true;
      notifyListeners();
    });

    // Listen to network status changes continuously
    _subscription = _checker.onStatusChange.listen((status) {
      final isNowOnline = (status == InternetConnectionStatus.connected);
      if (_isOnline != isNowOnline) {
        if (!isNowOnline) {
          _wasOffline = true;
        }
        _isOnline = isNowOnline;
        debugPrint('[NetworkService] Connectivity changed: ${_isOnline ? "ONLINE" : "OFFLINE"}');
        notifyListeners();
      }
    });
  }

  /// Manually re-check connection status (useful on user retry).
  Future<bool> checkConnection() async {
    try {
      final hasNet = await _checker.hasConnection;
      if (_isOnline != hasNet) {
        if (!hasNet) _wasOffline = true;
        _isOnline = hasNet;
        notifyListeners();
      }
      return hasNet;
    } catch (_) {
      return _isOnline;
    }
  }

  /// Force-mark the network status as offline (e.g. from network interceptor).
  void markOffline() {
    if (_isOnline) {
      _wasOffline = true;
      _isOnline = false;
      debugPrint('[NetworkService] Marked OFFLINE from failed network request');
      notifyListeners();
    }
  }

  /// Force-mark the network status as online.
  void markOnline() {
    if (!_isOnline) {
      _isOnline = true;
      debugPrint('[NetworkService] Marked ONLINE');
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

/// Dio Interceptor that intercepts all network requests before sending,
/// verifies network state, and handles connection failures gracefully.
class NetworkInterceptor extends Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // If device is offline, re-verify quickly to prevent false positives or fail immediately
    if (!NetworkService.instance.isOnline) {
      final hasNet = await NetworkService.instance.checkConnection();
      if (!hasNet) {
        return handler.reject(
          DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
            error: 'No internet connection. Please check your network and try again.',
            message: 'No internet connection. Please check your network and try again.',
          ),
        );
      }
    }
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.sendTimeout ||
        err.type == DioExceptionType.receiveTimeout) {
      NetworkService.instance.markOffline();
      final userFriendlyError = err.copyWith(
        message: 'Unable to connect to the server. Please check your internet connection and try again.',
      );
      return handler.next(userFriendlyError);
    }
    super.onError(err, handler);
  }
}
