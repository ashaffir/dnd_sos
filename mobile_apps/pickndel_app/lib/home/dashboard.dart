import 'dart:async';
// import 'dart:html';
import 'dart:ui';
import 'dart:convert';

import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:background_locator/location_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/common/helper.dart';
import 'package:pickndell/home/profile.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/location/geo_helpers.dart';
import 'package:pickndell/location/location_callback_handler.dart';
import 'package:pickndell/location/location_service_repository.dart';
import 'package:pickndell/networking/CustomException.dart';
import 'package:pickndell/orders/new_order.dart';
import 'package:pickndell/model/user_location.dart';
import 'package:pickndell/networking/messaging_widget.dart';
import 'package:pickndell/repository/location_repository.dart';
import 'package:pickndell/repository/user_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pickndell/api_connection/api_connection.dart';
import 'package:flutter/material.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:pickndell/ui/bottom_navigation_bar.dart';
import 'package:pickndell/ui/buttons.dart';
import 'package:pickndell/ui/exception_page.dart';
import 'package:pickndell/ui/progress_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:http/http.dart' as http;
import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../dao/user_dao.dart';
import '../model/user_model.dart';
import '../ui/bottom_nav_bar.dart';
import 'dart:isolate';

class Dashboard extends StatefulWidget {
  final UserRepository userRepository;

  Dashboard({this.userRepository});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  ReceivePort port = ReceivePort();
  String logStr = '';
  bool isRunning;
  bool isTracking = false;
  // LocationDto lastLocation;
  DateTime lastTimeLocation;

// User related
  var userData;
  bool isEmployee;

  // void _getUserInfo() async {
  //   SharedPreferences localStorage = await SharedPreferences.getInstance();
  //   var userJson = localStorage.getString('user');
  //   var user = json.decode(userJson);
  //   setState(() {
  //     userData = user;
  //   });
  // }

  // Push notifications
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String notificationTitle;
  String notificationHelper;
  bool _updatingProfile;
  bool _emailCodeVerification = false;

