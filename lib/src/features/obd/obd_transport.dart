import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ObdDevice {
  const ObdDevice(this.id, this.name, {this.paired = true});
  final String id;
  final String name;
  final bool paired;
}

abstract interface class ObdTransport {
  Stream<Uint8List> get bytes;
  Future<void> connect(String id);
  Future<void> write(Uint8List bytes);
  Future<void> disconnect();
}

/// RFCOMM on Android; ExternalAccessory on iOS. MX+ is not a BLE device.
class PlatformObdTransport implements ObdTransport {
  static const _methods = MethodChannel('drivemap/obd');
  static const _events = EventChannel('drivemap/obd_bytes');
  Stream<Uint8List>? _stream;
  static bool get supported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
  static Future<List<ObdDevice>> devices() async {
    if (!supported) {
      throw const ObdException(
        'Su desktop puoi importare e analizzare i viaggi. L’acquisizione Bluetooth è disponibile su mobile.',
      );
    }
    final result = await _methods.invokeListMethod<dynamic>('devices') ?? [];
    return result
        .map(
          (e) => ObdDevice(
            e['id'] as String,
            e['name'] as String,
            paired: e['paired'] as bool? ?? true,
          ),
        )
        .toList();
  }

  static Future<void> pairing() => _methods.invokeMethod<void>('pairing');
  @override
  Stream<Uint8List> get bytes => _stream ??= _events
      .receiveBroadcastStream()
      .map(
        (event) => event is Uint8List
            ? event
            : Uint8List.fromList((event as List).cast<int>()),
      );
  @override
  Future<void> connect(String id) =>
      _methods.invokeMethod<void>('connect', {'id': id});
  @override
  Future<void> write(Uint8List bytes) =>
      _methods.invokeMethod<void>('write', bytes);
  @override
  Future<void> disconnect() => _methods.invokeMethod<void>('disconnect');
}

class ObdException implements Exception {
  const ObdException(this.message);
  final String message;
  @override
  String toString() => message;
}

String readableError(Object error) =>
    error is PlatformException ? error.message ?? error.code : error.toString();
