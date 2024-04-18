import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geofence_service/geofence_service.dart';
import 'package:geofence_service_example/custom_overlay/custom_overlay.dart';
import 'package:geofence_service_example/services/background_services.dart';
import 'package:system_alert_window/system_alert_window.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundManager.initializeService();
  runApp(const ExampleApp());
}

@pragma("vm:entry-point")
void overlayMain() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: CustomOverlay(),
    ),
  );
}

class ExampleApp extends StatefulWidget {
  const ExampleApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  final _activityStreamController = StreamController<Activity>();
  final _geofenceStreamController = StreamController<Geofence>();

  // Create a [GeofenceService] instance and set options.
  final _geofenceService = GeofenceService.instance.setup(
      interval: 15,
      accuracy: 100,
      loiteringDelayMs: 60000,
      statusChangeDelayMs: 10000,
      useActivityRecognition: true,
      allowMockLocations: false,
      printDevLog: false,
      geofenceRadiusSortType: GeofenceRadiusSortType.DESC);

  // Create a [Geofence] list.
  final _geofenceList = <Geofence>[
    Geofence(
      id: 'Coffee Thindi 9th main Kalyan Nagar',
      latitude: 13.019722685997898,
      longitude: 77.6474592108932,
      radius: [
        // GeofenceRadius(id: 'radius_100m', length: 100),
        GeofenceRadius(id: 'radius_25m', length: 10),
        // GeofenceRadius(id: 'radius_250m', length: 250),
        // GeofenceRadius(id: 'radius_200m', length: 200),
      ],
    ),
    Geofence(
      id: '7 Eleven 9th main Kalyan Nagar',
      latitude: 13.019380927936238,
      longitude: 77.64727459227342,
      radius: [
        // GeofenceRadius(id: 'radius_100m', length: 100),
        GeofenceRadius(id: 'radius_25m', length: 10),
        // GeofenceRadius(id: 'radius_250m', length: 250),
        // GeofenceRadius(id: 'radius_200m', length: 200),
      ],
    ),
    Geofence(
      id: 'OFFICE PVT LTD',
      latitude: 13.019705,
      longitude: 77.647465,
      radius: [
        GeofenceRadius(id: 'radius_25m', length: 10),
        // GeofenceRadius(id: 'radius_100m', length: 100),
        // GeofenceRadius(id: 'radius_200m', length: 200),
      ],
    ),
  ];

  // This function is to be called when the geofence status is changed.
  Future<void> _onGeofenceStatusChanged(
      Geofence geofence,
      GeofenceRadius geofenceRadius,
      GeofenceStatus geofenceStatus,
      Location location) async {
    log('geofence: ${geofence.toJson()}');
    print('geofenceRadius: ${geofenceRadius.toJson()}');
    log('geofenceStatus: ${geofenceStatus.toString()}');
    _geofenceStreamController.sink.add(geofence);
  }

  // This function is to be called when the activity has changed.
  void _onActivityChanged(Activity prevActivity, Activity currActivity) {
    print('prevActivity: ${prevActivity.toJson()}');
    print('currActivity: ${currActivity.toJson()}');
    _activityStreamController.sink.add(currActivity);
  }

  // This function is to be called when the location has changed.
  void _onLocationChanged(Location location) {
    print('location: ${location.toJson()}');
  }

  // This function is to be called when a location services status change occurs
  // since the service was started.
  void _onLocationServicesStatusChanged(bool status) {
    print('isLocationServicesEnabled: $status');
  }

  // This function is used to handle errors that occur in the service.
  void _onError(error) {
    final errorCode = getErrorCodesFromError(error);
    if (errorCode == null) {
      print('Undefined error: $error');
      return;
    }

    print('ErrorCode: $errorCode');
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _geofenceService
          .addGeofenceStatusChangeListener(_onGeofenceStatusChanged);
      _geofenceService.addLocationChangeListener(_onLocationChanged);
      _geofenceService.addLocationServicesStatusChangeListener(
          _onLocationServicesStatusChanged);
      _geofenceService.addActivityChangeListener(_onActivityChanged);
      _geofenceService.addStreamErrorListener(_onError);
      _geofenceService.start(_geofenceList).catchError(_onError);
    });
  }

  Future<void> _requestPermissions() async {
    await SystemAlertWindow.requestPermissions(
        prefMode: SystemWindowPrefMode.OVERLAY);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // A widget used when you want to start a foreground task when trying to minimize or close the app.
      // Declare on top of the [Scaffold] widget.
      home: WillStartForegroundTask(
        onWillStart: () async {
          // You can add a foreground task start condition.
          return _geofenceService.isRunningService;
        },
        androidNotificationOptions: AndroidNotificationOptions(
          channelId: 'geofence_service_notification_channel',
          channelName: 'Geofence Service Notification',
          channelDescription:
              'This notification appears when the geofence service is running in the background.',
          channelImportance: NotificationChannelImportance.LOW,
          priority: NotificationPriority.LOW,
          isSticky: false,
        ),
        iosNotificationOptions: const IOSNotificationOptions(),
        foregroundTaskOptions: const ForegroundTaskOptions(),
        notificationTitle: 'Geofence Service is running',
        notificationText: 'Tap to return to the app',
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Geofence Service'),
            centerTitle: true,
          ),
          body: _buildContentView(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _activityStreamController.close();
    _geofenceStreamController.close();
    super.dispose();
  }

  Widget _buildContentView() {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(8.0),
      children: [
        _buildActivityMonitor(),
        const SizedBox(height: 20.0),
        _buildGeofenceMonitor(),
      ],
    );
  }

  Widget _buildActivityMonitor() {
    return StreamBuilder<Activity>(
      stream: _activityStreamController.stream,
      builder: (context, snapshot) {
        final updatedDateTime = DateTime.now();
        final content = snapshot.data?.toJson().toString() ?? '';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('•\t\tActivity (updated: $updatedDateTime)'),
            const SizedBox(height: 10.0),
            Text(
              content,
              style: const TextStyle(color: Colors.amber),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGeofenceMonitor() {
    return StreamBuilder<Geofence>(
      stream: _geofenceStreamController.stream,
      builder: (context, snapshot) {
        final updatedDateTime = DateTime.now();
        final content = snapshot.data?.toJson().toString() ?? '';
        var value = snapshot.data?.toJson();
        print("value =$value");
        final message = '${value?['id']},${value?['id']},${value?['id']}';

        print('SystemAlertWindow opened');
        SystemAlertWindow.showSystemWindow(
          height: MediaQuery.sizeOf(context).height.toInt(),
          width: MediaQuery.of(context).size.width.floor(),
          gravity: SystemWindowGravity.CENTER,
          prefMode: SystemWindowPrefMode.OVERLAY,
        );
        SystemAlertWindow.sendMessageToOverlay(message);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('•\t\tGeofence (updated: $updatedDateTime)'),
            const SizedBox(height: 10.0),
            Text(
              content,
              style: const TextStyle(color: Colors.amber),
            ),
          ],
        );
      },
    );
  }
}