  Widget build(BuildContext context) {
    if (_updatingProfile) {
      String loaderText = "Loading Account...";
      return ColoredProgressDemo(loaderText);
    } else {
      return FutureBuilder(
        future: UserDao().getUser(0),
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          if (snapshot.hasData) {
            return getDashboard(snapshot.data);
          } else {
            print("No data");
          }
          return CircularProgressIndicator();
        },
      );
    }
  }

  String _country;

  Future _checkProfile() async {
    setState(() {
      _updatingProfile = true;
    });
    User _currentUser = await UserDao().getUser(0);
    // print('DASHBOARD PROFILE >>>>>: ${_currentUser.usdIls}');

    var _getProfileResponse;
    // print('DASHBOARD PROFILE: $_getProfileResponse');

    // Get user information from the server
    try {
      _getProfileResponse = await getProfile(user: _currentUser);
      print('DASHBOARD PROFILE: ${_getProfileResponse["bank_details"]}');
    } catch (e) {
      print('ERROR >> DHASBOARD: Failed to update profile. ERROR: $e');
    }

    // Update local DB with user info
    try {
      await rowUpdate(user: _currentUser, data: _getProfileResponse);
    } catch (e) {
      print('ERROR >> DHASBOARD: Failed to update DB. ERROR: $e');
    }

    try {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      _country = await getCountryName();
      await localStorage.setString('country', _country);

      await localStorage.setDouble('usdIls', _currentUser.usdIls);
      await localStorage.setDouble('usdEur', _currentUser.usdEur);
      print('>>> COUNTRY: $_country');
      print('>>> USD-ILS: ${_currentUser.usdIls}');
      print('>>> USD-EUR: ${_currentUser.usdEur}');
    } catch (e) {
      print('Error: updating user country');
    }

    setState(() {
      _updatingProfile = false;
    });

    return _getProfileResponse;
  }

  @override
  void initState() {
    super.initState();

    getCountryName();
    if (_emailCodeVerification) {}

    _checkProfile();

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
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    print('Initializing...');
    await BackgroundLocator.initialize();
    // logStr = await FileManager.readLogFile();
    print('Initialization done');
    final _isRunning = await BackgroundLocator.isRegisterLocationUpdate();
    setState(() {
      isRunning = _isRunning;
    });
    print('Running ${isRunning.toString()}');
    await localStorage.setBool('locationTracking', isRunning);
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

  void _onStart() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    LocationRepository updateAvailability = LocationRepository();
    if (await _checkLocationPermission()) {
      print('GOT PERMISSIONS!!');
      _startLocator();
      setState(() {
        isRunning = true;
        lastTimeLocation = null;
        // lastLocation = null;

        print('isRunning: $isRunning');
      });
    } else {
      // show error
    }
    await localStorage.setBool('locationTracking', isRunning);
    await updateAvailability.updateAvailability(isRunning);
  }

  void onStop() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    LocationRepository updateAvailability = LocationRepository();
    BackgroundLocator.unRegisterLocationUpdate();
    setState(() {
      isRunning = false;
      //  lastTimeLocation = null;
//      lastLocation = null;
    });
    await localStorage.setBool('locationTracking', isRunning);
    await updateAvailability.updateAvailability(isRunning);
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
          notificationMsg: "Senders are able to share orders with you.",
          notificationIcon: "assets/images/pickndell-logotype-white.png",
          wakeLockTime: 20,
          autoStop: false,
          distanceFilter: 10,
          interval: 5),
    );
  }

  Widget getDashboard(User currentUser) {
    final translations = ExampleLocalizations.of(context);
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   title: (currentUser.isApproved == 1)
        //       ? Text('Dashboard')
        //       : (currentUser.profilePending == 1)
        //           ? Text(translations.home_title + ' (Pending Approval)')
        //           : Text(translations.home_title + ' (Not Complete)'),
        // ),
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                /////////////// Push notification widget //////////
                ///
                MessagingWidget(),
                Padding(padding: EdgeInsets.only(top: 20)),
                Image.asset(
                  'assets/images/pickndell-logo-white.png',
                  width: MediaQuery.of(context).size.width * 0.40,
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                ),
                (currentUser.isEmployee == 1)
                    ? Text(
                        'Courier Account',
                        style: whiteTitle,
                      )
                    : Text('Sender Account', style: whiteTitle),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    /////////////////// Acount Status //////////////
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 30.0, top: 10.0),
                        ),
                        Text(
                          "Account Status" + ":",
                          style: intrayTitleStyle,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                        ),
                        (currentUser.isApproved == 1)
                            ? Text(
                                "Active",
                                style: greenApproved,
                              )
                            : (currentUser.profilePending == 1)
                                ? Text(
                                    '(Pending Approval)',
                                    style: TextStyle(
                                        backgroundColor: Colors.orange),
                                  )
                                : Text(
                                    'Profile Not Complete',
                                    style:
                                        TextStyle(backgroundColor: Colors.red),
                                  ),
                      ],
                    ),

                    /////////////////// Acount Level //////////////
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 30.0, top: 10.0),
                        ),
                        Text(
                          "Your PickNdell Level" + ":",
                          style: intrayTitleStyle,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                        ),
                        Text("${currentUser.accountLevel}"),
                        Padding(padding: EdgeInsets.only(right: 5.0)),
                        QuestionTooltip(
                          tooltipMessage:
                              "The level of the account defines the number of concurrent deliveries you are entitled to do \n Rookie - 1 \n Advanced - 10 \n Expert - Unlimited",
                        ),
                      ],
                    ),
                    //////////////// User Rating  ///////////////
                    ////////////
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                    ),

                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 30.0, top: 20.0),
                        ),
                        Text(
                          currentUser.isEmployee == 1
                              ? currentUser.rating != null &&
                                      currentUser.rating != 0.0
                                  ? translations.home_courier_rating +
                                      ": ${currentUser.rating}"
                                  : translations.home_courier_rating +
                                      ": " +
                                      translations.home_unrated
                              : currentUser.rating != null &&
                                      currentUser.rating != null
                                  ? translations.home_sender_rating +
                                      ": ${currentUser.rating}"
                                  : translations.home_sender_rating +
                                      ": " +
                                      translations.home_unrated,
                          style: intrayTitleStyle,
                        ),
                        Padding(padding: EdgeInsets.only(right: 10)),

                        //////////// Courier star ratings: ////////
                        SmoothStarRating(
                            rating: currentUser.rating != null
                                ? currentUser.rating
                                : 0,
                            isReadOnly: true,
                            size: 20,
                            filledIconData: Icons.star,
                            halfFilledIconData: Icons.star_half,
                            defaultIconData: Icons.star_border,
                            borderColor: Colors.white24,
                            starCount: 5,
                            allowHalfRating: true,
                            color: Colors.yellow,
                            spacing: 0.0),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                    ),
                    //////////////// Active Orders  ///////////////
                    ////////////
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 30.0, top: 10.0),
                        ),
                        Text(
                          translations.home_active_orders + ":",
                          style: intrayTitleStyle,
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
                          style: userContentStyle,
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                    Divider(color: Colors.white),
                    SizedBox(
                      height: 40,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            right: RIGHT_MARGINE, left: LEFT_MARGINE),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Daily Earnings',
                              style: whiteTitleH4,
                            ),
                            Padding(padding: EdgeInsets.only(right: 10)),
                            _country == 'Israel'
                                ? Text(
                                    // 'GAGAGA)',
                                    ' ₪ ${roundDouble(currentUser.dailyProfit * currentUser.usdIls, 2)}',
                                    style: whiteTitleH2,
                                  )
                                : Text(
                                    '\$ ${roundDouble(currentUser.dailyProfit, 2)}',
                                    style: whiteTitleH2,
                                  ),
                          ],
                        ),
                      ),
                    ),

                    Divider(color: Colors.white),
                    Padding(
                      padding: EdgeInsets.only(left: 30.0, top: 20.0),
                    ),
                    //////////////// Available Switch ////////////
                    ///
                    currentUser.isEmployee == 1
                        ? Row(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 30.0, top: 20.0),
                              ),
                              Text(
                                translations.home_status,
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
                                      value: isRunning,
                                      onChanged: (running) {
                                        // Check account approved first
                                        if (currentUser.isApproved == 1) {
                                          if (running) {
                                            _onStart();
                                          } else if (!running) {
                                            onStop();
                                          }
                                        } else {
                                          showAlertDialog(
                                            context: context,
                                            title:
                                                'Your account is not approved yet',
                                            content: (currentUser
                                                        .profilePending ==
                                                    1)
                                                ? 'Your account is being reviewed. We will notify you once approved.'
                                                : 'Please complete your profile first.',
                                            nameRoute: '/profile',
                                            buttonText: 'Go to Profile',
                                            buttonColor: pickndellGreen,
                                            //     'https://pickndell.com/core/login'
                                          );
                                          print('NOT APPROVED');
                                        }
                                      },
                                      activeTrackColor: Colors.lightGreenAccent,
                                      activeColor: pickndellGreen,
                                      inactiveTrackColor: Colors.red[400],
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.only(top: 20.0),
                                  ),
                                  Text(isRunning
                                      ? translations.home_available
                                      : translations.home_unavailable),
                                ],
                              ),
                            ],
                          )
                        : Row(),
                    //////////////// New Order Button ////////////
                    ///
                    currentUser.isEmployee == 0
                        ? Row(
                            children: <Widget>[
                              Padding(
                                padding: EdgeInsets.only(left: 30.0, top: 20.0),
                              ),
                              FlatButton(
                                child: Text('Create a New Order'),
                                shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        color: pickndellGreen,
                                        width: 2,
                                        style: BorderStyle.solid),
                                    borderRadius: BorderRadius.circular(50)),
                                onPressed: () {
                                  if (currentUser.isApproved == 1) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => NewOrder(
                                                user: currentUser,
                                                userRepository:
                                                    widget.userRepository,
                                              )),
                                    );
                                  } else {
                                    showAlertDialog(
                                        context: context,
                                        title: 'Your account is not approved.',
                                        content:
                                            "Please complete your profile before ordering deliveries. \n Name, phone and credit card are mandatory.",
                                        nameRoute: '/profile',
                                        buttonText: 'Go to Profile');
                                  }
                                },
                              ),
                            ],
                          )
                        : Row(),

                    /////////////////// Profile Edit Button //////////
                    ///
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 30),
                        ),
                        FlatButton(
                          child: Text('Edit Profile'),
                          shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: pickndellGreen,
                                  width: 2,
                                  style: BorderStyle.solid),
                              borderRadius: BorderRadius.circular(50)),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfilePage(
                                        user: currentUser,
                                      )),
                            );
                          },
                        ),
                      ],
                    ),
                    Divider(
                      thickness: 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          right: RIGHT_MARGINE, left: LEFT_MARGINE),
                      child: Row(
                        children: <Widget>[
                          Text('Long press on '),
                          FaIcon(
                            FontAwesomeIcons.questionCircle,
                            // size: 25,
                          ),
                          Text(' for more information'),
                        ],
                      ),
                    ),
                  ], //Children
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigation(
          user: currentUser,
        ),

        // resizeToAvoidBottomPadding: false,
      ),
    );
  }
}
