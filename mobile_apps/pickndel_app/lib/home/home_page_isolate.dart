import 'dart:async';
import 'dart:ui';
import 'dart:convert';

import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:background_locator/location_settings.dart';
import 'package:pickndell/common/common.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/common/helper.dart';
import 'package:pickndell/home/profile.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/location/location_callback_handler.dart';
import 'package:pickndell/location/location_service_repository.dart';
import 'package:pickndell/login/profile_updated.dart';
import 'package:pickndell/model/user_location.dart';
import 'package:pickndell/networking/messaging_widget.dart';
import 'package:pickndell/orders/get_orders_page.dart';
import 'package:pickndell/repository/location_repository.dart';
import 'package:pickndell/repository/user_repository.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pickndell/api_connection/api_connection.dart';
import 'package:flutter/material.dart';
import 'package:location_permissions/location_permissions.dart';
import 'package:pickndell/ui/progress_indicator.dart';
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
  // LocationDto lastLocation;
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

  var _vehicleTypes = List<DropdownMenuItem>();
  String _vehicleType;
  List<String> _vehicleTypeList;

  _loadVehicleTypes() {
    _vehicleTypeList = ['Car', 'Scooter', 'Bicycle', 'Motorcycle', 'Other'];

    _vehicleTypeList.forEach((element) {
      setState(() {
        _vehicleTypes.add(DropdownMenuItem(
          child: Text(element),
          value: element,
        ));
      });
    });
  }

  var _businessCategories = List<DropdownMenuItem>();
  String _businessCategory;
  List<String> _businessCategoryList;

  _loadCategoriesTypes() {
    _businessCategoryList = [
      'Restaurant',
      'Cothing',
      'Convenience',
      'Grocery',
      'Office',
      'Other'
    ];

    _businessCategoryList.forEach((element) {
      setState(() {
        _businessCategories.add(DropdownMenuItem(
          child: Text(element),
          value: element,
        ));
      });
    });
  }

  // Push notifications
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String notificationTitle;
  String notificationHelper;
  bool _updatingProfile;
  bool _emailCodeVerification = false;

  Widget build(BuildContext context) {
    if (_updatingProfile) {
      String loaderText = "Loading Profile...";
      return ColoredProgressDemo(loaderText);
    } else {
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
  }

  Future _checkProfile() async {
    setState(() {
      _updatingProfile = true;
    });
    User _currentUser = await UserDao().getUser(0);
    var _getProfileResponse;
    _getProfileResponse = await getProfile(user: _currentUser);
    print('GET PROFILE: $_getProfileResponse');
    await rowUpdate(user: _currentUser, data: _getProfileResponse);
    setState(() {
      _updatingProfile = false;
    });

    return _getProfileResponse;
  }

  @override
  void initState() {
    super.initState();
    _loadVehicleTypes();
    _loadCategoriesTypes();

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

  Widget getHomePageIsolate(User currentUser) {
    final translations = ExampleLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(translations.home_title),
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
                width: MediaQuery.of(context).size.width * 0.40,
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
              ),
              Padding(
                padding: EdgeInsets.only(top: 10.0),
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
                        translations.home_name + ":",
                        style: TextStyle(fontSize: 20.0),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 10.0),
                      ),
                      Text(
                        currentUser.isEmployee == 1
                            ? currentUser.name != null
                                ? '${currentUser.name}'
                                : " "
                            : currentUser.businessName != null
                                ? '${currentUser.businessName}'
                                : " ",
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                      IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            updateProfile(
                                context: context, updateField: 'name');
                            print('EDIT NAME');
                          }),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 20.0),
                      ),
                      Text(
                        translations.home_phone + ":",
                        style: TextStyle(fontSize: 20.0),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 10.0),
                      ),
                      Text(
                        currentUser.phone != null
                            ? '${currentUser.phone}'
                            : " ",
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                      IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            updateProfile(
                                context: context, updateField: 'phone');
                            print('UPDATE PHONE');
                          }),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 20.0),
                      ),
                      Text(
                        translations.email + ":",
                        style: TextStyle(fontSize: 20.0),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 10.0),
                      ),
                      Text(
                        currentUser.username != null
                            ? '${currentUser.username}'
                            : " ",
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                      IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            updateProfile(
                                context: context, updateField: 'email');
                            print('EDIT EMAIL');
                          }),
                    ],
                  ),

                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 20.0),
                      ),
                      Text(
                        currentUser.isEmployee == 1
                            ? translations.home_vehicle + ":"
                            : translations.home_sender_cat + ":",
                        style: TextStyle(fontSize: 20.0),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 10.0),
                      ),
                      Text(
                        currentUser.isEmployee == 1
                            ? currentUser.vehicle != null
                                ? '${currentUser.vehicle}'
                                : " "
                            : currentUser.businessCategory != null
                                ? '${currentUser.businessCategory}'
                                : " ",
                        style: TextStyle(fontSize: 15.0),
                      ),
                      IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            updateProfile(
                                context: context,
                                updateField: currentUser.isEmployee == 1
                                    ? 'vehicle'
                                    : 'business category');
                            print('EDIT VEHICLE');
                          }),
                    ],
                  ),
                  Divider(color: Colors.white),
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
                            ? currentUser.rating != 0.0
                                ? translations.home_courier_rating +
                                    ": ${currentUser.rating}"
                                : translations.home_courier_rating +
                                    ": " +
                                    translations.home_unrated
                            : currentUser.rating != null
                                ? translations.home_sender_rating +
                                    ": ${currentUser.rating}"
                                : translations.home_sender_rating +
                                    ": " +
                                    translations.home_unrated,
                        style: TextStyle(fontSize: 15.0),
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
                        translations.home_active_orders + ":",
                        style: TextStyle(fontSize: 15.0),
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
                        style: TextStyle(fontSize: 15.0),
                      )
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 30.0, top: 20.0),
                  ),
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
                                        // setState(() {
                                        //   _toggleTracking();
                                        // });
                                      } else {
                                        showAlertDialog(
                                            context: context,
                                            title:
                                                'Your account is not approved yet',
                                            content:
                                                'Please complete your profile at https://pickndell.com',
                                            url:
                                                'https://pickndell.com/core/login');
                                        print('NOT APPROVED');
                                      }
                                    },
                                    activeTrackColor: Colors.lightGreenAccent,
                                    activeColor: Colors.green,
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
                  // Row(
                  //   children: <Widget>[
                  //     Padding(
                  //       padding: EdgeInsets.only(left: 30.0, top: 20.0),
                  //     ),
                  //     FlatButton(
                  //         shape: RoundedRectangleBorder(
                  //             side: BorderSide(
                  //                 color: Colors.blue,
                  //                 width: 1,
                  //                 style: BorderStyle.solid),
                  //             borderRadius: BorderRadius.circular(50)),
                  //         onPressed: () {
                  //           Navigator.pushAndRemoveUntil(
                  //               context,
                  //               MaterialPageRoute(
                  //                   builder: (context) => Profile()),
                  //               (Route<dynamic> route) => false);
                  //         },
                  //         child: Text('Edit Profile'))
                  //   ],
                  // )
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

  Future updateProfile({BuildContext context, String updateField}) async {
    User currentUser = await UserDao().getUser(0);
    TextEditingController _textInput = TextEditingController();
    // set up the AlertDialog
    Widget okButton = FlatButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change the  $updateField'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  updateField == 'business category'
                      ? DropdownButtonFormField(
                          decoration: InputDecoration(
                              labelText: 'Category' + ":",
                              prefixIcon: Icon(Icons.business)),
                          value: _businessCategory,
                          items: _businessCategories,
                          validator: (value) {
                            if (dropdownMenue(value) == null) {
                              return null;
                            } else {
                              return 'Please select the business category';
                            }
                          },
                          onChanged: (value) {
                            setState(() {
                              print('dropdown: $value');
                              _businessCategory = value;
                            });
                          },
                        )
                      : updateField == 'vehicle'
                          ? DropdownButtonFormField(
                              decoration: InputDecoration(
                                  labelText: 'Vehicle' + ":",
                                  prefixIcon: Icon(Icons.drive_eta)),
                              value: _vehicleType,
                              items: _vehicleTypes,
                              validator: (value) {
                                if (dropdownMenue(value) == null) {
                                  return null;
                                } else {
                                  return 'Please select the type of vehicle you user';
                                }
                              },
                              onChanged: (value) {
                                setState(() {
                                  print('dropdown: $value');
                                  _vehicleType = value;
                                });
                              },
                            )
                          : TextFormField(
                              controller: _textInput,
                              decoration: InputDecoration(
                                  hintText: updateField == 'email'
                                      ? currentUser.username
                                      : "Enter new $updateField here",
                                  prefixIcon: updateField == 'name'
                                      ? Icon(Icons.person)
                                      : updateField == 'email'
                                          ? Icon(Icons.email)
                                          : updateField == 'phone'
                                              ? Icon(Icons.phone)
                                              : ""),
                              validator: (value) {
                                if (value != null) {
                                  if (updateField == 'email' &&
                                      validateEmail(value) != null) {
                                    return 'Please enter a valid value';
                                  } else if (updateField == 'phone' &&
                                          validateMobile(value) != null ||
                                      currentUser.phone.toString() == value) {
                                    print(
                                        'CURRENT: ${currentUser.phone.toString()} NEW: $value');
                                    return 'Please enter a valid new phone';
                                  } else if (updateField == 'name' &&
                                      validateName(value) != null) {
                                    return 'Please enter a valid value';
                                  } else if (updateField == 'vehicle' &&
                                      validateName(value) != null) {
                                    return 'Please enter a valid value';
                                  } else if (value == '') {
                                    return 'Please enter a valid value';
                                  } else {
                                    return null;
                                  }
                                } else {
                                  return 'Please enter a valid value';
                                }
                              },
                            ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            okButton,
            FlatButton(
                child: Text('Update'),
                color: Colors.green,
                onPressed: () {
                  if (!_formKey.currentState.validate()) {
                    return;
                  } else {
                    if (updateField == 'email') {
                      print(
                          '> STAGE 1) Email update requested. Sending email-verification code');
                      sendEmailVerificationCode(
                          user: currentUser,
                          email: _textInput.text,
                          direction: 'request');
                      Navigator.pop(context);
                      //2) Open a popup with a text field for the code
                      print('> STAGE 4) Showing verification code entry form.');
                      String _sentCode = showVerificationAlert(
                        context: context,
                        user: currentUser,
                        title:
                            'Please enter the five digits you have received in your new email',
                      );
                      print('SENT CODE: $_sentCode');
                      //3) on submission, call ProfileUpdated with the email update field
                    } else if (updateField == 'phone') {
                      print(
                          '> STAGE 1) Phone update requested. Sending the phone number');
                      sendPhoneVerificationRequest(
                          user: currentUser,
                          phone: _textInput.text,
                          action: 'new_phone');
                      Navigator.pop(context);
                      //2) Open a popup with a text field for the code
                      print('> STAGE 4) Showing verification code entry form.');
                      String _sentCode = showVerificationAlert(
                        context: context,
                        user: currentUser,
                        title: 'Please enter the code you receive via SMS',
                      );
                      print('SENT CODE: $_sentCode');
                      //3) on submission, call ProfileUpdated with the email update field

                    } else {
                      print('UPDATED FIELD: $updateField');
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return ProfileUpdated(
                                user: currentUser,
                                updateField: updateField,
                                value: updateField == 'vehicle'
                                    ? _vehicleType
                                    : updateField == 'business category'
                                        ? _businessCategory
                                        : _textInput.text);
                          },
                        ),
                        (Route<dynamic> route) =>
                            false, // No Back option for this page
                      );
                    }
                    print('Updating $updateField');
                  }
                }),
          ],
        );
      },
    );
  }

  Future sendPhoneVerificationRequest(
      {User user, String phone, String action}) async {
    var _phoneVerificationApi;
    _phoneVerificationApi = await phoneVerificationAPI(
        phone: phone, code: "", user: user, action: 'new_phone');
  }

  Future<bool> sendEmailVerificationCode(
      {String email, User user, String direction}) async {
    bool _codeRequestSent = false;
    var _emailVerificationApi;
    if (direction == 'request') {
      _emailVerificationApi = await emailVerificationAPI(
          email: email, code: "", user: user, codeDirection: 'send_code');
    } else {
      _emailVerificationApi = await emailVerificationAPI(
          email: email, code: "", user: user, codeDirection: 'test_result');
    }
    print(
        '> STAGE 2)  Email verificaiton code sent. API message: $_emailVerificationApi');
    _codeRequestSent =
        _emailVerificationApi == "Update successful" ? true : false;

    // Storing tempporary email

    print('> STAGE 3) Storing temporary email $email in shared preferences.');
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    try {
      await localStorage.setString('tmpEmail', email);
    } catch (e) {
      print('Main page access USER repository');
    }
    return _codeRequestSent;
  }

  // Email change - Code verification
  showVerificationAlert({BuildContext context, String title, User user}) {
    final TextEditingController _emailCodeController =
        new TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext verifContext) {
        return AlertDialog(
          title: Text(title),
          content: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _emailCodeController,
                      decoration:
                          InputDecoration(prefixIcon: Icon(Icons.security)),
                      validator: (value) {
                        if (value != null) {
                          if (validateVerificationCode(value) != null) {
                            return 'Please enter a valid code';
                          } else {
                            return null;
                          }
                        }
                      },
                    )
                  ],
                ),
              )),
          actions: [
            FlatButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(verifContext);
              },
            ),
            FlatButton(
              child: Text('Submit'),
              onPressed: () {
                print('Sending verification code...');
                if (!_formKey.currentState.validate()) {
                  return;
                } else {
                  print(
                      '> STAGE 5) Entered code is sent for checking...Switching to form update page ');
                  Navigator.pushAndRemoveUntil(
                    verifContext,
                    MaterialPageRoute(
                      builder: (profileUpdatecontext) {
                        return ProfileUpdated(
                            user: user,
                            updateField: 'email',
                            value: _emailCodeController.text,
                            operation: 'check_code');
                      },
                    ),
                    (Route<dynamic> route) =>
                        false, // No Back option for this page
                  );
                }
              },
              color: Colors.green,
            )
          ],
        );
      },
    );
  }
}
