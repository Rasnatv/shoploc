import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:play_install_referrer/play_install_referrer.dart';
import '../storage/local_storage_service.dart';

/// Centralized service to read and extract Google Play Install Referrer parameters.
/// Securely reads the referral code (e.g. STAFF001, STAFF002, STAFF003) on app launch
/// and stores it in [LocalStorageService] for subsequent signup/OTP verification.
class ReferralService {
  ReferralService._();

  static bool _isChecking = false;

  /// Initializes the install referrer check asynchronously.
  /// Designed to be called at app startup or splash initialization without blocking UI.
  static Future<void> init(LocalStorageService storageService) async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      await checkAndRecordReferral(storageService);
    } catch (e) {
      debugPrint('[ReferralService] Referral reading error: $e');
    } finally {
      _isChecking = false;
    }
  }

  /// Queries the Google Play Install Referrer API and saves any valid referral code.
  /// Returns the detected or already-stored referral code, or null if none found.
  static Future<String?> checkAndRecordReferral(
    LocalStorageService storageService,
  ) async {
    debugPrint('[ReferralService] Referral checking started.');

    // 1. Guard against overwriting an already saved referral code
    if (storageService.hasReferralCode()) {
      final existingCode = storageService.getReferralCode();
      debugPrint(
        '[ReferralService] Referral code already saved previously: $existingCode',
      );
      return existingCode;
    }

    // 2. Platform guard: Google Play Install Referrer is Android only
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      debugPrint(
        '[ReferralService] Google Play Install Referrer is only available on Android. Skipping on ${defaultTargetPlatform.name}.',
      );
      return null;
    }

    // 3. Read Google Play Install Referrer
    try {
      final ReferrerDetails referrerDetails =
          await PlayInstallReferrer.installReferrer.timeout(
        const Duration(seconds: 5),
      );

      final String? rawReferrer = referrerDetails.installReferrer;
      debugPrint('[ReferralService] Install referrer received: $rawReferrer');

      if (rawReferrer == null || rawReferrer.trim().isEmpty) {
        debugPrint('[ReferralService] No referral code found.');
        return null;
      }

      // 4. Extract referral code parameter
      final String? referralCode = extractReferralCode(rawReferrer);

      if (referralCode != null && referralCode.isNotEmpty) {
        debugPrint('[ReferralService] Referral code found: $referralCode');

        final bool saved = await storageService.saveReferralCode(referralCode);
        if (saved) {
          debugPrint(
            '[ReferralService] Referral code saved successfully: $referralCode',
          );
        }
        return referralCode;
      } else {
        debugPrint('[ReferralService] No referral code found.');
        return null;
      }
    } catch (e) {
      // Handles missing Play Services, emulator environments, timeouts or non-Play installs gracefully
      debugPrint('[ReferralService] Referral reading error: $e');
      return null;
    }
  }

  /// Parses and extracts the `referral_code` parameter from a raw referrer string or full URL.
  ///
  /// Examples:
  /// - Full Play Store URL: `https://play.google.com/store/apps/details?id=com.astraz.shoplocproject&referrer=referral_code%3DSTAFF001` -> `STAFF001`
  /// - Direct parameter: `referral_code=STAFF001` -> `STAFF001`
  /// - UTM campaign link: `utm_source=google-play&referral_code=STAFF002&utm_medium=organic` -> `STAFF002`
  /// - URL-encoded: `utm_source%3Dgoogle%26referral_code%3DSTAFF003` -> `STAFF003`
  /// - Direct code fallback: `STAFF001` -> `STAFF001`
  /// - Organic install without referral -> `null`
  static String? extractReferralCode(String? rawReferrer) {
    if (rawReferrer == null) return null;

    String cleaned = rawReferrer.trim();
    if (cleaned.isEmpty) return null;

    // 1. If a full Play Store or web URL is passed, parse its query parameters first
    if (cleaned.contains('://') || cleaned.contains('play.google.com')) {
      try {
        final uri = Uri.parse(cleaned);
        // Check if there is an explicit 'referrer' parameter (Google Play URL standard)
        final referrerParam = uri.queryParameters['referrer'];
        if (referrerParam != null && referrerParam.isNotEmpty) {
          final nestedCode = extractReferralCode(referrerParam);
          if (nestedCode != null) return nestedCode;
        }
        // Direct query param: ?referral_code=STAFF001
        for (final key in ['referral_code', 'referralcode', 'ref_code', 'ref']) {
          if (uri.queryParameters.containsKey(key)) {
            final val = _sanitizeCode(uri.queryParameters[key]);
            if (val != null && val.isNotEmpty) return val;
          }
        }
      } catch (_) {
        // Fall back to string parsing below
      }
    }

    // Decode URL query encoding if %3D or %26 are present (e.g. Play Store URL encoded)
    for (int i = 0; i < 2; i++) {
      if (cleaned.contains('%')) {
        try {
          cleaned = Uri.decodeComponent(cleaned);
        } catch (_) {
          break;
        }
      }
    }

    // Strip leading '?' or '#' if present
    if (cleaned.startsWith('?') || cleaned.startsWith('#')) {
      cleaned = cleaned.substring(1);
    }

    // 2. Try standard query string split
    try {
      final Map<String, String> params = Uri.splitQueryString(cleaned);
      for (final MapEntry<String, String> entry in params.entries) {
        final key = entry.key.trim().toLowerCase();
        if (key == 'referral_code' ||
            key == 'referralcode' ||
            key == 'ref_code' ||
            key == 'ref') {
          final val = _sanitizeCode(entry.value);
          if (val != null && val.isNotEmpty) {
            return val;
          }
        } else if (key == 'referrer') {
          // e.g. referrer=referral_code=STAFF001 or referrer=STAFF001
          final subVal = entry.value.trim();
          if (subVal.isNotEmpty) {
            final subCode = extractReferralCode(subVal);
            if (subCode != null && subCode.isNotEmpty) return subCode;
            if (RegExp(r'^[A-Za-z0-9_-]{3,25}$').hasMatch(subVal)) {
              return subVal;
            }
          }
        }
      }
    } catch (_) {
      // Fall through to regex parser
    }

    // 3. Robust Regex fallback for non-standard formatted strings
    final RegExp regExp = RegExp(
      r'(?:^|[&?;=])(?:referral_code|referralcode|ref_code|ref)=([^&;\s]+)',
      caseSensitive: false,
    );

    final Match? match = regExp.firstMatch(cleaned);
    if (match != null && match.groupCount >= 1) {
      final String? matchedValue = match.group(1);
      final val = _sanitizeCode(matchedValue);
      if (val != null && val.isNotEmpty) {
        return val;
      }
    }

    // 4. Direct code fallback if string looks like an isolated staff referral code (e.g. STAFF001)
    if (RegExp(r'^[A-Za-z0-9_-]{3,25}$').hasMatch(cleaned) &&
        !cleaned.contains('=') &&
        !cleaned.contains('&')) {
      return cleaned;
    }

    return null;
  }

  /// Strips whitespace and optional surrounding quotes from the extracted code.
  static String? _sanitizeCode(String? code) {
    if (code == null) return null;
    var trimmed = code.trim();
    if ((trimmed.startsWith('"') && trimmed.endsWith('"')) ||
        (trimmed.startsWith("'") && trimmed.endsWith("'"))) {
      trimmed = trimmed.substring(1, trimmed.length - 1).trim();
    }
    return trimmed.isNotEmpty ? trimmed : null;
  }

  /// Testing helper: Allows simulating or testing referral extraction in Android Studio / tests
  /// with an explicit referrer string (e.g. `referral_code=STAFF001`).
  static Future<String?> processReferrerForTesting(
    LocalStorageService storageService,
    String? testReferrer,
  ) async {
    debugPrint(
      '[ReferralService] Testing referral extraction with input: "$testReferrer"',
    );
    final String? code = extractReferralCode(testReferrer);

    if (code != null && code.isNotEmpty) {
      debugPrint('[ReferralService] Referral code found: $code');
      final bool saved = await storageService.saveReferralCode(code);
      if (saved) {
        debugPrint(
          '[ReferralService] Referral code saved successfully: $code',
        );
      }
      return code;
    } else {
      debugPrint('[ReferralService] No referral code found.');
      return null;
    }
  }
}

// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'package:play_install_referrer/play_install_referrer.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class ReferralService {
//   static const _kCode = 'referral_code';
//   static const _kChecked = 'referral_checked';
//
//   // ടെസ്റ്റിന് വേണ്ടി dummy code. റിലീസിന് മുമ്പ് false ആക്കുക.
//   static const bool useDummy = true;
//   static const String dummyCode = 'SAL123';
//
//   /// ആപ്പ് തുടങ്ങുമ്പോൾ ഒരു തവണ വിളിക്കുക
//   static Future<void> capture() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     // ഇതിനകം പരിശോധിച്ചെങ്കിൽ വീണ്ടും വേണ്ട
//     if (prefs.getBool(_kChecked) == true) return;
//
//     // 1) Dummy mode (debug-ൽ മാത്രം)
//     if (kDebugMode && useDummy) {
//       await prefs.setString(_kCode, dummyCode);
//       await prefs.setBool(_kChecked, true);
//       return;
//     }
//
//     // 2) യഥാർത്ഥ Play Install Referrer
//     if (!Platform.isAndroid) {
//       await prefs.setBool(_kChecked, true);
//       return;
//     }
//
//     try {
//       final details = await PlayInstallReferrer.installReferrer;
//       final referrer = details.installReferrer ?? ''; // "ref=SAL123"
//       final code = Uri.splitQueryString(referrer)['ref'];
//       if (code != null && code.isNotEmpty) {
//         await prefs.setString(_kCode, code);
//       }
//     } catch (e) {
//       // കിട്ടിയില്ലെങ്കിലും ആപ്പ് പ്രവർത്തിക്കണം
//     }
//
//     await prefs.setBool(_kChecked, true);
//   }
//
//   /// Registration screen-ൽ വായിക്കാൻ
//   static Future<String?> getSavedCode() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString(_kCode);
//   }
//
//   /// Register വിജയിച്ച ശേഷം നീക്കം ചെയ്യുക
//   static Future<void> clear() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove(_kCode);
//   }
// }