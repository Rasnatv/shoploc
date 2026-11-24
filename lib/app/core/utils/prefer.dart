
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Shared preference storage
class Prefs {
  JsonCodec codec = const JsonCodec();
  SharedPreferences? _sharedPreferences;

  static const String _AUTH_TOKEN = "auth_token";
  static const String _IS_LOGGED_IN = "is_logged_in";
  static const String _FCM_TOKEN = "fcm_token";
  static const String _USER_ID = "USER_ID";
  static const String _USER_NAME = "user_name";
  static const String _USER_EMAIL = "user_email";
  static const String _MODEL = "model";
  static const String _MODEL_NAME = "model_name";
  static const String _MODEL_VERSION = "model_version";
  static const String _APP_VERSION = "app_version";
  static const String _REFERRAL_CODE = "referral_code";
  static const String _REFERRER_CHECKED = "referrer_checked";
  static const String _ONBOARDING_COMPLETE = "onboarding_complete";

  Prefs();

  set sharedPreferences(SharedPreferences value) {
    _sharedPreferences = value;
  }

  // ---------------- AUTH TOKEN ----------------
  void setAuthToken({String? accesstoken}) {
    _sharedPreferences!.setString(_AUTH_TOKEN, accesstoken ?? "");
  }

  String? getAuthToken() => _sharedPreferences!.getString(_AUTH_TOKEN);

  /// true only for a logged-in user (guest = no saved token).
  /// Use this before calling any API that needs authentication.
  bool get hasAuthToken {
    final token = getAuthToken();
    return token != null && token.isNotEmpty && (isLoggedIn() ?? false);
  }

  // ---------------- USER ----------------
  void setUserId({String? user_id}) {
    _sharedPreferences!.setString(_USER_ID, user_id ?? "");
  }

  String? getUseriD() => _sharedPreferences!.getString(_USER_ID);

  void setUserName(String v) => _sharedPreferences!.setString(_USER_NAME, v);
  String? getUserName() => _sharedPreferences!.getString(_USER_NAME);

  void setUserEmail(String v) => _sharedPreferences!.setString(_USER_EMAIL, v);
  String? getUserEmail() => _sharedPreferences!.getString(_USER_EMAIL);

  // ---------------- FCM (not used, kept so the API gets the field) ----------------
  String? getFcmToken() => _sharedPreferences!.getString(_FCM_TOKEN);

  void setFcmToken({String? fcmToken}) {
    _sharedPreferences!.setString(_FCM_TOKEN, fcmToken ?? "");
  }

  // ---------------- LOGIN FLAG ----------------
  /// after login set true, before logout set false
  void setIsLoggedIn(bool status) {
    _sharedPreferences!.setBool(_IS_LOGGED_IN, status);
  }

  bool? isLoggedIn() => _sharedPreferences!.getBool(_IS_LOGGED_IN) ?? false;

  // ---------------- DEVICE INFO ----------------
  void setDeviceInfo({
    String? model,
    String? modelName,
    String? modelVersion,
  }) {
    _sharedPreferences!.setString(_MODEL, model ?? "");
    _sharedPreferences!.setString(_MODEL_NAME, modelName ?? "");
    _sharedPreferences!.setString(_MODEL_VERSION, modelVersion ?? "");
  }

  String? getModel() => _sharedPreferences!.getString(_MODEL);
  String? getModelName() => _sharedPreferences!.getString(_MODEL_NAME);
  String? getModelVersion() => _sharedPreferences!.getString(_MODEL_VERSION);

  void setAppVersion(String version) {
    _sharedPreferences!.setString(_APP_VERSION, version);
  }

  String? getAppVersion() => _sharedPreferences!.getString(_APP_VERSION);

  // ---------------- REFERRAL (Play Store install referrer) ----------------
  void setReferralCode(String code) {
    _sharedPreferences!.setString(_REFERRAL_CODE, code);
  }

  String? getReferralCode() => _sharedPreferences!.getString(_REFERRAL_CODE);

  void clearReferralCode() {
    _sharedPreferences!.remove(_REFERRAL_CODE);
  }

  /// The install referrer is read only once per install
  void setReferrerChecked(bool v) {
    _sharedPreferences!.setBool(_REFERRER_CHECKED, v);
  }

  bool isReferrerChecked() =>
      _sharedPreferences!.getBool(_REFERRER_CHECKED) ?? false;

  // ---------------- ONBOARDING ----------------
  void setOnboardingComplete(bool v) {
    _sharedPreferences!.setBool(_ONBOARDING_COMPLETE, v);
  }

  bool isOnboardingComplete() =>
      _sharedPreferences!.getBool(_ONBOARDING_COMPLETE) ?? false;

  // ---------------- LOGOUT / CLEAR ----------------
  /// Logout: clears the session, keeps onboarding + device info
  Future<void> clearSession() async {
    await _sharedPreferences!.remove(_AUTH_TOKEN);
    await _sharedPreferences!.remove(_USER_ID);
    await _sharedPreferences!.remove(_USER_NAME);
    await _sharedPreferences!.remove(_USER_EMAIL);
    await _sharedPreferences!.setBool(_IS_LOGGED_IN, false);
  }

  /// Clears everything (this also resets onboarding)
  Future<void> clearPrefs() async {
    await _sharedPreferences?.clear();
  }

}