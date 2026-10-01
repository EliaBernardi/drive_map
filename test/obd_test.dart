import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:drive_map/src/domain/telemetry.dart';
import 'package:drive_map/src/features/obd/demo_transport.dart';
import 'package:drive_map/src/features/obd/elm_protocol.dart';
import 'package:drive_map/src/features/obd/obd_session.dart';
import 'package:drive_map/src/features/obd/obd_transport.dart';
import 'package:flutter_test/flutter_test.dart';

class _Transport implements ObdTransport {
  final controller = StreamController<Uint8List>.broadcast();
  final commands = <String>[];
  @override
  Stream<Uint8List> get bytes => controller.stream;
  @override
  Future<void> connect(String id) async {}
  @override
  Future<void> disconnect() async {}
  @override
  Future<void> write(Uint8List bytes) async {
    commands.add(ascii.decode(bytes));
  }

  void emit(String text) =>
      controller.add(Uint8List.fromList(ascii.encode(text)));
}

void main() {
  test('ELM buffers fragments, ignores echo and parses ECU payload', () async {
    final transport = _Transport();
    final channel = ElmChannel(transport);
    final pending = channel.request('010C');
    transport.emit('010C\rSEARCHING...\r7E8 04 41');
    transport.emit(' 0C 1A F8\r');
    transport.emit('>');
    final replies = PidDecoder.replies(await pending, 0x0C);
    expect(replies.single.ecu, '7E8');
    expect(PidDecoder.decode(Pid.rpm, replies.single.bytes), 1726);
    expect(transport.commands, ['010C\r']);
    await channel.close();
    await transport.controller.close();
  });
  test('Headers, padding, multiple ECUs and malformed replies', () {
    expect(PidDecoder.replies('410C1AF8', 12).single.ecu, 'headerless');
    expect(
      PidDecoder.replies('18 DA F1 10 04 41 0C 1A F8', 12).single.ecu,
      '18DAF110',
    );
    expect(
      PidDecoder.replies('18DAF110 04 41 0C 1A F8 00 00', 12).single.bytes,
      [0x1A, 0xF8],
    );
    expect(
      PidDecoder.replies('48 6B 10 41 0C 1A F8 AA', 12).single.ecu,
      '486B10',
    );
    expect(
      PidDecoder.replies('7E8 03 41 0D 3C\r7E9 03 41 0D 00', 13).length,
      2,
    );
    expect(PidDecoder.replies('NO DATA\rBUS ERROR', 12), isEmpty);
    expect(PidDecoder.replies('7E8 04 41 0C 1A', 12), isEmpty);
    expect(() => PidDecoder.decode(Pid.rpm, [0]), throwsFormatException);
  });
  test('Capability bitmap and unit conversions', () {
    expect(PidDecoder.supported([0x80, 0, 0, 1], 0x20), {0x21, 0x40});
    expect(PidDecoder.decode(Pid.fuelRate, [0, 100]), 5);
    expect(PidDecoder.decode(Pid.coolant, [130]), 90);
    expect(PidDecoder.decode(Pid.voltage, [0x36, 0xB0]), 14);
  });
  test(
    'Timeout poisons channel and concurrent requests are rejected',
    () async {
      final transport = _Transport();
      final channel = ElmChannel(transport);
      final pending = channel.request(
        '010C',
        timeout: const Duration(milliseconds: 20),
      );
      await expectLater(channel.request('010D'), throwsStateError);
      await expectLater(pending, throwsA(isA<TimeoutException>()));
      transport.emit('7E8 04 41 0C 00 00\r>');
      await expectLater(channel.request('010D'), throwsA(isA<ObdException>()));
      expect(transport.commands.length, 1);
      await channel.close();
      await transport.controller.close();
    },
  );
  test('Read-only command allowlist rejects diagnostic writes', () async {
    final transport = _Transport();
    final channel = ElmChannel(transport);
    await expectLater(channel.request('04'), throwsArgumentError);
    expect(transport.commands, isEmpty);
    await channel.close();
    await transport.controller.close();
  });
  test('Frames expire values and do not mask NO DATA with previous values', () {
    final at = DateTime.utc(2026);
    final assembler = FrameAssembler();
    assembler.add(
      RawSample(
        at: at,
        pid: Pid.rpm,
        value: 2000,
        response: '',
        latencyMs: 10,
        quality: SampleQuality.valid,
      ),
    );
    expect(assembler.frame(at.add(const Duration(seconds: 1)))[Pid.rpm], 2000);
    expect(
      assembler.frame(at.add(const Duration(seconds: 2)))[Pid.rpm],
      isNull,
    );
    assembler.add(
      RawSample(
        at: at.add(const Duration(milliseconds: 100)),
        pid: Pid.rpm,
        response: 'NO DATA',
        latencyMs: 10,
        quality: SampleQuality.noData,
      ),
    );
    expect(
      assembler.frame(at.add(const Duration(milliseconds: 200)))[Pid.rpm],
      isNull,
    );
    assembler.add(
      RawSample(
        at: at,
        pid: Pid.rpm,
        value: 3000,
        response: '',
        latencyMs: 10,
        quality: SampleQuality.valid,
      ),
    );
    expect(
      assembler.frame(at.add(const Duration(milliseconds: 300)))[Pid.rpm],
      isNull,
    );
  });
  test(
    'Demo exercises full initialization, discovery, polling and disconnect',
    () async {
      final transport = DemoTransport();
      final session = ObdSession(transport);
      final ready = session.states
          .firstWhere((s) => s.ready)
          .timeout(const Duration(seconds: 5));
      final frame = session.frames
          .firstWhere((f) => f[Pid.rpm] != null)
          .timeout(const Duration(seconds: 5));
      await session.connect('demo');
      expect((await ready).supported, Pid.values.toSet());
      expect((await frame)[Pid.rpm], greaterThan(0));
      await session.dispose();
      await transport.dispose();
    },
  );
}
