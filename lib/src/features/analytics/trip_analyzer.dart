import 'dart:convert';
import 'dart:math' as math;

import '../../domain/telemetry.dart';

class ScoreConfig {
  const ScoreConfig({
    this.zoneWeight = .40,
    this.smoothWeight = .25,
    this.warmupWeight = .20,
    this.economyWeight = .15,
    this.warmTemperature = 70,
    this.highLoad = 75,
    this.coldLoad = 50,
    this.lowRpm = 1200,
    this.highRpm = 3500,
    this.hardAcceleration = 2.5,
    this.hardBraking = 3.0,
    this.baselineConsumption = 0,
  });
  static const version = 'rules-1.0.0';
  final double zoneWeight, smoothWeight, warmupWeight, economyWeight;
  final double warmTemperature, highLoad, coldLoad, lowRpm, highRpm;
  final double hardAcceleration, hardBraking, baselineConsumption;
  Map<String, Object> toJson() => {
    'version': version,
    'zoneWeight': zoneWeight,
    'smoothWeight': smoothWeight,
    'warmupWeight': warmupWeight,
    'economyWeight': economyWeight,
    'warmTemperature': warmTemperature,
    'highLoad': highLoad,
    'coldLoad': coldLoad,
    'lowRpm': lowRpm,
    'highRpm': highRpm,
    'hardAcceleration': hardAcceleration,
    'hardBraking': hardBraking,
    'baselineConsumption': baselineConsumption,
  };
  String encode() => jsonEncode(toJson());
  factory ScoreConfig.decode(String value) {
    final j = jsonDecode(value) as Map<String, dynamic>;
    if (j['version'] != version) {
      throw FormatException('Modello ${j['version']} non supportato');
    }
    double number(String key) => (j[key] as num).toDouble();
    return ScoreConfig(
      zoneWeight: number('zoneWeight'),
      smoothWeight: number('smoothWeight'),
      warmupWeight: number('warmupWeight'),
      economyWeight: number('economyWeight'),
      warmTemperature: number('warmTemperature'),
      highLoad: number('highLoad'),
      coldLoad: number('coldLoad'),
      lowRpm: number('lowRpm'),
      highRpm: number('highRpm'),
      hardAcceleration: number('hardAcceleration'),
      hardBraking: number('hardBraking'),
      baselineConsumption: number('baselineConsumption'),
    )..validate();
  }
  void validate() {
    for (final value in toJson().values.whereType<double>()) {
      if (!value.isFinite) {
        throw const FormatException('I parametri devono essere numeri finiti.');
      }
    }
    if ([
          zoneWeight,
          smoothWeight,
          warmupWeight,
          economyWeight,
        ].any((v) => v < 0) ||
        zoneWeight + smoothWeight + warmupWeight + economyWeight <= 0 ||
        lowRpm < 500 ||
        highRpm <= lowRpm ||
        highRpm > 12000 ||
        highLoad <= 0 ||
        highLoad > 100 ||
        coldLoad < 0 ||
        coldLoad >= 100 ||
        warmTemperature < 20 ||
        warmTemperature > 120 ||
        hardAcceleration <= 0 ||
        hardBraking <= 0 ||
        baselineConsumption < 0 ||
        baselineConsumption > 50) {
      throw const FormatException(
        'Controlla pesi, soglie e baseline: i valori non sono validi.',
      );
    }
  }

  double zonePenalty(double rpm, double load) {
    if ((rpm < lowRpm && load >= highLoad) || rpm >= highRpm) return 1;
    if (rpm >= lowRpm && rpm < highRpm && load >= 20 && load < highLoad) {
      return 0;
    }
    return .5;
  }
}

class OperatingCell {
  OperatingCell(this.rpmBin, this.loadBin);
  final int rpmBin, loadBin;
  int samples = 0;
  double seconds = 0, penaltySeconds = 0;
  double _speed = 0, _speedSeconds = 0, _fuel = 0, _fuelSeconds = 0;
  double _throttle = 0, _throttleSeconds = 0;
  double? get meanSpeed => _speedSeconds > 0 ? _speed / _speedSeconds : null;
  double? get meanFuel => _fuelSeconds > 0 ? _fuel / _fuelSeconds : null;
  double? get meanThrottle =>
      _throttleSeconds > 0 ? _throttle / _throttleSeconds : null;
  double get penalty => seconds > 0 ? penaltySeconds / seconds : 0;
  double get relativeIndex => (1 - penalty) * 100;
  void add(TelemetryFrame f, double dt, double penalty) {
    samples++;
    seconds += dt;
    penaltySeconds += dt * penalty;
    if (f[Pid.speed] != null) {
      _speed += f[Pid.speed]! * dt;
      _speedSeconds += dt;
    }
    if (f[Pid.fuelRate] != null) {
      _fuel += f[Pid.fuelRate]! * dt;
      _fuelSeconds += dt;
    }
    if (f[Pid.throttle] != null) {
      _throttle += f[Pid.throttle]! * dt;
      _throttleSeconds += dt;
    }
  }
}

