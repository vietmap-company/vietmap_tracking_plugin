import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'tracking_location.dart';
import 'tracking_location_background.dart';


@pragma('vm:entry-point')
class TrackingService {
  static final TrackingService _singleton = TrackingService._internal();

  factory TrackingService() {
    return _singleton;
  }
  TrackingService._internal();

  static FlutterBackgroundService serviceBackground =
      FlutterBackgroundService();
  static bool trackingLocation = false;
  static bool asyncData = false;

  static getInstance() async {
    initializeService();
  }

  @pragma('vm:entry-point')
  static Future<void> initializeService() async {
    final service = FlutterBackgroundService();

    /// OPTIONAL, using custom notification channel id
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'my_foreground',
      'vm-tracking-location',
      description: '',
      importance: Importance.low,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        // this will be executed when app is in foreground or background in separated isolate
        onStart: onStart,
        // auto start service
        autoStart: false,
        isForegroundMode: true,
        notificationChannelId: 'my_foreground',
        initialNotificationTitle: 'Fleetwork',
        initialNotificationContent: 'Service',
        foregroundServiceNotificationId: 888,
      ),
      iosConfiguration: IosConfiguration(
        // auto start service
        autoStart: false,
        // this will be executed when app is in foreground in separated isolate
        onForeground: onStart,
        // you have to enable background fetch capability on xcode project
        onBackground: onIosBackground,
      ),
    );
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // Only available for flutter 3.0.0 and later
    DartPluginRegistrant.ensureInitialized();

    /// Receive data
    if (service is AndroidServiceInstance) {
      service.on('setAsForeground').listen((event) {
        service.setAsForegroundService();
      });

      service.on('setAsBackground').listen((event) {
        service.setAsBackgroundService();
      });
    }

    service.on('stopService').listen((event) {
      endCurrentService(service);
    });

    service.on('trackingLocation').listen((event) {
      trackingLocation = true;
      TrackingLocation.startTracking();
    });

    service.on('stopTrackingLocation').listen((event) {
      trackingLocation = false;
      TrackingLocation.stopTracking();
    });

    service.on('handleAsyncData').listen(
      (event) async {
        asyncData = true;
        // bool isStop =
        //     await FWExecutionTaskOffline().handleAsyncDataToServer(service);
        // if (isStop) {
        //   endCurrentService(service);
        // }
      },
    );
  }

  @pragma('vm:entry-point')
  static Future<bool> onIosBackground(ServiceInstance service) async {
    WidgetsFlutterBinding.ensureInitialized();
    DartPluginRegistrant.ensureInitialized();
    return true;
  }

  static void endCurrentService(ServiceInstance service) {
    trackingLocation = false;
    asyncData = false;
    service.stopSelf();
  }

  static Future<void> start() async {
    debugPrint("StartTrackingLocation");
    await serviceBackground.startService();
    TrackingLocationBackground.startLocation();
    var isRunning = await checkServiceStart();
    if (isRunning) {
      serviceBackground.invoke("trackingLocation");
    }
  }

  static Future<void> stop() async {
    debugPrint("EndTrackingService");
    TrackingLocationBackground.stopLocation();
    var isRunning = await checkServiceStart();
    if (isRunning) {
      serviceBackground.invoke("stopTrackingLocation");
      if (!asyncData) {
        serviceBackground.invoke("stopService");
      }
    }
  }

  static void handleAsyncData() async {
    // bool? keyAsyncData = await FWSharePreference().getKeyAsyncData();
    // if (keyAsyncData != null && keyAsyncData) return;
    debugPrint("StartHandleAsyncData");
    await serviceBackground.startService();
    var isRunning = await checkServiceStart();
    if (isRunning) {
      // await FWSharePreference().setKeyAsyncData(true);
      serviceBackground.invoke("handleAsyncData");
    }
  }

  static Future<bool> checkServiceStart() async {
    var isRunning = await serviceBackground.isRunning();
    return isRunning;
  }
}
