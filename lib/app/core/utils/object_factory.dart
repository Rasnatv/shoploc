import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoploc/app/core/utils/prefer.dart';


import '../api_client/api_client.dart';

/// Hub connecting prefs, repo and client.
/// Used to reduce imports in pages.
class ObjectFactory {
  static final _objectFactory = ObjectFactory._internal();

  ObjectFactory._internal();

  factory ObjectFactory() => _objectFactory;

  final Prefs _prefs = Prefs();
  final ApiClient _apiClient = ApiClient();

  Future<void> initPrefs() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    _prefs.sharedPreferences = sharedPrefs;
  }

  ApiClient get apiClient => _apiClient;
  Prefs get prefs => _prefs;
}