import 'package:csv/csv.dart';

import '../../domain/telemetry.dart';
import '../analytics/trip_analyzer.dart';

class CsvPreview {
  const CsvPreview(this.headers, this.rows);
  final List<String> headers;
  final List<List<dynamic>> rows;
  static CsvPreview parse(String text) {
    final rows = csv.decode(text.replaceFirst('\uFEFF', ''));
    if (rows.length < 2) {
      throw const FormatException(
        'Il CSV deve contenere un’intestazione e almeno una riga.',
      );
    }
    if (rows.length > 200001) {
      throw const FormatException(
        'Limite di importazione: 200.000 righe per viaggio.',
      );
    }
    return CsvPreview(
      rows.first.map((v) => v.toString().trim()).toList(),
      rows.skip(1).toList(),
    );
  }

  int guessTime() => headers.indexWhere(
    (h) => RegExp(
      r'^(timestamp|time|tempo|time \(s\)|elapsed time \(s\))$',
      caseSensitive: false,
    ).hasMatch(h),
  );
  int guess(Pid pid) {
    final names = switch (pid) {
      Pid.rpm => ['rpm', 'engine rpm', 'engine speed'],
      Pid.speed => ['speed', 'vehicle speed', 'velocità'],
      Pid.load => [
        'load',
        'calculated load',
        'calculated engine load',
        'absolute load value',
      ],
      Pid.throttle => [
        'throttle',
        'throttle position',
        'absolute throttle position',
      ],
      Pid.coolant => [
        'coolant',
        'engine coolant temperature',
        'coolant temperature',
      ],
      Pid.fuelRate => ['fuelrate', 'fuel rate', 'engine fuel rate'],
      Pid.manifold => ['manifold', 'intake manifold absolute pressure'],
      Pid.voltage => ['voltage', 'control module voltage'],
    };
    return headers.indexWhere((h) {
      final normalized = h
          .toLowerCase()
          .replaceAll(RegExp(r'[_]'), ' ')
          .replaceAll(RegExp(r'\s*[\[(].*'), '')
          .trim();
      if (pid == Pid.fuelRate && h.toLowerCase().contains('g/s')) return false;
      // Absolute load (PID 43) is not interchangeable with calculated load (04).
      if (pid == Pid.load && normalized.contains('absolute')) return false;
      return names.contains(normalized);
    });
  }
}

class CsvImportResult {
  const CsvImportResult(this.frames, this.discardedRows, this.invalidValues);
  final List<TelemetryFrame> frames;
  final int discardedRows, invalidValues;
}

