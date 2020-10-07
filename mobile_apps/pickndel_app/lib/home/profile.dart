import 'package:async/async.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pickndell/common/error_page.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/common/helper.dart';
import 'package:pickndell/finance/payments.dart';
import 'package:pickndell/home/dashboard.dart';
import 'package:pickndell/lang/lang_helper.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/location/geo_helpers.dart';
import 'package:pickndell/login/id_upload.dart';
import 'package:pickndell/login/image_uploaded_message.dart';
import 'package:pickndell/login/phone_update.dart';
import 'package:pickndell/login/profile_update.dart';
import 'package:pickndell/model/credit_card_update.dart';
import 'package:pickndell/networking/CustomException.dart';
import 'package:pickndell/networking/messaging_widget.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pickndell/api_connection/api_connection.dart';
import 'package:flutter/material.dart';
import 'package:pickndell/ui/bottom_navigation_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import '../dao/user_dao.dart';
import '../model/user_model.dart';
import 'dart:isolate';

File _image;
File _currentProfilePic;
bool businessCategory = false;

class ProfilePage extends StatefulWidget {
  final User user;
  final String userCountry;

  ProfilePage({this.user, this.userCountry});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ReceivePort port = ReceivePort();
  TextEditingController _textInput = TextEditingController();

  String logStr = '';
  bool isRunning;
  bool isTracking = false;
  // LocationDto lastLocation;
  DateTime lastTimeLocation;
// User related
  var userData;
  User currentUser_G;
  User currentUser;
  User theCurrentUser;
  bool isEmployee;

  _getCurrentUser() async {
    theCurrentUser = await UserDao().getUser(0);
    setState(() {
      currentUser_G = theCurrentUser;
    });
  }

// User is not being set so the blow is not used
  // void _getUserInfo() async {
  //   SharedPreferences localStorage = await SharedPreferences.getInstance();
  //   var userJson = localStorage.getString('user');
  //   var user = json.decode(userJson);
  //   setState(() {
  //     userData = user;
  //   });
  // }

  var _vehicleTypes = List<DropdownMenuItem>();
  String _vehicleType;
  List<String> _vehicleTypeList;

