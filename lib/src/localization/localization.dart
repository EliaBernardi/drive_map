import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../features/analytics/trip_analyzer.dart';
import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

part 'legacy_messages.dart';

extension LocalizedContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension PresentationMessages on AppLocalizations {
  String pidLabel(int code) => switch (code) {
    0x04 => pidLoad,
    0x05 => pidCoolant,
    0x0B => pidManifold,
    0x0C => pidRpm,
    0x0D => pidSpeed,
    0x11 => pidThrottle,
    0x42 => pidVoltage,
    0x5E => pidFuelRate,
    0x2F => pidFuelLevel,
    0x62 => pidTorque,
    0x63 => pidReferenceTorque,
    0xA6 => pidOdometer,
    _ => 'PID ${code.toRadixString(16).padLeft(2, '0').toUpperCase()}',
  };

  String error(Object value) => message(switch (value) {
    FormatException(message: 'Invalid double') => invalidNumber,
    FormatException() => value.message,
    StateError() => value.message.toString(),
    PlatformException() => value.message ?? value.code,
    TimeoutException() => value.message ?? value.toString(),
    _ => value.toString(),
  });

  /// Existing diagnostic/domain messages also update when the locale changes.
  /// Unknown adapter or OS messages are preserved verbatim for troubleshooting.
  String message(String value) {
    for (final prefix in ['FormatException: ', 'Bad state: ']) {
      if (value.startsWith(prefix)) {
        return message(value.substring(prefix.length));
      }
    }
    final translated = _staticMessage(value);
    if (translated != null) return translated;
    final patterns = <(String, String Function(RegExpMatch))>[
      (r'^TimeoutException(?: after [\d:.]+)?: (.+)$', (m) => message(m[1]!)),
      (r'^Riconnessione (\d+) di 3…$', (m) => reconnectingAttempt(m[1]!)),
      (r'^Connessione a (.+)…$', (m) => connectingDevice(m[1]!)),
      (
        r'^Associazione a (.+)… Conferma la richiesta Android\.$',
        (m) => pairingDevice(m[1]!),
      ),
      (r'^Connesso a (.+)$', (m) => connectedDevice(m[1]!)),
      (r'^Interrogo i PID (\d+)–(\d+)…$', (m) => pidsQueryRange(m[1]!, m[2]!)),
      (
        r'^(\d+) PID standard rilevati sulla centralina (.+)\.$',
        (m) => pidsFound(m[1]!, m[2]!),
      ),
      (
        r'^Verifica PID non completata: (.+)$',
        (m) => pidCheckFailed(message(m[1]!)),
      ),
      (r'^Test in corso · (\d+) / 30 s$', (m) => testProgress(m[1]!)),
      (
        r'^Test interrotto dopo (\d+)s · (\d+) letture valide$',
        (m) => testInterrupted(m[1]!, m[2]!),
      ),
      (
        r'^Test completato · 30 s · (\d+) letture valide$',
        (m) => testCompleted(m[1]!),
      ),
      (r'^Test interrotto: (.+)$', (m) => testFailed(message(m[1]!))),
      (
        r'^Penalità per carico oltre (\d+)% sotto (\d+) °C, sul tempo osservato\.$',
        (m) => warmupReason(m[1]!, m[2]!),
      ),
      (
        r'^Rapporto rispetto alla baseline ([\d.]+) l/100 km; richiede copertura ≥80% e distanza ≥100 m\.$',
        (m) => economyReason(m[1]!),
      ),
      (r'^Modello (.+) non supportato$', (m) => unsupportedModel(m[1]!)),
      (
        r'^Inizializzazione fallita: (.+)\.$',
        (m) => initializationFailed(m[1]!),
      ),
      (
        r'^L’adattatore non ha confermato (.+)\.$',
        (m) => unconfirmedCommand(m[1]!),
      ),
      (r'^Risposta PID (.+) incompleta$', (m) => incompletePidResponse(m[1]!)),
      (r'^Risposta (.+) incompleta$', (m) => incompleteResponse(m[1]!)),
      (r'^PID standard non decodificato: (.+)$', (m) => undecodedPid(m[1]!)),
      (r'^Nessuna risposta a (.+)$', (m) => noResponse(m[1]!)),
      (
        r'^Collegamento non riuscito: (.+)$',
        (m) => connectionError(message(m[1]!)),
      ),
      (
        r'^Salvataggio non riuscito; registrazione in pausa\. I dati in memoria sono conservati\. (.+)$',
        (m) => saveRecordingFailed(message(m[1]!)),
      ),
      (r'^Viaggio (\d+/\d+)$', (m) => automaticTripName(m[1]!)),
    ];
    for (final (pattern, format) in patterns) {
      final match = RegExp(pattern, dotAll: true).firstMatch(value);
      if (match != null) return format(match);
    }
    return value;
  }

  String analysisExplanation(TripAnalysis analysis) {
    if (analysis.score == null) return scoreRequiresData;
    final active = analysis.parts.where((p) => p.value != null && p.weight > 0);
    final coverage = analysis.duration > 0
        ? (analysis.validMapSeconds / analysis.duration).clamp(0, 1)
        : 0.0;
    return scoreIntro('${analysis.score!.round()}', '${active.length}') +
        (analysis.validMapSeconds > 0
            ? scoreMapPortion('${(analysis.favorableFraction * 100).round()}')
            : scoreNoMap) +
        scoreEventCount('${analysis.events.length}') +
        (analysis.parts.any((p) => p.value == null)
            ? scoreWeightsNormalized
            : '') +
        scoreMapCoverage('${(coverage * 100).round()}');
  }
}
