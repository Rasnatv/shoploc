import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:play_install_referrer/play_install_referrer.dart';
import 'package:shoploc/app/core/utils/object_factory.dart';

class ReferralService {
  /// Reads the Play Store install referrer once per install and saves it in Prefs.
  /// The Register screen then autofills the Referral Code field from Prefs.
  static Future<void> captureInstallReferrer() async {
    final prefs = ObjectFactory().prefs;
    if (prefs.isReferrerChecked() || !Platform.isAndroid) return;

    try {
      final details = await PlayInstallReferrer.installReferrer;
      final raw = details.installReferrer;
      final code = _parse(raw);
      debugPrint('[Referral] raw=$raw parsed=$code');

      if (code != null && code.isNotEmpty) prefs.setReferralCode(code);
      prefs.setReferrerChecked(true);
    } catch (e) {
      debugPrint('[Referral] failed: $e'); // retries on next launch
    }
  }

  /// Supports "STAFF001" and "referral_code=STAFF001&utm_source=..."
  static String? _parse(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    raw = raw.trim();

    if (!raw.contains('=')) return raw;

    try {
      final p = Uri.splitQueryString(raw);
      final code = p['referral_code'] ?? p['ref'] ?? p['code'];
      return (code == null || code.trim().isEmpty) ? null : code.trim();
    } catch (_) {
      return null;
    }
    // "utm_source=google-play&utm_medium=organic" returns null, which is correct
  }
}