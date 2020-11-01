import 'dart:async';
// import 'dart:html';
import 'dart:ui';

import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:background_locator/settings/android_settings.dart';
import 'package:background_locator/settings/ios_settings.dart';
import 'package:background_locator/settings/locator_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pickndell/common/error_page.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/common/helper.dart';
import 'package:pickndell/home/prominent_disclosure.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/location/geo_helpers.dart';
import 'package:pickndell/location/location_callback_handler.dart';
import 'package:pickndell/location/location_service_repository.dart';
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
import 'package:pickndell/ui/progress_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:smooth_star_rating/smooth_star_rating.dart';

import '../dao/user_dao.dart';
import '../model/user_model.dart';
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

  // Account level limits
  int _rookieLevelLimit;
  int _advancedLevelLimit;
  int _expertLevelLimit;

  // Tracking location disclosure
  bool disclosure;

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
    final trans = ExampleLocalizations.of(context);
    if (_updatingProfile) {
      String loaderText = trans.loading_account + "...";
      return ColoredProgressDemo(loaderText);
    } else {
      return FutureBuilder(
        future: UserDao().getUser(0),
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          // prominentDisclosure();
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
    // final trans = ExampleLocalizations.of(context);

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
      print('DASHBOARD PROFILE DATA: ${_getProfileResponse}');
    } catch (e) {
      print('ERROR >> DHASBOARD: Failed to update profile. ERROR: $e');
      return Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ErrorPage(
              errorMessage: 'Server Communication Error',
            );
          },
        ),
        (Route<dynamic> route) => false, // No Back option for this page
      );
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

      // await localStorage.getString('userCountry');

      await localStorage.setString('country', _country);

      await localStorage.setDouble('usdIls', _currentUser.usdIls);
      await localStorage.setDouble('usdEur', _currentUser.usdEur);

      // Setting the current account levels
      await localStorage.setInt(
          'rookieLevel', _getProfileResponse["account_level_rookie"]);

      await localStorage.setInt(
          'advancedLevel', _getProfileResponse["account_level_advanced"]);
      await localStorage.setInt(
          'expertLevel', _getProfileResponse["account_level_expert"]);

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
    _checkProfile();
    super.initState();

    getCountryName();
    if (_emailCodeVerification) {}

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

    // disclosure = localStorage.getBool('disclosure');
    // if (disclosure == null || disclosure == false) {
    disclosure = await prominentDisclosure(context);
    // localStorage.setBool('disclosure', disclosure);
    // } else if (disclosure) {
    if (disclosure) {
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
    } else {
      print('DECLINED');
    }
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
    BackgroundLocator.registerLocationUpdate(LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        initDataCallback: data,
/*
        Comment initDataCallback, so service not set init variable,
        variable stay with value of last run after unRegisterLocationUpdate
 */
        disposeCallback: LocationCallbackHandler.disposeCallback,
        iosSettings: IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION, distanceFilter: 0),
        autoStop: false,
        androidSettings: AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            interval: 5,
            distanceFilter: 10,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'PickNdell',
                notificationTitle: 'You are currently available',
                notificationMsg: 'Senders are able to share orders with you',
                // notificationBigMsg:
                //     'Background location is on to keep the app up-tp-date with your location. This is required for main features to work properly when the app is not running.',
                notificationIcon: 'assets/images/pickndell-logotype-white.png',
                notificationIconColor: Colors.grey,
                notificationTapCallback:
                    LocationCallbackHandler.notificationCallback)));
  }

  Widget getDashboard(User currentUser) {
    final translations = ExampleLocalizations.of(context);
    return SafeArea(
      child: Scaffold(
        // appBar: AppBar(
        //   title: Text(translations.main),
        // ),
        // drawer: MainMenu(),
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                /////////////// Push notification widget //////////
                ///
                MessagingWidget(),

                /////////////// Header //////////
                ///
                Padding(padding: EdgeInsets.only(top: 20)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    // Spacer(
                    //   flex: 1,
                    // ),
                    Image.asset(
                      'assets/images/pickndell-logo-white.png',
                      width: MediaQuery.of(context).size.width * 0.40,
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                ),
                (currentUser.isEmployee == 1)
                    ? Text(
                        translations.courier_account,
                        style: whiteTitle,
                      )
                    : Text(translations.sender_account, style: whiteTitle),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    /////////////////// Account Username //////////////
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 30.0, top: 10.0),
                        ),
                        Text(
                          translations.usernmane + ":",
                          style: intrayTitleStyle,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                        ),
                        Text(
                          currentUser.username,
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),

                    /////////////////// Account Status //////////////
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 30.0, top: 10.0),
                        ),
                        Text(
                          translations.account_status + ":",
                          style: intrayTitleStyle,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                        ),
                        (currentUser.isApproved == 1)
                            ? Text(
                                translations.active,
                                style: greenApproved,
                              )
                            : (currentUser.profilePending == 1)
                                ? Text(
                                    translations.pending_approval,
                                    style: TextStyle(
                                        backgroundColor: Colors.orange),
                                  )
                                : Text(
                                    translations.profile_not_complete,
                                    style:
                                        TextStyle(backgroundColor: Colors.red),
                                  ),
                      ],
                    ),

                    /////////////////// Acount Level //////////////
                    Padding(
                      padding: EdgeInsets.only(top: 20.0),
                    ),

                    if (currentUser.isEmployee == 1)
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 30.0, top: 10.0),
                          ),
                          Text(
                            translations.your_level + ":",
                            style: intrayTitleStyle,
                          ),
                          Padding(
                            padding: EdgeInsets.only(right: 10.0),
                          ),
                          currentUser.accountLevel == 'Rookie'
                              ? Text(translations.rookie)
                              : currentUser.accountLevel == 'Advanced'
                                  ? Text(translations.advanced)
                                  : Text(translations.expert),
                          Padding(padding: EdgeInsets.only(right: 5.0)),
                          QuestionTooltip(
                            tooltipMessage:
                                "${translations.level_tooltip}: \n ${translations.messages_please_check_pickndell_website}",
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

                        //////////// Courier/Sender star ratings: ////////
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
                              currentUser.isEmployee == 1
                                  ? translations.daily_earnings + ":"
                                  : translations.daily_cost + ":",
                              style: whiteTitleH4,
                            ),
                            Padding(padding: EdgeInsets.only(right: 10)),
                            _country == 'Israel' || _country == 'ישראל'
                                ? Text(
                                    currentUser.isEmployee == 1
                                        ? ': ${roundDouble(currentUser.dailyProfit * currentUser.usdIls, 2)} ₪'
                                        : ': ${roundDouble(currentUser.dailyCost * currentUser.usdIls, 2)} ₪',
                                    style: whiteTitleH2,
                                  )
                                : Text(
                                    currentUser.isEmployee == 1
                                        ? ' \$ ${roundDouble(currentUser.dailyProfit, 2)}'
                                        : ' \$ ${roundDouble(currentUser.dailyCost, 2)}',
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
                                            user: currentUser,
                                            country: _country,
                                            title: translations
                                                .your_account_not_approved_yet,
                                            content: (currentUser
                                                        .profilePending ==
                                                    1)
                                                ? translations
                                                    .your_account_reviewed
                                                : translations.complete_profile,
                                            nameRoute:
                                                currentUser.profilePending == 1
                                                    ? null
                                                    : 'profile',
                                            buttonText:
                                                translations.got_to_profile,
                                            okButtontext: translations.close,
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
                              Spacer(
                                flex: 3,
                              ),
                              // Padding(
                              //   padding: EdgeInsets.only(left: 30.0, top: 20.0),
                              // ),
                              RaisedButton(
                                child: Text(
                                  translations.new_order,
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.white),
                                ),
                                padding: EdgeInsets.all(15),
                                color: pickndellGreen,
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
                                                country: _country,
                                              )),
                                    );
                                  } else {
                                    showAlertDialog(
                                        context: context,
                                        user: currentUser,
                                        country: _country,
                                        title: translations
                                            .your_account_not_approved_yet,
                                        content: translations.complete_profile,
                                        nameRoute: 'profile',
                                        buttonText: translations.got_to_profile,
                                        okButtontext: translations.close);
                                  }
                                },
                              ),
                              Spacer(
                                flex: 1,
                              ),
                            ],
                          )
                        : Row(),

                    Padding(padding: EdgeInsets.only(top: 20)),
                    /////////////////// Profile Edit Button //////////
                    ///
                    // Row(
                    //   children: [
                    //     Padding(
                    //       padding: EdgeInsets.only(left: 30),
                    //     ),
                    //     FlatButton(
                    //       child: Text(translations.edit_profile),
                    //       shape: RoundedRectangleBorder(
                    //           side: BorderSide(
                    //               color: pickndellGreen,
                    //               width: 2,
                    //               style: BorderStyle.solid),
                    //           borderRadius: BorderRadius.circular(50)),
                    //       onPressed: () {
                    //         Navigator.push(
                    //           context,
                    //           MaterialPageRoute(
                    //               builder: (context) => ProfilePage(
                    //                     user: currentUser,
                    //                   )),
                    //         );
                    //       },
                    //     ),
                    //   ],
                    // ),
                    Divider(
                      thickness: 2,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          right: RIGHT_MARGINE, left: LEFT_MARGINE),
                      child: Row(
                        children: <Widget>[
                          Text("${translations.long_press_on} "),
                          FaIcon(
                            FontAwesomeIcons.questionCircle,
                            // size: 25,
                          ),
                          Text(' ${translations.for_more_info}'),
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