  _loadVehicleTypes() async {
    // SharedPreferences localStorage = await SharedPreferences.getInstance();
    String country = await getCountryName();

    _vehicleTypeList = country == 'Israel' || country == 'ישראל'
        ? ['רכב', 'קטנוע', 'אופניים', 'אופנוע', 'משאית']
        : ['Car', 'Scooter', 'Bicycle', 'Motorcycle', 'Truck'];

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

  _loadCategoriesTypes() async {
    String country = await getCountryName();

    _businessCategoryList = country == 'Israel' || country == 'ישראל'
        ? ['מסעדה', 'בגדים', 'נוחות', 'מכולת', 'משרד', 'אחר']
        : [
            'Restaurant',
            'Clothes',
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
  bool _updatingProfile = false;
  bool _emailCodeVerification = false;

  Widget build(BuildContext context) {
    return getProfilePage(widget.user);
    // if (_updatingProfile) {
    //   String loaderText = "Loading Profile...";
    //   return ColoredProgressDemo(loaderText);
    // } else {
    //   return FutureBuilder(
    //     future: UserDao().getUser(0),
    //     builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
    //       if (snapshot.hasData) {
    //         currentUser = snapshot.data;
    //         print('USER IS: ${snapshot.data.username}');
    //         return getProfilePage(widget.user);
    //       } else {
    //         print("No data");
    //       }
    //       return CircularProgressIndicator();
    //     },
    //   );
    // }
  }

  String _country;

  Future checkCountry() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    _country = localStorage.getString('userCountry');
  }

  // The routine was not accessed to save performance...
  Future _checkProfile() async {
    setState(() {
      _updatingProfile = true;
    });
    User _currentUser = await UserDao().getUser(0);
    var _getProfileResponse;
    try {
      _getProfileResponse = await getProfile(user: _currentUser);
      print('GET PROFILE: $_getProfileResponse');
    } catch (e) {
      print('ERROR >> PROFILE: Server Communication Error. ERROR: $e');
    }

    try {
      await rowUpdate(user: _currentUser, data: _getProfileResponse);
    } on NoSuchMethodError {
      print('Profile: DB update Error');
    }
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
    _getProfilePic();
    checkCountry();

    // _checkProfile();
  }

  Widget getProfilePage(User currentUser) {
    print('WIDGET USER: ${widget.user.phone}');
    final translations = ExampleLocalizations.of(context);
    return SafeArea(
      child: Scaffold(
        body: Container(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                MessagingWidget(),
                Padding(padding: EdgeInsets.only(top: 20)),
                (currentUser.isEmployee == 1)
                    ? Text(
                        translations.home_courier_profile,
                        style: whiteTitle,
                      )
                    : Text(translations.home_sender_profile, style: whiteTitle),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ///////////////////// Image Section //////////////
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 8.0, top: 20, right: 8, bottom: 8),
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: <Widget>[
                          CircleAvatar(
                            radius: 65,
                            backgroundColor: Colors.grey.shade400,
                            child: ClipOval(
                              child: SizedBox(
                                width: 170,
                                height: 170,
                                child: _currentProfilePic != null
                                    ? Image.file(
                                        _currentProfilePic,
                                        fit: BoxFit.cover,
                                      )
                                    : _image == null
                                        ? Image.asset(
                                            'assets/images/placeholder.jpg',
                                            fit: BoxFit.cover,
                                          )
                                        : Image.file(
                                            _image,
                                            fit: BoxFit.cover,
                                          ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 80,
                            right: 0,
                            child: FloatingActionButton(
                                backgroundColor: Colors.blue,
                                child: Icon(Icons.camera_alt),
                                mini: true,
                                onPressed: _onCameraClick),
                          )
                        ],
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        RaisedButton(
                            child: Text(translations.upload_photo),
                            color: mainBackground,
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: pickndellGreen,
                                width: 2,
                              ),
                            ),
                            onPressed: () {
                              if (_image == null) {
                                showAlertDialog(
                                    context: context,
                                    title: 'No Image Selected',
                                    content:
                                        "Please select an image to upload.");
                              } else {
                                _saveProfilePic();
                                _sendToServer();
                              }
                            })
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ////////////// NAME SECTION ////////////////
                        ///
                        Padding(
                          padding: EdgeInsets.only(left: 30.0),
                        ),
                        currentUser.isEmployee == 0
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  currentUser.businessName != null
                                      ? IconButton(
                                          icon: Icon(Icons.check_circle),
                                          color: pickndellGreen,
                                          onPressed: () {
                                            print('Name');
                                          },
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
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: <Widget>[
                                  currentUser.name != null
                                      ? IconButton(
                                          icon: Icon(Icons.check_circle),
                                          color: pickndellGreen,
                                          onPressed: () {
                                            print('Courier Name');
                                          },
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
                        Text(
                          translations.home_name + ":",
                          style: intrayTitleStyle,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                        ),
                        InkWell(
                          onTap: () {
                            updateProfile(
                                context: context, updateField: 'name');
                          },
                          child: Text(
                              currentUser.isEmployee == 1
                                  ? currentUser.name != null
                                      ? '${currentUser.name}'
                                      : " "
                                  : currentUser.businessName != null
                                      ? '${currentUser.businessName}'
                                      : " ",
                              style: userContentStyle),
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
                        currentUser.phone != null
                            ? IconButton(
                                icon: Icon(Icons.check_circle),
                                color: pickndellGreen,
                                onPressed: () {
                                  print('Phone');
                                },
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
                        Text(
                          translations.home_phone + ":",
                          style: intrayTitleStyle,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                        ),
                        InkWell(
                          onTap: () {
                            updateProfile(
                                context: context, updateField: 'phone');
                          },
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              currentUser.phone != null
                                  ? '${currentUser.phone}'
                                  : " ",
                              style: userContentStyle,
                            ),
                          ),
                        ),
                      ],
                    ),

                    ////////////// EMAIL SECTION ////////////////
                    ///
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(left: 30.0, top: 10.0),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton(
                              icon: Icon(Icons.check_circle),
                              color: pickndellGreen,
                              onPressed: () {
                                print("Email");
                              },
                            ),
                          ],
                        ),
                        IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              updateProfile(
                                  context: context, updateField: 'email');
                              print('EDIT EMAIL');
                            }),
                        Text(
                          translations.email + ":",
                          style: intrayTitleStyle,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                        ),
                        Flexible(
                          child: InkWell(
                            onTap: () {
                              updateProfile(
                                  context: context, updateField: 'email');
                            },
                            child: Text(
                              currentUser.username != null
                                  ? '${currentUser.username}'
                                  : " ",
                              style: userContentStyle,
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                        ),
                      ],
                    ),

                    ////////////// ID DOCUMENT SECTION ////////////////
                    ///
                    if (currentUser.isEmployee == 1)
                      Row(
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 30.0, top: 10.0),
                          ),
                          currentUser.isEmployee == 1
                              ? Row(
                                  children: <Widget>[
                                    currentUser.idDoc != null
                                        ? IconButton(
                                            icon: Icon(Icons.check_circle),
                                            color: pickndellGreen,
                                            onPressed: () {
                                              print('ID doc');
                                            },
                                          )
                                        : IconButton(
                                            icon: Icon(Icons.control_point),
                                            color: Colors.orange,
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        IdUpload(
                                                          user: currentUser,
                                                          country: _country,
                                                          updateField:
                                                              'photo_id',
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
                                            country: _country,
                                            updateField: 'photo_id',
                                          )),
                                );
                                print('EDIT ID PHOTO');
                              }),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => IdUpload(
                                          user: currentUser,
                                          country: _country,
                                          updateField: 'photo_id',
                                        )),
                              );
                            },
                            child: Text(
                              "ID Document",
                              style: intrayTitleStyle,
                            ),
                          ),
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
                              currentUser.creditCardToken != null
                                  ? IconButton(
                                      icon: Icon(Icons.check_circle),
                                      color: pickndellGreen,
                                      onPressed: () {
                                        print('Credit Card');
                                      },
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
                                          builder: (context) =>
                                              CreditCardUpdate(
                                                user: currentUser,
                                              )),
                                    );
                                  }),
                              Text(
                                translations.credit_card,
                                style: intrayTitleStyle,
                              ),
                              Padding(padding: EdgeInsets.only(right: 10)),
                              if (currentUser.creditCardToken != null)
                                Icon(Icons.credit_card),
                            ],
                          )
                        : Row(),
                    ////////////// CATEGORY SECTION ////////////////
                    /// - Currently is not enabled. To enable, change businessCategory to "true"
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 30.0, top: 10.0),
                        ),
                        Row(
                          children: <Widget>[
                            currentUser.vehicle != null ||
                                    currentUser.businessCategory != null
                                ? IconButton(
                                    icon: Icon(Icons.check_circle),
                                    color: pickndellGreen,
                                    onPressed: () {
                                      print('Category');
                                    },
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
                        ), // Not adding for business yet
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
                        Text(
                          currentUser.isEmployee == 1
                              ? translations.home_vehicle + ":"
                              : translations.category + " :",
                          style: intrayTitleStyle,
                        ),
                        Padding(
                          padding: EdgeInsets.only(right: 10.0),
                        ),
                        InkWell(
                          onTap: () {
                            updateProfile(
                                context: context,
                                updateField: currentUser.isEmployee == 1
                                    ? 'vehicle'
                                    : 'business category');
                          },
                          child: Text(
                            currentUser.isEmployee == 1
                                ? currentUser.vehicle != null
                                    ? widget.userCountry == 'IL'
                                        ? translateVehicle(currentUser.vehicle)
                                        : '${currentUser.vehicle}'
                                    : " "
                                : currentUser.businessCategory != null
                                    ? widget.userCountry == 'IL'
                                        ? translateCategory(
                                            currentUser.businessCategory)
                                        : '${currentUser.businessCategory}'
                                    : " ",
                            style: userContentStyle,
                          ),
                        ),
                      ],
                    ),
                    Divider(color: Colors.white),
                    Padding(padding: EdgeInsets.only(top: 20.0)),
                    Row(
                      children: [
                        Spacer(
                          flex: 1,
                        ),
                        Padding(
                          padding:
                              EdgeInsets.only(top: 30.0, left: LEFT_MARGINE),
                        ),
                        InkWell(
                          child: Row(
                            children: <Widget>[
                              Icon(Icons.arrow_back),
                              Padding(padding: EdgeInsets.only(right: 10.0)),
                              Text(translations.back_to_dashboard),
                            ],
                          ),
                          onTap: () {
                            print('BACK');
                            // Navigator.pop(context);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return Dashboard();
                                },
                              ),
                              (Route<dynamic> route) =>
                                  false, // No Back option for this page
                            );
                          },
                        ),
                        Spacer(
                          flex: 2,
                        ),
                        if (currentUser.isEmployee == 1)
                          FlatButton.icon(
                            icon: Icon(Icons.monetization_on),
                            label: Text(translations.payments),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(BUTTON_BORDER_RADIUS),
                                side: BorderSide(color: buttonBorderColor)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => PaymentsPage(
                                          user: currentUser,
                                          userCountry: _country,
                                        )),
                              );
                            },
                          ),
                        Spacer(
                          flex: 1,
                        ),
                      ],
                    ),
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
      ),
    );
  }

