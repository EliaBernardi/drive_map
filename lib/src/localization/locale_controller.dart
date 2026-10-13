import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final localeProvider = AsyncNotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);

/// The app language is independent of telemetry and of each trip's data.
class LocaleController extends AsyncNotifier<Locale> {
  static const preferenceKey = 'app_language';

  @override
  Future<Locale> build() async {
    final preferences = await SharedPreferences.getInstance();
    final language = preferences.getString(preferenceKey);
    return Locale(language == 'en' ? 'en' : 'it');
  }

  Future<void> select(String languageCode) async {
    if (languageCode != 'it' && languageCode != 'en') {
      throw ArgumentError.value(languageCode, 'languageCode');
    }
    final preferences = await SharedPreferences.getInstance();
    try {
      final saved = await preferences.setString(preferenceKey, languageCode);
      if (!saved) throw StateError('language_save_failed');
    } catch (_) {
      // The plugin updates its memory cache before reporting a write failure.
      try {
        await preferences.reload();
      } catch (_) {
        // Keep the current UI language if storage itself is unavailable.
      }
      rethrow;
    }
    if (ref.mounted) state = AsyncData(Locale(languageCode));
  }
}
