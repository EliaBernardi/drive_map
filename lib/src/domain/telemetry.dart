enum Pid {
  load(0x04, 'Carico motore', '%', 250),
  coolant(0x05, 'Refrigerante', '°C', 2000),
  manifold(0x0B, 'Pressione collettore', 'kPa', 1000),
  rpm(0x0C, 'Regime motore', 'rpm', 250),
  speed(0x0D, 'Velocità', 'km/h', 250),
  throttle(0x11, 'Farfalla', '%', 500),
  voltage(0x42, 'Tensione centralina', 'V', 5000),
  fuelRate(0x5E, 'Flusso carburante', 'l/h', 500);

  const Pid(this.code, this.label, this.unit, this.intervalMs);
  final int code;
  final String label;
  final String unit;
  final int intervalMs;
  String get hex => code.toRadixString(16).padLeft(2, '0').toUpperCase();
  String get command => '01$hex';
  Duration get maxAge =>
      Duration(milliseconds: intervalMs < 1000 ? 1500 : intervalMs * 2);
}

enum SampleQuality { valid, noData, invalid, timeout }

class RawSample {
  const RawSample({
    required this.at,
    required this.pid,
    this.value,
    required this.response,
    required this.latencyMs,
    required this.quality,
  });
  final DateTime at;
  final Pid pid;
  final double? value;
  final String response;
  final int latencyMs;
  final SampleQuality quality;
}

/// One causal, 500 ms snapshot. Source timestamps survive persistence and export.
class TelemetryFrame {
  TelemetryFrame({
    required this.at,
    required Map<Pid, double> values,
    Map<Pid, DateTime>? observedAt,
    this.segment = 0,
  }) : values = Map.unmodifiable(values),
       observedAt = Map.unmodifiable(
         observedAt ?? {for (final p in values.keys) p: at},
       );
  final DateTime at;
  final Map<Pid, double> values;
  final Map<Pid, DateTime> observedAt;
  final int segment;
  double? operator [](Pid pid) => values[pid];
  TelemetryFrame inSegment(int value) => TelemetryFrame(
    at: at,
    values: values,
    observedAt: observedAt,
    segment: value,
  );
  Map<String, Object?> toJson() => {
    'at': at.toIso8601String(),
    'segment': segment,
    'values': {for (final e in values.entries) e.key.name: e.value},
    'observedAt': {
      for (final e in observedAt.entries) e.key.name: e.value.toIso8601String(),
    },
  };
  factory TelemetryFrame.fromJson(Map<String, dynamic> json) {
    final values = (json['values'] as Map).cast<String, num>();
    final times = (json['observedAt'] as Map?)?.cast<String, String>();
    return TelemetryFrame(
      at: DateTime.parse(json['at'] as String),
      segment: json['segment'] as int? ?? 0,
      values: {
        for (final p in Pid.values)
          if (values[p.name] != null) p: values[p.name]!.toDouble(),
      },
      observedAt: times == null
          ? null
          : {
              for (final p in Pid.values)
                if (times[p.name] != null) p: DateTime.parse(times[p.name]!),
            },
    );
  }
}

class FrameAssembler {
  final Map<Pid, RawSample> _latest = {};
  void add(RawSample sample) {
    final previous = _latest[sample.pid];
    if (previous != null && !sample.at.isAfter(previous.at)) return;
    _latest[sample.pid] = sample;
  }

  void clear() => _latest.clear();
  TelemetryFrame frame(DateTime at) {
    final valid = _latest.entries.where(
      (e) =>
          e.value.quality == SampleQuality.valid &&
          e.value.value != null &&
          !e.value.at.isAfter(at) &&
          at.difference(e.value.at) <= e.key.maxAge,
    );
    return TelemetryFrame(
      at: at,
      values: {for (final e in valid) e.key: e.value.value!},
      observedAt: {for (final e in valid) e.key: e.value.at},
    );
  }
}
