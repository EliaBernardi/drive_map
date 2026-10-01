import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import '../../domain/telemetry.dart';
import 'obd_transport.dart';

/// One request at a time, delimited by `>`. Timeouts poison the channel so late
/// replies cannot be attributed to a subsequent PID; reconnect is then required.
class ElmChannel {
  ElmChannel(this.transport) {
    _subscription = transport.bytes.listen(
      _receive,
      onError: _fail,
      onDone: () =>
          _fail(const ObdException('Collegamento Bluetooth interrotto.')),
    );
  }
  final ObdTransport transport;
  late final StreamSubscription<Uint8List> _subscription;
  Completer<String>? _pending;
  String _buffer = '';
  bool _poisoned = false;
  void _receive(Uint8List bytes) {
    _buffer += ascii.decode(bytes, allowInvalid: true);
    if (_buffer.length > 32768) {
      _fail(const ObdException('Risposta OBD troppo lunga.'));
      return;
    }
    while (_buffer.contains('>')) {
      final index = _buffer.indexOf('>');
      final response = _buffer.substring(0, index);
      _buffer = _buffer.substring(index + 1);
      final pending = _pending;
      if (pending != null && !pending.isCompleted) pending.complete(response);
    }
  }

  void _fail(Object error) {
    _poisoned = true;
    final pending = _pending;
    if (pending != null && !pending.isCompleted) pending.completeError(error);
  }

  Future<String> request(
    String command, {
    Duration timeout = const Duration(seconds: 4),
  }) async {
    if (_poisoned) throw const ObdException('Canale OBD da riconnettere.');
    if (_pending != null) throw StateError('Concurrent ELM request');
    if (!RegExp(
      r'^(ATZ|ATE0|ATL0|ATS1|ATH1|ATSP0|ATAT1|ATST64|ATDP|01[0-9A-F]{2})$',
    ).hasMatch(command)) {
      throw ArgumentError.value(command, 'command', 'Comando non consentito');
    }
    _buffer = '';
    final completer = Completer<String>();
    _pending = completer;
    final response = completer.future.timeout(
      timeout,
      onTimeout: () {
        _poisoned = true;
        throw TimeoutException('Nessuna risposta a $command', timeout);
      },
    );
    try {
      unawaited(
        transport
            .write(Uint8List.fromList(ascii.encode('$command\r')))
            .catchError(_fail),
      );
      return await response;
    } finally {
      _pending = null;
    }
  }

  Future<void> close() async {
    _fail(const ObdException('Sessione chiusa.'));
    await _subscription.cancel();
  }
}

class PidReply {
  const PidReply(this.ecu, this.bytes);
  final String ecu;
  final List<int> bytes;
}

abstract final class PidDecoder {
  /// ATH1 / ATS1: 11/29-bit CAN single frames and three-byte ISO headers.
  static List<PidReply> replies(String response, int pid) {
    final marker = '41${pid.toRadixString(16).padLeft(2, '0').toUpperCase()}';
    final result = <PidReply>[];
    for (var line in response.toUpperCase().split(RegExp(r'[\r\n]'))) {
      line = line.replaceAll('SEARCHING...', '').trim();
      if (!RegExp(r'^[0-9A-F\s]+$').hasMatch(line)) continue;
      final compact = line.replaceAll(RegExp(r'\s'), '');
      final parts = line.split(RegExp(r'\s+'));
      String ecu;
      String payload;
      if (compact.startsWith(marker)) {
        ecu = 'headerless';
        payload = compact;
      } else if (parts.first.length == 3 ||
          (parts.first.length == 8 && parts.length > 1)) {
        ecu = parts.first;
        var remaining = parts.skip(1).join();
        if (remaining.startsWith('0') && remaining.length >= 2) {
          final length = int.tryParse(remaining.substring(0, 2), radix: 16);
          if (length == null || length > 7 || remaining.length < 2 + length * 2) {
            continue;
          }
          remaining = remaining.substring(2, 2 + length * 2);
        }
        payload = remaining;
      } else if (parts.length >= 7 &&
          parts.take(4).every((p) => p.length == 2) &&
          parts[4].startsWith('0') &&
          parts[5] == '41') {
        ecu = parts.take(4).join();
        final length = int.tryParse(parts[4], radix: 16);
        if (length == null || length > 7 || parts.length < 5 + length) continue;
        payload = parts.skip(5).take(length).join();
      } else if (compact.length >= 10 &&
          compact.substring(6).startsWith(marker)) {
        ecu = compact.substring(0, 6);
        payload = compact.substring(6);
      } else {
        continue;
      }
      if (!payload.startsWith(marker) || payload.length.isOdd) continue;
      result.add(
        PidReply(ecu, [
          for (var i = 4; i < payload.length; i += 2)
            int.parse(payload.substring(i, i + 2), radix: 16),
        ]),
      );
    }
    return result;
  }

  static Set<int> supported(List<int> bytes, int base) {
    if (bytes.length < 4) throw const FormatException('Bitmap PID incompleta');
    final bits =
        (bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | bytes[3];
    return {
      for (var bit = 0; bit < 32; bit++)
        if (bits & (1 << (31 - bit)) != 0) base + bit + 1,
    };
  }

  static double decode(Pid pid, List<int> bytes) {
    final count = {Pid.rpm, Pid.voltage, Pid.fuelRate}.contains(pid) ? 2 : 1;
    if (bytes.length < count) {
      throw FormatException('Risposta ${pid.command} incompleta');
    }
    final a = bytes[0];
    return switch (pid) {
      Pid.rpm => (a * 256 + bytes[1]) / 4,
      Pid.speed || Pid.manifold => a.toDouble(),
      Pid.coolant => a - 40.0,
      Pid.load || Pid.throttle => a * 100 / 255,
      Pid.voltage => (a * 256 + bytes[1]) / 1000,
      Pid.fuelRate => (a * 256 + bytes[1]) / 20,
    };
  }

  static bool noData(String response) =>
      response.toUpperCase().contains('NO DATA');
}