//////////////// Update Profile //////////////////
  ///
  Future updateProfile({BuildContext context, String updateField}) async {
    final trans = ExampleLocalizations.of(context);
    User currentUser = await UserDao().getUser(0);
    /////// Cancel Button ////////////
    ///
    Widget okButton = FlatButton(
      child: Text(trans.orders_cancel),
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
          title: updateField == 'phone'
              ? Column(
                  children: [
                    Text('${trans.enter_with_country_code}:'),
                    Padding(padding: EdgeInsets.only(right: 10)),
                    Directionality(
                        textDirection: TextDirection.ltr,
                        child: Text("+972541234567")),
                  ],
                )
              : updateField == 'name'
                  ? Text('${trans.change_the_name}')
                  : updateField == 'email'
                      ? Text('${trans.change_the_email}')
                      : updateField == 'business category'
                          ? Text('${trans.change_the_category}')
                          : updateField == 'vehicle'
                              ? Text('${trans.change_the_vehicle}')
                              : Text(""),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  /////////// Business Category ////////////
                  ///
                  updateField == 'business category'
                      ? DropdownButtonFormField(
                          decoration: InputDecoration(
                              labelText: trans.category + ":",
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
                              // ['מסעדה', 'בגדים', 'נוחות', 'מכולת', 'משרד', 'אחר']
                              // 'Restaurant','Clothes','Convenience','Grocery','Office','Other'
                              switch (value) {
                                case 'מסעדה':
                                  _businessCategory = 'Restaurant';
                                  break;
                                case 'בגדים':
                                  _businessCategory = 'Clothes';
                                  break;
                                case 'נוחות':
                                  _businessCategory = 'Convenience';
                                  break;
                                case 'מכולת':
                                  _businessCategory = 'Grocery';
                                  break;
                                case 'משרד':
                                  _businessCategory = 'Office';
                                  break;
                                case 'אחר':
                                  _businessCategory = 'Other';
                                  break;
                                default:
                                  _businessCategory = value;
                              }
                            });
                          },
                        )

                      /////////// Vehicle  ////////////
                      ///

                      : updateField == 'vehicle'
                          ? DropdownButtonFormField(
                              decoration: InputDecoration(
                                  labelText: trans.home_vehicle + ":",
                                  prefixIcon: Icon(Icons.drive_eta)),
                              value: _vehicleType,
                              items: _vehicleTypes,
                              validator: (value) {
                                if (value != null) {
                                  return null;
                                } else {
                                  return trans.please_select_vehicle;
                                }
                              },
                              onChanged: (value) {
                                setState(() {
                                  print('dropdown: $value');
                                  // ['רכב', 'קטנוע', 'אופניים', 'אופנוע', 'משאית']
                                  switch (value) {
                                    case 'רכב':
                                      _vehicleType = 'Car';
                                      break;
                                    case 'קטנוע':
                                      _vehicleType = 'Scooter';
                                      break;
                                    case 'אופניים':
                                      _vehicleType = 'Bicycle';
                                      break;
                                    case 'אופנוע':
                                      _vehicleType = 'Motorcycle';
                                      break;
                                    case 'משאית':
                                      _vehicleType = 'Truck';
                                      break;
                                    default:
                                      _vehicleType = value;
                                  }
                                });
                              },
                            )

                          /////////// Email/Name/Phone ////////////
                          ///

                          : Directionality(
                              textDirection: TextDirection.ltr,
                              child: TextFormField(
                                controller: _textInput,
                                decoration: InputDecoration(
                                    hintText: updateField == 'email'
                                        ? currentUser.username
                                        : trans.enter_here,
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
                                      return trans.alert_email;
                                    } else if (updateField == 'phone' &&
                                            isValidPhoneNumber(value) != null ||
                                        currentUser.phone.toString() == value) {
                                      return trans.please_enter_a_valid_phone;
                                    } else if (updateField == 'name' &&
                                        value.isEmpty) {
                                      return trans.name_not_valid;
                                    } else if (updateField == 'vehicle' &&
                                        validateName(value) != null) {
                                      return trans.please_select_vehicle;
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
                            ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            okButton,

            /////////////////// Profile update email button ///////////
            ///
            FlatButton(
                child: Text(trans.update),
                shape: StadiumBorder(
                  side: BorderSide(
                    color: pickndellGreen,
                    width: 2,
                  ),
                ),
                color: pickndellGreen,
                textColor: DEFAUT_TEXT_COLOR,
                onPressed: () {
                  if (!_formKey.currentState.validate()) {
                    return;
                  } else {
                    // Navigator.pop(context);
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
                      showVerificationAlert(
                        context: context,
                        user: currentUser,
                        updateField: 'email',
                        title: trans.please_enter_the_five_email_code,
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
                      print(
                          'UPDATED FIELD: $updateField with new value ${_textInput.text}');
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
                        (Route<dynamic> route) => false,
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
    final trans = ExampleLocalizations.of(context);
    bool _codeRequestSent = false;
    var _emailVerificationApi;
    if (direction == 'request') {
      try {
        _emailVerificationApi = await emailVerificationAPI(
            email: email, code: "", user: user, codeDirection: 'send_code');
      } on FetchDataException catch (e) {
        print('Failed to send request for an email code. ERROR: $e');
        return Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ErrorPage(
                user: widget.user,
                errorMessage: trans.messages_communication_error,
              );
            },
          ),
          (Route<dynamic> route) => false, // No Back option for this page
        );
      }
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
    final trans = ExampleLocalizations.of(context);
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
                      keyboardType: TextInputType.number,
                      controller: _verificationCodeController,
                      decoration:
                          InputDecoration(prefixIcon: Icon(Icons.security)),
                      validator: (value) {
                        if (value != null) {
                          if (validateVerificationCode(value) != null) {
                            return trans.please_enter_valid_email_code;
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
              child: Text(trans.close),
              onPressed: () {
                Navigator.pop(verifContext);
              },
            ),
            FlatButton(
              child: Text(trans.submit),
              textColor: DEFAUT_TEXT_COLOR,
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

  _onCameraClick() {
    final trans = ExampleLocalizations.of(context);
    final action = CupertinoActionSheet(
      message: Text(
        trans.submit_photo_id,
        style: TextStyle(fontSize: 15.0),
      ),
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text(trans.choose_gallery,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          isDefaultAction: false,
          onPressed: () async {
            Navigator.pop(context);
            var image = await ImagePicker.pickImage(
                source: ImageSource.gallery,
                imageQuality: 60,
                maxHeight: 500.0,
                maxWidth: 500.0);
            setState(() {
              _image = image;
            });
          },
        ),
        CupertinoActionSheetAction(
          child: Text(trans.take_a_picture,
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          isDestructiveAction: false,
          onPressed: () async {
            Navigator.pop(context);
            var image = await ImagePicker.pickImage(
                source: ImageSource.camera,
                imageQuality: 50,
                maxHeight: 500.0,
                maxWidth: 500.0);
            setState(() {
              _image = image;
            });
          },
        )
      ],
      cancelButton: CupertinoActionSheetAction(
        child: Text(trans.orders_cancel,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
    showCupertinoModalPopup(context: context, builder: (context) => action);
  }

  _getProfilePic() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _currentProfilePic = File(prefs.getString('profilePic'));
      print("PROFILE PIC: $_currentProfilePic");
    } catch (e) {
      print('Failed getting profile picture in shared preferences. E: $e');
    }
  }

  _saveProfilePic() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('profilePic', _image != null ? _image.path : "");
    } catch (e) {
      print('No Image found in database. E: $e');
    }
  }

  _sendToServer() async {
    final trans = ExampleLocalizations.of(context);
    showProgress(context, trans.uploading_to_pickndell + '...', false);
    if (_image != null) {
      updateProgress(trans.uploading_image + '...');
      try {
        _uploadImage(imageFile: _image, user: widget.user);
      } catch (e) {
        print('Failed uploading the image. ERROR: $e');
        return ErrorPage(
          user: widget.user,
          errorMessage:
              'There was a problem uploading your image to the server. Please try again later.',
        );
      }
    } else {
      print('false');
    }
  }

  _uploadImage({File imageFile, User user}) async {
    final trans = ExampleLocalizations.of(context);

    // open a bytestream
    var stream = new http.ByteStream(DelegatingStream(imageFile.openRead()));
    // get file length
    var length = await imageFile.length();

    // string to uri
    var uri = Uri.parse(serverDomain + "/api/user-profile-image/");

    Map<String, String> headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Token ${user.token}',
    };

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);

    // multipart that takes file
    var multipartFile = new http.MultipartFile('image', stream, length,
        filename: imageFile != null ? imageFile.path.split("/").last : "");

    // add file to multipart
    request.files.add(multipartFile);

    //add headers
    request.headers.addAll(headers);

    //adding params
    String country;
    try {
      country = await getCountryName();
    } catch (e) {
      print('Failed getting the country code. ERROR: $e');
      country = defaultCountry;
    }
    request.fields['user_id'] = user.userId.toString();
    request.fields['is_employee'] = user.isEmployee == 1 ? "true" : "false";
    request.fields['country'] = country;

    // send
    var response;
    try {
      response = await request.send();
      // listen for response
      response.stream.transform(utf8.decoder).listen((value) {
        if (value == "202") {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ImageUploaded(
                  uploadStatus: 'ok',
                  user: user,
                );
              },
            ),
            (Route<dynamic> route) => false, // No Back option for this page
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) {
                return ImageUploaded(
                  uploadStatus: 'fail',
                  user: user,
                );
              },
            ),
            (Route<dynamic> route) => false, // No Back option for this page
          );
        }
      });
    } catch (e) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ErrorPage(
              user: user,
              errorMessage: trans.messages_communication_error,
            );
          },
        ),
        (Route<dynamic> route) => false, // No Back option for this page
      );
    }
  }
}
