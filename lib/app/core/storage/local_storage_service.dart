import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

/// Centralized Local Storage Service wrapping SharedPreferences.
/// Provides robust persistence and restoration across application restarts.
class LocalStorageService {
  static LocalStorageService? _instance;
  static SharedPreferences? _prefs;

  LocalStorageService._();

  static Future<LocalStorageService> getInstance() async {
    _instance ??= LocalStorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Generic Getters & Setters
  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  // Onboarding
  bool isOnboardingComplete() {
    return getBool(AppConstants.keyOnboardingComplete, defaultValue: false);
  }

  Future<bool> setOnboardingComplete(bool complete) {
    return setBool(AppConstants.keyOnboardingComplete, complete);
  }

  // Authentication & User
  bool isLoggedIn() {
    return getBool(AppConstants.keyIsLoggedIn, defaultValue: false);
  }

  Future<bool> setLoggedIn(bool loggedIn) {
    return setBool(AppConstants.keyIsLoggedIn, loggedIn);
  }

  Map<String, dynamic>? getCurrentUser() {
    final raw = getString(AppConstants.keyCurrentUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveCurrentUser(Map<String, dynamic> userMap) {
    return setString(AppConstants.keyCurrentUser, jsonEncode(userMap));
  }

  Future<void> clearUserSession() async {
    await setLoggedIn(false);
    await remove(AppConstants.keyCurrentUser);
  }

  // Wishlist
  List<String> getWishlistIds() {
    final raw = getString(AppConstants.keyWishlist);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveWishlistIds(List<String> ids) {
    return setString(AppConstants.keyWishlist, jsonEncode(ids));
  }

  // Cart
  List<Map<String, dynamic>> getCartItems() {
    final raw = getString(AppConstants.keyCart);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveCartItems(List<Map<String, dynamic>> items) {
    return setString(AppConstants.keyCart, jsonEncode(items));
  }

  // Addresses
  List<Map<String, dynamic>> getAddresses() {
    final raw = getString(AppConstants.keyAddresses);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveAddresses(List<Map<String, dynamic>> addresses) {
    return setString(AppConstants.keyAddresses, jsonEncode(addresses));
  }

  // Orders
  List<Map<String, dynamic>> getOrders() {
    final raw = getString(AppConstants.keyOrders);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveOrders(List<Map<String, dynamic>> orders) {
    return setString(AppConstants.keyOrders, jsonEncode(orders));
  }

  // Recently Viewed Product IDs
  List<String> getRecentlyViewedIds() {
    final raw = getString(AppConstants.keyRecentlyViewed);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => e.toString()).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveRecentlyViewedIds(List<String> ids) {
    return setString(AppConstants.keyRecentlyViewed, jsonEncode(ids));
  }

  // Notifications
  List<Map<String, dynamic>> getNotifications() {
    final raw = getString(AppConstants.keyNotifications);
    if (raw == null || raw.isEmpty) return [];
    try {
      final List<dynamic> decoded = jsonDecode(raw);
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveNotifications(List<Map<String, dynamic>> notifications) {
    return setString(AppConstants.keyNotifications, jsonEncode(notifications));
  }
}

