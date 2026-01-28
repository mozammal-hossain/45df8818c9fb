import 'package:flutter/services.dart';

import 'method_channels.dart';

/// Dispatches platform calls to the [MethodChannels.sensors] channel.
/// Used by [SensorPlatformDatasource]; can be overridden in tests.
class PlatformDispatcher {
  PlatformDispatcher({MethodChannel? channel})
      : _channel = channel ?? const MethodChannel(MethodChannels.sensors);

  final MethodChannel _channel;

  MethodChannel get channel => _channel;

  Future<T?> invoke<T>(String method, [dynamic arguments]) =>
      _channel.invokeMethod<T>(method, arguments);
}
