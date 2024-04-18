import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BackgroundManager {
  static final _service = FlutterBackgroundService();

  @pragma('vm:entry-point')
  static Future<void> initializeService() async {
    await _service.configure(
      androidConfiguration: AndroidConfiguration(
        //* this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,

        //* auto start service
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'update_meeting_channel',
        initialNotificationTitle: 'Show nearest POC',
        initialNotificationContent: 'Show nearest POC',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        //* auto start service
        autoStart: true,

        //* this will be executed when app is in foreground in separated isolate
        onForeground: onStart,

        //* you have to enable background fetch capability on xcode project
        onBackground: onIosBackground,
      ),
    );
  }

//* to ensure this is executed
//* run app from xcode, then from xcode menu, select Simulate Background Fetch

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.reload();
    final log = preferences.getStringList('log') ?? <String>[];
    log.add(DateTime.now().toIso8601String());
    await preferences.setStringList('log', log);
    return true;
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    //* Only available for flutter 3.0.0 and later
    DartPluginRegistrant.ensureInitialized();

    // //* For flutter prior to version 3.0.0
    // //* We have to register the plugin manually

    // SharedPreferences preferences = await SharedPreferences.getInstance();
    // await preferences.setString("hello", "world");

    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) async {
        await service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) async {
        await service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) async {
      await service.stopSelf();
    });

    // // bring to foreground
    // Timer.periodic(const Duration(seconds: 1), (timer) async {
    //   if (service is AndroidServiceInstance) {
    //     if (await service.isForegroundService()) {

    //     }
    //   }

    //   ///* you can see this log in logcat
    //   // write('FLUTTER BACKGROUND SERVICE: ${DateTime.now()}');
    // });
  }

  static Future<void> startService() async {
    final running = await isRunning;
    if (!running) {
      await _service.startService();
      foreground;
    }
  }

  static Future<void> stopService() async {
    final running = await isRunning;
    if (running) {
      _service.invoke("stopService");
    }
  }

  static Future<bool> get isRunning async => await _service.isRunning();

  static void get foreground => _service.invoke("setAsForeground");

  static void get background => _service.invoke("setAsBackground");
}
