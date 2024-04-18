import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:flutter/material.dart';
import 'package:system_alert_window/system_alert_window.dart';

class CustomOverlay extends StatefulWidget {
  // final PocLatLongs targetLocation;

  const CustomOverlay({
    Key? key,
    // required this.targetLocation,
  }) : super(key: key);
  @override
  State<CustomOverlay> createState() => _CustomOverlayState();
}

class _CustomOverlayState extends State<CustomOverlay> {
  static const String _mainAppPort = 'foreground_port';
  SendPort? mainAppPort;
  bool update = false;
  String location = '';
  String pocName = '';
  String number = '';
  @override
  void initState() {
    IsolateNameServer.lookupPortByName(
      _mainAppPort,
    )?.send('this is the message');

    // TODO: implement initState
    super.initState();

    // sendPort = IsolateManager.lookupPortByName();
    SystemAlertWindow.overlayListener.listen((event) {
      log("overlayListener = $event in overlay ");
      // if (event is bool) {
      //   setState(() {
      //     update = event;
      //   });
      // }
      if (event is String) {
        setState(() {
          pocName = event.split(',')[1];
          location = event.split(',').first;
          number = event.split(',').last;
        });
      }
    });
  }

  Future<void> callBackFunction(String tag) async {
    mainAppPort ??= IsolateNameServer.lookupPortByName(
      _mainAppPort,
    );
    if (tag == 'call') {
      // await callBackFunction('yes');
      // mainAppPort?.send({
      //   'tag': tag,
      //   'data': number,
      // });
    } else if (tag == 'notNow') {
      // mainAppPort?.send({
      //   'tag': tag,
      // });
      callBackFunction('close');
    } else if (tag == 'close') {
      await SystemAlertWindow.closeSystemWindow(prefMode: prefMode);
    } else if (tag == 'yes') {
      // mainAppPort?.send({
      //   'tag': tag,
      // });
      await LaunchApp.openApp(
              androidPackageName: 'com.pravera.geofence_service_example')
          .then((value) => callBackFunction('close'));
    }
  }

  Widget overlay() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            height: MediaQuery.of(context).size.height,
          ),
          Center(
            child: Container(
              width: 327,
              height: 296,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.black12,
                  width: .5,
                ),
                borderRadius: BorderRadius.circular(
                  20,
                ),
              ),
              child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    )),
                height: 145,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    locationDetailsHearderWidget(),
                    locationDetailsBodyWidget(),
                    Expanded(
                      child: locationDetailsActionsButtons(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child:
                      // Container(
                      //   height: 200,
                      //   width: 200,
                      //   child: SvgPicture.asset(
                      //     'assets/images/salesgo.svg',
                      //     fit: BoxFit.fill,
                      //     color: Colors.amber,
                      //   ),
                      // ),

                      Container(
                    decoration: const BoxDecoration(
                        // image: DecorationImage(
                        //     image: AssetImage('assets/images/salesgo.png'),
                        //     fit: BoxFit.fill,
                        //     filterQuality: FilterQuality.high),
                        ),
                    height: 34,
                    width: 112,
                  ),
                ),
                const SizedBox(
                  height: 40,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Row locationDetailsActionsButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(.1),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    // color: Colors.blue.withOpacity(.1),
                    width: 240,
                    child: SizedBox(
                      height: 50,
                      child: Row(
                        children: [
                          SalesGoBtn(
                            btnTitle: 'Not now',
                            btnMinWidth: 90,
                            colorFilled: false,
                            onTap: () async {
                              await callBackFunction("notNow");
                            },
                          ),
                          Expanded(child: Container()),
                          SalesGoBtn(
                            btnTitle: 'Yes',
                            btnMinWidth: 96,
                            onTap: () async {
                              await callBackFunction("yes");
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Container locationDetailsBodyWidget() {
    return Container(
      // color: Colors.white,
      color: Colors.blue.withOpacity(.1),
      child: const Column(
        children: [
          SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Want to add conveyance?',
                style: TextStyle(
                  fontFamily: "Mulish",
                  // color: context.colors.textMain,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 34),
        ],
      ),
    );
  }

  Container locationDetailsHearderWidget() {
    return Container(
      height: 145,
      // color: Colors.blue.withOpacity(.1),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 20,
              bottom: 14,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  // color: context.colors.main,
                  size: 14,
                ),
                const SizedBox(
                  width: 8,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'You have reached at:',
                      style: TextStyle(
                        fontFamily: "Mulish",
                        color: Colors.black,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      // height: 32,
                      width: 224,
                      child: Text(
                        location,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: "Mulish",
                          // color: context.colors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                    iconSize: 14,
                    padding: EdgeInsets.zero,
                    onPressed: () async {
                      await callBackFunction("close");
                    },
                    icon: const Icon(
                      Icons.close,
                      size: 14,
                    )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
            ),
            child: SizedBox(
              width: 267,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // if (pocName.isNotNullOrEmpty)
                      Text(
                        pocName,
                        style: const TextStyle(
                          fontFamily: "Mulish",
                          // color: context.colors.textMain,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // if (number.isNotNullOrEmpty)
                      Text(
                        number,
                        style: const TextStyle(
                          fontFamily: "Mulish",
                          // color: context.colors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  // if (number.isNotNullOrEmpty) ...[
                  const Spacer(),
                  IconButton(
                    onPressed: () async {
                      await callBackFunction('call');
                    },
                    icon: const Icon(
                      Icons.local_phone_outlined,
                      size: 18,
                    ),
                  ),
                  // ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  SystemWindowPrefMode prefMode = SystemWindowPrefMode.OVERLAY;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: overlay(),
    );
  }

  Widget SalesGoBtn(
      {final VoidCallback? onTap,
      final String? btnTitle,
      final double? btnMinWidth,
      bool? colorFilled}) {
    return Container(
      child: TextButton(
        onPressed: onTap,
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (colorFilled == false) {
                  return Colors.transparent;
                  //#0E4C8A
                }
                return const Color(0xFF0E4C8A);
                // Use the component's default.
              },
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ))),
        child: Container(
          constraints: BoxConstraints(minWidth: btnMinWidth ?? 136),
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Text(
            btnTitle ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: "Mulish",
              color:
                  colorFilled == false ? const Color(0xFF0E4C8A) : Colors.white,
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}