class DrivingEvent {
  const DrivingEvent(this.at, this.label, this.value);
  final DateTime at;
  final String label;
  final double value;
}

class ScorePart {
  const ScorePart(
    this.name,
    this.value,
    this.weight,
    this.coverage,
    this.reason,
  );
  final String name;
  final double? value;
  final double weight, coverage;
  final String reason;
}

class TripAnalysis {
  const TripAnalysis({
    required this.frames,
    required this.cells,
    required this.parts,
    required this.events,
    required this.duration,
    required this.validMapSeconds,
    required this.distanceKm,
    required this.fuelLiters,
    required this.consumption,
    required this.score,
    required this.favorableFraction,
    required this.speedCoverage,
    required this.fuelCoverage,
    required this.duplicates,
    required this.explanation,
  });
  final List<TelemetryFrame> frames;
  final List<OperatingCell> cells;
  final List<ScorePart> parts;
  final List<DrivingEvent> events;
  final double duration,
      validMapSeconds,
      favorableFraction,
      speedCoverage,
      fuelCoverage;
  final double? distanceKm, fuelLiters, consumption, score;
  final int duplicates;
  final String explanation;
  double get effectiveWeight =>
      parts.where((p) => p.value != null).fold(0.0, (a, p) => a + p.weight);
}

