import 'dart:async';
import 'dart:ui';
import 'dart:convert';

import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:background_locator/location_settings.dart';
import 'package:flutter/cupertino.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/common/helper.dart';
import 'package:pickndell/home/profile.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/location/credencials.dart';
import 'package:pickndell/location/geo_helpers.dart';
import 'package:pickndell/location/location_callback_handler.dart';
import 'package:pickndell/location/location_service_repository.dart';
import 'package:pickndell/location/place.dart';
import 'package:pickndell/location/search_bloc.dart';
import 'package:pickndell/login/id_upload.dart';
import 'package:pickndell/login/phone_update.dart';
import 'package:pickndell/login/profile_updated.dart';
import 'package:pickndell/model/credit_card_update.dart';
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
import 'package:pickndell/ui/progress_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:auto_size_text/auto_size_text.dart';

import 'package:http/http.dart' as http;
import 'package:smooth_star_rating/smooth_star_rating.dart';

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

  Widget getHomePageIsolate(User currentUser) {
    final translations = ExampleLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: (currentUser.isApproved == 1)
            ? Text('Home')
            : (currentUser.profilePending == 1)
                ? Text(translations.home_title + ' (Pending Approval)')
                : Text(translations.home_title + ' (Not Complete)'),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              MessagingWidget(),
              Image.asset(
                'assets/images/pickndell-logo-white.png',
                width: MediaQuery.of(context).size.width * 0.40,
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
                        padding: EdgeInsets.only(left: 30.0),
                      ),

                      ////////////// NAME SECTION ////////////////
                      ///
                      Text(
                        translations.home_name + ":",
                        style: intrayTitleStyle,
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 10.0),
                      ),
                      Row(
                        children: [
                          Text(
                              currentUser.isEmployee == 1
                                  ? currentUser.name != null
                                      ? '${currentUser.name}'
                                      : " "
                                  : currentUser.businessName != null
                                      ? '${currentUser.businessName}'
                                      : " ",
                              style: userContentStyle),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 10.0),
                      ),

                      currentUser.isEmployee == 0
                          ? Row(
                              children: <Widget>[
                                currentUser.businessName != null
                                    ? Icon(
                                        Icons.check_circle,
                                        color: pickndellGreen,
                                      )
                                    : IconButton(
                                        icon: Icon(Icons.control_point),
                                        color: Colors.orange,
                                        onPressed: () {
                                          updateProfile(
                                              context: context,
                                              updateField: 'name');
                                          print('UPDATE NAME');
                                        }),
                                IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      updateProfile(
                                          context: context,
                                          updateField: 'name');
                                      print('EDIT NAME');
                                    }),
                              ],
                            )
                          : Row(
                              children: <Widget>[
                                currentUser.name != null
                                    ? Icon(
                                        Icons.check_circle,
                                        color: pickndellGreen,
                                      )
                                    : IconButton(
                                        icon: Icon(Icons.control_point),
                                        color: Colors.orange,
                                        onPressed: () {
                                          updateProfile(
                                              context: context,
                                              updateField: 'name');
                                          print('UPDATE NAME');
                                        }),
                                IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      updateProfile(
                                          context: context,
                                          updateField: 'name');
                                      print('EDIT NAME');
                                    }),
                              ],
                            ),
                    ],
                  ),

                  ////////////// PHONE SECTION ////////////////
                  ///
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 10.0),
                      ),
                      Text(
                        translations.home_phone + ":",
                        style: intrayTitleStyle,
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 10.0),
                      ),
                      Text(
                        currentUser.phone != null
                            ? '${currentUser.phone}'
                            : " ",
                        style: userContentStyle,
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 5.0),
                      ),
                      currentUser.phone != null
                          ? Icon(
                              Icons.check_circle,
                              color: pickndellGreen,
                            )
                          : IconButton(
                              icon: Icon(Icons.control_point),
                              color: Colors.orange,
                              onPressed: () {
                                updateProfile(
                                    context: context, updateField: 'phone');
                                print('UPDATE PHONE');
                              }),
                      IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            updateProfile(
                                context: context, updateField: 'phone');
                            print('UPDATE PHONE');
                          }),
                    ],
                  ),

                  ////////////// EMAIL SECTION ////////////////
                  ///
                  Row(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 10.0),
                      ),
                      Text(
                        translations.email + ":",
                        style: intrayTitleStyle,
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 10.0),
                      ),
                      Text(
                        currentUser.username != null
                            ? '${currentUser.username}'
                            : " ",
                        style: userContentStyle,
                      ),
                      Padding(padding: EdgeInsets.only(right: 5.0)),
                      Icon(Icons.check_circle, color: pickndellGreen),
                      IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            updateProfile(
                                context: context, updateField: 'email');
                            print('EDIT EMAIL');
                          }),
                    ],
                  ),
                  ////////////// CATEGORY SECTION ////////////////
                  ///
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 10.0),
                      ),
                      Text(
                        currentUser.isEmployee == 1
                            ? translations.home_vehicle + ":"
                            : translations.category + ":",
                        style: intrayTitleStyle,
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
                        style: userContentStyle,
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 10.0),
                      ),
                      currentUser.isEmployee == 1
                          ? Row(
                              children: <Widget>[
                                currentUser.vehicle != null
                                    ? Icon(
                                        Icons.check_circle,
                                        color: pickndellGreen,
                                      )
                                    : IconButton(
                                        icon: Icon(Icons.control_point),
                                        color: Colors.orange,
                                        onPressed: () {
                                          updateProfile(
                                              context: context,
                                              updateField:
                                                  currentUser.isEmployee == 1
                                                      ? 'vehicle'
                                                      : 'business category');
                                          print('EDIT VEHICLE');
                                        },
                                      )
                              ],
                            )
                          : Row(), // Not adding for business yet
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
                  ////////////// ID DOCUMENT SECTION ////////////////
                  ///
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 30.0, top: 10.0),
                      ),
                      Text(
                        "ID Document:",
                        style: intrayTitleStyle,
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 10.0),
                      ),
                      currentUser.isEmployee == 1
                          ? Row(
                              children: <Widget>[
                                currentUser.idDoc != null
                                    ? Icon(
                                        Icons.check_circle,
                                        color: pickndellGreen,
                                      )
                                    : IconButton(
                                        icon: Icon(Icons.control_point),
                                        color: Colors.orange,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => IdUpload(
                                                      user: currentUser,
                                                      updateField: 'photo_id',
                                                    )),
                                          );
                                          print('Add ID Document');
                                        },
                                      )
                              ],
                            )
                          : Row(), // Not adding for business yet
                      IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => IdUpload(
                                        user: currentUser,
                                        updateField: 'photo_id',
                                      )),
                            );
                            print('EDIT ID PHOTO');
                          }),
                    ],
                  ),

                  ////////////// CREDICT CARD SECTION (ONLY BUSINESS/SENDER) ////////////////
                  ///
                  currentUser.isEmployee == 0
                      ? Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 30.0, top: 10.0),
                            ),
                            Text(
                              'Credit Card' + ":",
                              style: intrayTitleStyle,
                            ),
                            Padding(
                              padding: EdgeInsets.only(right: 10.0),
                            ),
                            currentUser.creditCardToken != null
                                ? Icon(
                                    Icons.check_circle,
                                    color: pickndellGreen,
                                  )
                                : IconButton(
                                    icon: Icon(Icons.control_point,
                                        color: Colors.orange),
                                    onPressed: () {
                                      print('CREDIT CARD');
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                CreditCardUpdate(
                                                  user: currentUser,
                                                  userRepository:
                                                      widget.userRepository,
                                                )),
                                      );
                                    }),
                            IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () {
                                  print('CREDIT CARD');
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CreditCardUpdate(
                                              user: currentUser,
                                              userRepository:
                                                  widget.userRepository,
                                            )),
                                  );
                                }),
                          ],
                        )
                      : Row(),
                  Divider(color: Colors.white),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                  ),

                  //////////////// User Rating  ///////////////
                  ////////////
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
                                    currentUser.rating != 0.0
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
                              : 0.0,
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
                                          url: '',
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
                  currentUser.isEmployee == 0
                      ? Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 30.0, top: 20.0),
                            ),
                            FlatButton(
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
                                        url: '');
                                  }
                                },
                                child: Text('Create a New Order')),
                          ],
                        )
                      : Row(),
                  FlatButton(
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
                                builder: (context) => ProfilePage(
                                      user: currentUser,
                                    )),
                          );
                        } else {
                          showAlertDialog(
                              context: context,
                              title: 'Your account is not approved.',
                              content:
                                  "Please complete your profile before ordering deliveries. \n Name, phone and credit card are mandatory.",
                              url: '');
                        }
                      },
                      child: Text('Edit Profile'))
                ], //Children
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(34.0, 20.0, 0.0, 0.0),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        user: currentUser,
      ),

      // resizeToAvoidBottomPadding: false,
    );
  }

