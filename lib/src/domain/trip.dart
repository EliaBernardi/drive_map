import 'telemetry.dart';

enum TripSource { obd, demo, csv }

class Trip {
  const Trip({
    required this.id,
    required this.name,
    required this.startedAt,
    this.endedAt,
    required this.source,
    required this.status,
    required this.configJson,
    this.frameCount = 0,
    this.vehicle = 'Ford Fiesta 2021',
  });
  final String id;
  final String name;
  final String vehicle;
  final DateTime startedAt;
  final DateTime? endedAt;
  final TripSource source;
  final String status;
  final String configJson;
  final int frameCount;
}

class TripData {
  const TripData(this.trip, this.frames);
  final Trip trip;
  final List<TelemetryFrame> frames;
}