abstract final class TripAnalyzer {
  static TripAnalysis analyze(List<TelemetryFrame> source, ScoreConfig config) {
    config.validate();
    final sorted = [...source]..sort((a, b) => a.at.compareTo(b.at));
    final frames = <TelemetryFrame>[];
    var duplicates = 0;
    for (final f in sorted) {
      if (frames.isNotEmpty && frames.last.at == f.at) {
        duplicates++;
        continue;
      }
      final valid = <Pid, double>{};
      for (final e in f.values.entries) {
        final observed = f.observedAt[e.key];
        if (observed == null ||
            observed.isAfter(f.at) ||
            f.at.difference(observed) > e.key.maxAge) {
          continue;
        }
        if (validValue(e.key, e.value)) valid[e.key] = e.value;
      }
      frames.add(
        TelemetryFrame(
          at: f.at,
          values: valid,
          observedAt: f.observedAt,
          segment: f.segment,
        ),
      );
    }
    final cells = <(int, int), OperatingCell>{};
    final events = <DrivingEvent>[];
    double duration = 0, mapTime = 0, zoneCost = 0, favorable = 0;
    double distance = 0,
        fuel = 0,
        speedTime = 0,
        fuelTime = 0,
        jointDistance = 0,
        jointFuel = 0,
        jointTime = 0;
    double warmTime = 0, warmCost = 0, smoothTime = 0;
    DateTime? lastSpeedAt;
    double? lastSpeed;
    var lastSegment = -1;
    var lastEvent = '';
    for (var i = 0; i < frames.length; i++) {
      final f = frames[i];
      if (f.segment != lastSegment ||
          (i > 0 && f.at.difference(frames[i - 1].at).inMilliseconds > 1500)) {
        lastSpeedAt = null;
        lastSpeed = null;
        lastEvent = '';
        lastSegment = f.segment;
      }
      final speedAt = f.observedAt[Pid.speed];
      if (f[Pid.speed] != null && speedAt != null && speedAt != lastSpeedAt) {
        if (lastSpeedAt != null && lastSpeed != null) {
          final dt = speedAt.difference(lastSpeedAt).inMicroseconds / 1e6;
          if (dt > 0 && dt <= 2) {
            smoothTime += dt;
            final acceleration = (f[Pid.speed]! - lastSpeed) / 3.6 / dt;
            final type = acceleration > config.hardAcceleration
                ? 'Accelerazione brusca'
                : acceleration < -config.hardBraking
                ? 'Frenata brusca'
                : '';
            if (type.isNotEmpty && type != lastEvent) {
              events.add(DrivingEvent(f.at, type, acceleration));
            }
            lastEvent = type;
          } else {
            lastEvent = '';
          }
        }
        lastSpeed = f[Pid.speed];
        lastSpeedAt = speedAt;
      }
      if (i + 1 >= frames.length) continue;
      final next = frames[i + 1];
      if (f.segment != next.segment) continue;
      final dt = next.at.difference(f.at).inMicroseconds / 1e6;
      // Gaps count in session coverage, but never in integrations or map cells.
      duration += dt;
      if (dt <= 0 || dt > 1.5) continue;
      final speed = f[Pid.speed], nextSpeed = next[Pid.speed];
      final rate = f[Pid.fuelRate], nextRate = next[Pid.fuelRate];
      if (speed != null && nextSpeed != null) {
        speedTime += dt;
        distance += (speed + nextSpeed) / 2 * dt / 3600;
      }
      if (rate != null && nextRate != null) {
        fuelTime += dt;
        fuel += (rate + nextRate) / 2 * dt / 3600;
      }
      if (speed != null &&
          nextSpeed != null &&
          rate != null &&
          nextRate != null) {
        jointTime += dt;
        jointDistance += (speed + nextSpeed) / 2 * dt / 3600;
        jointFuel += (rate + nextRate) / 2 * dt / 3600;
      }
      final rpm = f[Pid.rpm], load = f[Pid.load];
      if (rpm != null && rpm > 0 && load != null) {
        final penalty = config.zonePenalty(rpm, load);
        final key = ((rpm / 500).floor(), math.min(9, (load / 10).floor()));
        (cells[key] ??= OperatingCell(key.$1, key.$2)).add(f, dt, penalty);
        mapTime += dt;
        zoneCost += penalty * dt;
        if (penalty == 0) favorable += dt;
      }
      if (f[Pid.coolant] != null && load != null && rpm != null && rpm > 0) {
        warmTime += dt;
        if (f[Pid.coolant]! < config.warmTemperature) {
          warmCost +=
              dt *
              math.max(0, load - config.coldLoad) /
              (100 - config.coldLoad);
        }
      }
    }
    double coverage(double seconds) =>
        duration > 0 ? (seconds / duration).clamp(0, 1) : 0;
    double clamp(double score) => score.clamp(0, 100);
    final consumption = jointDistance >= .1 && coverage(jointTime) >= .8
        ? jointFuel / jointDistance * 100
        : null;
    final parts = [
      ScorePart(
        'Zone operative',
        mapTime >= 5 ? clamp(100 * (1 - zoneCost / mapTime)) : null,
        config.zoneWeight,
        coverage(mapTime),
        'Tempo ponderato nelle zone RPM–carico: costo 0, 0,5 o 1.',
      ),
      ScorePart(
        'Regolarità',
        smoothTime >= 5
            ? clamp(100 - events.length / (smoothTime / 60) * 5)
            : null,
        config.smoothWeight,
        coverage(smoothTime),
        '−5 punti per evento al minuto; accelerazione derivata dalla velocità OBD.',
      ),
      ScorePart(
        'Riscaldamento',
        warmTime >= 5 ? clamp(100 * (1 - warmCost / warmTime)) : null,
        config.warmupWeight,
        coverage(warmTime),
        'Penalità per carico oltre ${config.coldLoad.round()}% sotto ${config.warmTemperature.round()} °C, sul tempo osservato.',
      ),
      ScorePart(
        'Consumo relativo',
        consumption != null && config.baselineConsumption > 0
            ? clamp(
                100 * config.baselineConsumption / math.max(consumption, .01),
              )
            : null,
        config.economyWeight,
        coverage(jointTime),
        config.baselineConsumption <= 0
            ? 'Escluso: configura una baseline di viaggi comparabili per questo veicolo.'
            : 'Rapporto rispetto alla baseline ${config.baselineConsumption.toStringAsFixed(1)} l/100 km; richiede copertura ≥80% e distanza ≥100 m.',
      ),
    ];
    final active = parts.where((p) => p.value != null && p.weight > 0);
    final weight = active.fold(0.0, (s, p) => s + p.weight);
    final score = weight > 0
        ? active.fold(0.0, (s, p) => s + p.value! * p.weight) / weight
        : null;
    final favorableFraction = mapTime > 0 ? favorable / mapTime : 0.0;
    final text = score == null
        ? 'Servono almeno 5 secondi di dati validi per calcolare le componenti dello score.'
        : 'Score ${score.round()}/100 su ${active.length} componenti disponibili. '
              '${mapTime > 0 ? '${(favorableFraction * 100).round()}% del tempo mappato in zone favorevoli secondo le regole configurate. ' : 'Mappa non disponibile: RPM o carico mancanti. '}'
              '${events.length} eventi di accelerazione o frenata. '
              '${parts.any((p) => p.value == null) ? 'I pesi delle componenti disponibili sono rinormalizzati. ' : ''}'
              'Copertura della mappa: ${(coverage(mapTime) * 100).round()}%. Modello euristico, da calibrare su viaggi reali.';
    return TripAnalysis(
      frames: frames,
      cells: cells.values.toList(),
      parts: parts,
      events: events,
      duration: duration,
      validMapSeconds: mapTime,
      distanceKm: speedTime > 0 ? distance : null,
      fuelLiters: fuelTime > 0 ? fuel : null,
      consumption: consumption,
      score: score,
      favorableFraction: favorableFraction,
      speedCoverage: coverage(speedTime),
      fuelCoverage: coverage(fuelTime),
      duplicates: duplicates,
      explanation: text,
    );
  }

  static bool validValue(Pid pid, double value) {
    if (!value.isFinite) return false;
    final (min, max) = switch (pid) {
      Pid.rpm => (0, 16383.75),
      Pid.speed => (0, 255),
      Pid.load || Pid.throttle => (0, 100),
      Pid.coolant => (-40, 215),
      Pid.manifold => (0, 255),
      Pid.voltage => (0, 65.535),
      Pid.fuelRate => (0, 3276.75),
    };
    return value >= min && value <= max;
  }
}
