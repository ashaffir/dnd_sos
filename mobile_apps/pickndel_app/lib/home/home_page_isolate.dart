import 'dart:async';
import 'dart:ui';
import 'dart:convert';

import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:background_locator/location_settings.dart';
import 'package:bloc_login/common/global.dart';
import 'package:bloc_login/location/location_callback_handler.dart';
import 'package:bloc_login/location/location_service_repository.dart';
import 'package:bloc_login/model/user_location.dart';
import 'package:bloc_login/networking/message_testing.dart';
import 'package:bloc_login/networking/messaging_widget.dart';
import 'package:bloc_login/repository/location_repository.dart';
import 'package:bloc_login/repository/user_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../dao/user_dao.dart';
import '../model/user_model.dart';
import '../ui/bottom_nav_bar.dart';
import 'dart:isolate';

class HomePageIsolate extends StatefulWidget {
  final UserRepository userRepository;

  HomePageIsolate({this.userRepository});

  @override
  _HomePageIsolateState createState() => _HomePageIsolateState();
}

class _HomePageIsolateState extends State<HomePageIsolate> {
  ReceivePort port = ReceivePort();
  String logStr = '';
  bool isRunning;
  bool isTracking = false;
  bool isTrackinggg = false;
  LocationDto lastLocation;
  DateTime lastTimeLocation;

// User related
  var userData;
  bool isEmployee;

