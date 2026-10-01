import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

import '../../domain/telemetry.dart';
import 'obd_transport.dart';

/// Explicit simulator exercising the same framing, discovery and decoding path.
class DemoTransport implements ObdTransport {
  final _bytes = StreamController<Uint8List>.broadcast();
  final _clock = Stopwatch();
  bool _connected = false;
  @override
  Stream<Uint8List> get bytes => _bytes.stream;
  @override
  Future<void> connect(String id) async {
    _connected = true;
    _clock.start();
  }

  @override
  Future<void> disconnect() async {
    _connected = false;
    _clock.stop();
  }

  @override
  Future<void> write(Uint8List bytes) async {
    if (!_connected) throw const ObdException('Demo disconnessa');
    final command = ascii.decode(bytes).trim();
    String response;
    if (command == 'ATZ') {
      response = 'ELM327 DEMO';
    } else if (command == 'ATDP') {
      response = 'DEMO / ISO 15765-4 CAN';
    } else if (command.startsWith('AT')) {
      response = 'OK';
    } else {
      final code = int.parse(command.substring(2), radix: 16);
      final payload = <int>[];
      if (code % 32 == 0) {
        final supported = {...Pid.values.map((e) => e.code), 0x20, 0x40};
        var bits = 0;
        for (var i = 1; i <= 32; i++) {
          if (supported.contains(code + i)) bits |= 1 << (32 - i);
        }
        payload.addAll([
          bits >> 24 & 255,
          bits >> 16 & 255,
          bits >> 8 & 255,
          bits & 255,
        ]);
      } else {
        final t = _clock.elapsedMilliseconds / 1000;
        final speed = (45 + 30 * math.sin(t / 14) + 8 * math.sin(t / 3))
            .clamp(0, 110)
            .toDouble();
        final rpm = 950 + speed * 28 + 150 * math.sin(t / 4);
        final load = (40 + 28 * math.sin(t / 7)).clamp(0, 100).toDouble();
        final value = switch (code) {
          0x04 => (load * 255 / 100).round(),
          0x05 => (45 + math.min(t / 3, 45) + 40).round(),
          0x0B => 55,
          0x0C => (rpm * 4).round(),
          0x0D => speed.round(),
          0x11 => ((15 + load / 2) * 255 / 100).round(),
          0x42 => 14200,
          0x5E => ((1 + speed / 18 + load / 30) * 20).round(),
          _ => -1,
        };
        if (value < 0) {
          _emit('NO DATA\r>');
          return;
        }
        if ({0x0C, 0x42, 0x5E}.contains(code)) payload.add(value >> 8);
        payload.add(value & 255);
      }
      final data = [
        payload.length + 2,
        0x41,
        code,
        ...payload,
      ].map((v) => v.toRadixString(16).padLeft(2, '0').toUpperCase()).join(' ');
      response = '7E8 $data';
    }
    await Future<void>.delayed(const Duration(milliseconds: 35));
    if (_connected) {
      // Deliberately fragmented, as on a real serial link.
      final split = response.length ~/ 2;
      _emit(response.substring(0, split));
      _emit('${response.substring(split)}\r>');
    }
  }

  void _emit(String text) => _bytes.add(Uint8List.fromList(ascii.encode(text)));
  Future<void> dispose() => _bytes.close();
}