abstract final class CsvImporter {
  static CsvImportResult convert(
    CsvPreview preview,
    int timeColumn,
    Map<Pid, int> mapping, {
    required bool elapsedSeconds,
    required DateTime origin,
  }) {
    if (timeColumn < 0) {
      throw const FormatException('Seleziona la colonna del tempo.');
    }
    if (mapping.isEmpty) {
      throw const FormatException('Associa almeno un parametro OBD.');
    }
    if (mapping.values.toSet().length != mapping.length ||
        mapping.values.contains(timeColumn)) {
      throw const FormatException(
        'Ogni parametro deve usare una colonna distinta.',
      );
    }
    for (final e in mapping.entries) {
      final header = preview.headers[e.value].toLowerCase();
      if (e.key == Pid.fuelRate &&
          (header.contains('g/s') || header.contains('gal'))) {
        throw const FormatException(
          'Il fuel rate deve essere in l/h. g/s e gal/h richiedono una conversione esplicita.',
        );
      }
      if (e.key == Pid.load && header.contains('absolute')) {
        throw const FormatException(
          'Usa calculated load (PID 04), non absolute load (PID 43).',
        );
      }
    }
    final frames = <TelemetryFrame>[];
    var discarded = 0, invalid = 0;
    String cell(List<dynamic> row, int index) =>
        index < row.length ? row[index].toString().trim() : '';
    double? number(String text) => double.tryParse(text.replaceAll(',', '.'));
    final seen = <int>{};
    final segmentIndex = preview.headers.indexOf('segment');
    for (final row in preview.rows) {
      final time = cell(row, timeColumn);
      DateTime? at;
      if (elapsedSeconds) {
        final seconds = number(time);
        if (seconds != null &&
            seconds.isFinite &&
            seconds >= 0 &&
            seconds <= 86400) {
          at = origin.toUtc().add(
            Duration(microseconds: (seconds * 1e6).round()),
          );
        }
      } else {
        // Require timezone for absolute times to avoid device-dependent imports.
        if (RegExp(r'(Z|[+-]\d\d:\d\d)$').hasMatch(time)) {
          at = DateTime.tryParse(time)?.toUtc();
        }
      }
      if (at == null || !seen.add(at.microsecondsSinceEpoch)) {
        discarded++;
        continue;
      }
      final values = <Pid, double>{};
      final observed = <Pid, DateTime>{};
      for (final e in mapping.entries) {
        final raw = cell(row, e.value);
        if (raw.isEmpty) continue;
        var value = number(raw);
        final header = preview.headers[e.value].toLowerCase();
        if (value != null) {
          if (e.key == Pid.speed && header.contains('mph')) value *= 1.609344;
          if (e.key == Pid.coolant &&
              (header.contains('°f') || header.contains('(f)'))) {
            value = (value - 32) * 5 / 9;
          }
          if (e.key == Pid.manifold && header.contains('psi')) {
            value *= 6.894757;
          }
        }
        if (value == null || !TripAnalyzer.validValue(e.key, value)) {
          invalid++;
          continue;
        }
        final observedIndex = preview.headers.indexOf(
          '${e.key.name}_observed_at',
        );
        final timestamp = observedIndex < 0
            ? at
            : DateTime.tryParse(cell(row, observedIndex))?.toUtc();
        if (timestamp == null ||
            timestamp.isAfter(at) ||
            at.difference(timestamp) > e.key.maxAge) {
          invalid++;
          continue;
        }
        values[e.key] = value;
        observed[e.key] = timestamp;
      }
      if (values.isEmpty) {
        discarded++;
        continue;
      }
      frames.add(
        TelemetryFrame(
          at: at,
          values: values,
          observedAt: observed,
          segment: segmentIndex < 0
              ? 0
              : int.tryParse(cell(row, segmentIndex)) ?? 0,
        ),
      );
    }
    frames.sort((a, b) => a.at.compareTo(b.at));
    if (frames.length < 2) {
      throw const FormatException(
        'Servono almeno due righe con tempo e dati validi.',
      );
    }
    if (frames.last.at.difference(frames.first.at) >
        const Duration(hours: 24)) {
      throw const FormatException('Durata massima: 24 ore.');
    }
    // Causal resampling to the same 500 ms grid as acquisition. Gaps stay empty.
    final output = <TelemetryFrame>[];
    var index = 0;
    for (
      var at = frames.first.at;
      !at.isAfter(frames.last.at);
      at = at.add(const Duration(milliseconds: 500))
    ) {
      if (output.length >= 172801) {
        throw const FormatException('Durata massima: 24 ore.');
      }
      while (index + 1 < frames.length && !frames[index + 1].at.isAfter(at)) {
        index++;
      }
      final frame = frames[index];
      if (at.difference(frame.at).inMilliseconds > 1500) continue;
      output.add(
        TelemetryFrame(
          at: at,
          segment: frame.segment,
          values: {
            for (final e in frame.values.entries)
              if (at.difference(frame.observedAt[e.key]!) <= e.key.maxAge)
                e.key: e.value,
          },
          observedAt: frame.observedAt,
        ),
      );
    }
    return CsvImportResult(output, discarded, invalid);
  }

  static String export(List<TelemetryFrame> frames) => csv.encode([
    [
      'timestamp',
      'segment',
      ...Pid.values.map((p) => '${p.name} (${p.unit})'),
      ...Pid.values.map((p) => '${p.name}_observed_at'),
    ],
    for (final f in frames)
      [
        f.at.toIso8601String(),
        f.segment,
        ...Pid.values.map((p) => f[p] ?? ''),
        ...Pid.values.map(
          (p) => f[p] == null ? '' : f.observedAt[p]!.toIso8601String(),
        ),
      ],
  ]);
}