  void _getUserInfo() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    var userJson = localStorage.getString('user');
    var user = json.decode(userJson);
    setState(() {
      userData = user;
    });
  }

  // Push notifications
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String notificationTitle;
  String notificationHelper;

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: UserDao().getUser(0),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.hasData) {
          return getHomePageIsolate(snapshot.data);
        } else {
          print("No data");
        }
        return CircularProgressIndicator();
      },
    );
  }

  @override
  void initState() {
    super.initState();

    /////////////// Push Notifications ///////////////
    // _firebaseMessaging.configure(onMessage: (message) async {
    //   setState(() {
    //     print('$message');
    //     notificationTitle = message['notification']['title'];
    //     notificationHelper = 'You have a new notification!';
    //   });
    // }, onResume: (message) async {
    //   setState(() {
    //     notificationTitle = message['data']['title'];
    //     notificationHelper = 'You have a background notification!';
    //   });
    // });

    /////////////// Device location tracking ///////////////

    if (IsolateNameServer.lookupPortByName(
            LocationServiceRepository.isolateName) !=
        null) {
      IsolateNameServer.removePortNameMapping(
          LocationServiceRepository.isolateName);
    }

    IsolateNameServer.registerPortWithName(
        port.sendPort, LocationServiceRepository.isolateName);

    port.listen(
      (dynamic data) async {
        await updateUI(data);
      },
    );
    initPlatformState();
  }

  Future<void> initPlatformState() async {
    print('Initializing...');
    await BackgroundLocator.initialize();
    // logStr = await FileManager.readLogFile();
    print('Initialization done');
    final _isRunning = await BackgroundLocator.isRegisterLocationUpdate();
    setState(() {
      isRunning = _isRunning;
    });
    print('Running ${isRunning.toString()}');
  }

  Future<void> updateUI(LocationDto data) async {
    // final log = await FileManager.readLogFile();
    User currentUser = await UserDao().getUser(0);
    UserLocation userLocation = UserLocation();
    LocationRepository updateLocation = LocationRepository();

    if (data != null) {
      userLocation.latitude = data.latitude;
      userLocation.longitude = data.longitude;
      await updateLocation.updateUserLocation(userLocation);
    }

    setState(() {
      if (data != null) {
        lastLocation = data;
        lastTimeLocation = DateTime.now();
        print('-------User: ${currentUser.userId}  $data ---------');
      }
      // logStr = log;
    });
  }

  Future<bool> _checkLocationPermission() async {
    final access = await LocationPermissions().checkPermissionStatus();
    switch (access) {
      case PermissionStatus.unknown:
      case PermissionStatus.denied:
      case PermissionStatus.restricted:
        final permission = await LocationPermissions().requestPermissions(
          permissionLevel: LocationPermissionLevel.locationAlways,
        );
        if (permission == PermissionStatus.granted) {
          return true;
        } else {
          return false;
        }
        break;
      case PermissionStatus.granted:
        return true;
        break;
      default:
        return false;
        break;
    }
  }

  void _toggleTracking() {
    if (isTracking == false) {
      setState(() {
        isTracking = true;
        _onStart();
      });
    } else if (isTracking) {
      setState(() {
        isTracking = false;
        onStop();
      });
    }
  }

  void _onStart() async {
    if (await _checkLocationPermission()) {
      print('GOT PERMISSIONS!!');
      _startLocator();
      setState(() {
        isRunning = true;
        lastTimeLocation = null;
        lastLocation = null;

        print('isRunning: $isRunning');
      });
    } else {
      // show error
    }
  }

  void onStop() {
    BackgroundLocator.unRegisterLocationUpdate();
    setState(() {
      isRunning = false;
      //  lastTimeLocation = null;
//      lastLocation = null;
    });
  }

  void _startLocator() {
    Map<String, dynamic> data = {'countInit': 1};
    BackgroundLocator.registerLocationUpdate(
      LocationCallbackHandler.callback,
      initCallback: LocationCallbackHandler.initCallback,
      initDataCallback: data,
/*
        Comment initDataCallback, so service not set init variable,
        variable stay with value of last run after unRegisterLocationUpdate
 */
      disposeCallback: LocationCallbackHandler.disposeCallback,
      androidNotificationCallback: LocationCallbackHandler.notificationCallback,
      settings: LocationSettings(
          notificationChannelName: "PickNdell",
          notificationTitle: "You are currently available.",
          notificationMsg: "Businesses are able to share orders with you.",
          notificationIcon: "assets/images/pickndell-logotype-white.png",
          wakeLockTime: 20,
          autoStop: false,
          distanceFilter: 10,
          interval: 5),
    );
  }

  Widget getHomePageIsolate(User currentUser) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              MessagingWidget(),
              // MessagingWidgetTest(),
              Image.asset(
                'assets/images/pickndell-logo-white.png',
                width: MediaQuery.of(context).size.width * 0.70,
                // height: MediaQuery.of(context).size.height * 0.50,
                // width: 300,
              ),
              Padding(
                padding: EdgeInsets.only(top: 30.0),
              ),
              Text(
                currentUser.isEmployee == 1
                    ? "Carrier Profile"
                    : "Business Profile",
                style: whiteTitle,
              ),
              Padding(
                padding: EdgeInsets.only(top: 30.0),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 20.0),
                      ),
                      Text(
                        currentUser.isEmployee == 1
                            ? 'User Name: '
                            : 'Business:',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 10.0),
                      ),
                      Text(
                        currentUser.isEmployee == 1
                            ? '${currentUser.name}'
                            : '${currentUser.businessName}',
                        style: TextStyle(
                          fontSize: 20.0,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.0),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 20.0),
                      ),
                      Text(
                        currentUser.isEmployee == 1
                            ? 'Registered Vehicle:'
                            : 'Type:',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 10.0),
                      ),
                      Text(
                        currentUser.isEmployee == 1
                            ? '${currentUser.vehicle}'
                            : '${currentUser.businessCategory}',
                        style: TextStyle(fontSize: 20.0),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 20.0),
                  ),
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 20.0),
                      ),
                      Text(
                        'Current Active Orders:',
                        style: TextStyle(fontSize: 20.0),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 10.0),
                      ),
                      Text(
                        currentUser.isEmployee == 1
                            ? currentUser.activeOrders != null
                                ? '${currentUser.activeOrders}'
                                : '0'
                            : currentUser.numOrdersInProgress != null
                                ? '${currentUser.numOrdersInProgress}'
                                : '0',
                        style: TextStyle(fontSize: 20.0),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 30.0, top: 20.0),
                  ),
                  // Text('Alert: $notificationHelper'),
                  // Padding(
                  //   padding: EdgeInsets.only(left: 30.0, top: 10.0),
                  // ),
                  // Text('Conent: $notificationTitle'),
                  // Padding(
                  //   padding: EdgeInsets.only(left: 30.0, top: 20.0),
                  // ),
                  currentUser.isEmployee == 1
                      ? Row(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 30.0, top: 20.0),
                            ),
                            Text(
                              'Availability Status:',
                              style: TextStyle(fontSize: 20.0),
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 20.0),
                            ),
                            Column(
                              children: [
                                Transform.scale(
                                  scale: 2.0,
                                  child: Switch(
                                    value: isTracking,
                                    onChanged: (value) {
                                      setState(() {
                                        _toggleTracking();
                                      });
                                    },
                                    activeTrackColor: Colors.lightGreenAccent,
                                    activeColor: Colors.green,
                                    inactiveTrackColor: Colors.red[400],
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(top: 20.0),
                                ),
                                Text(isTracking ? "Available" : "Unavailable"),
                              ],
                            ),
                          ],
                        )
                      : Row(),
                ], //Children
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(34.0, 20.0, 0.0, 0.0),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        userRepository: widget.userRepository,
      ),
      // resizeToAvoidBottomPadding: false,
    );
  }
}