//////////////// Update Profile //////////////////
  ///
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

    /////////// Field update Button Dialog /////////////////////
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
                color: pickndellGreen,
                textColor: DEFAUT_TEXT_COLOR,
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
                      String _sentEmailCode = showVerificationAlert(
                        context: context,
                        user: currentUser,
                        updateField: 'email',
                        title:
                            'Please enter the five digits you have received in your new email',
                      );
                      //3) on submission, call ProfileUpdated with the email update field
                    } else if (updateField == 'phone') {
                      print(
                          '> STAGE 1) Phone update requested. Sending the phone number');
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return PhoneUpdate(
                                user: currentUser, newPhone: _textInput.text);
                          },
                        ),
                        (Route<dynamic> route) =>
                            false, // No Back option for this page
                      );
                    } else {
                      print('UPDATED FIELD: $updateField');
                      Navigator.push(
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

  bool codeRequestSent;

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

  // Email/Phone change - Code verification
  showVerificationAlert(
      {BuildContext context, String title, User user, String updateField}) {
    final TextEditingController _verificationCodeController =
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
                      controller: _verificationCodeController,
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
                            updateField: updateField,
                            value: _verificationCodeController.text,
                            operation: 'check_code');
                      },
                    ),
                    (Route<dynamic> route) =>
                        false, // No Back option for this page
                  );
                }
              },
              color: pickndellGreen,
            )
          ],
        );
      },
    );
  }
}
