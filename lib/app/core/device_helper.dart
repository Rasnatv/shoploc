import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shoploc/app/core/utils/object_factory.dart';

class DeviceHelper {
  static Future<void> init() async {
    final prefs = ObjectFactory().prefs;

    try {
      final pkg = await PackageInfo.fromPlatform();
      prefs.setAppVersion(pkg.version);
    } catch (_) {
      prefs.setAppVersion('1.0.0');
    }

    try {
      final info = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final a = await info.androidInfo;
        prefs.setDeviceInfo(
          model: a.manufacturer, // "samsung"
          modelName: a.model, // "SM-A336"
          modelVersion: 'Android ${a.version.release}',
        );
      } else if (Platform.isIOS) {
        final i = await info.iosInfo;
        prefs.setDeviceInfo(
          model: 'Apple',
          modelName: i.utsname.machine,
          modelVersion: 'iOS ${i.systemVersion}',
        );
      }
    } catch (_) {}

    if ((prefs.getFcmToken() ?? '').isEmpty) prefs.setFcmToken(fcmToken: 'no_fcm');
  }
}

