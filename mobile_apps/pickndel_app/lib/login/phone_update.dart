import 'package:flutter/material.dart';
import 'package:pickndell/api_connection/api_connection.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/common/helper.dart';
import 'package:pickndell/home/home_page_isolate.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/login/profile_updated.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/repository/user_repository.dart';
import 'package:pickndell/ui/bottom_nav_bar.dart';
import 'package:pickndell/ui/progress_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PhoneUpdate extends StatefulWidget {
  final String newPhone;
  final User user;

  PhoneUpdate({this.user, this.newPhone});

  @override
  _PhoneUpdateState createState() => _PhoneUpdateState();
}

class _PhoneUpdateState extends State<PhoneUpdate> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: sendPhoneVerificationRequest(
          user: widget.user, phone: widget.newPhone, action: 'new_phone'),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        print('SNAPSHO DATA: ${snapshot.data}');
        if (snapshot.hasData) {
          if (snapshot.data) {
            print('CONDITION TRUE');
            return phoneUpdatedPage();
          } else {
            return phoneUpdatedErrorPage();
          }
        } else {
          print("No data around here:");
        }
        print('Waiting for code verification...');
        String loaderText = "Sending code...";
        return ColoredProgressDemo(loaderText);
      },
    );
  }

  Future<bool> sendPhoneVerificationRequest(
      {User user, String phone, String action}) async {
    bool _codeRequestSent;
    var _phoneVerificationApi;

    // Getting the country code from memory
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    String userCountryCode = localStorage.getString('userCountry');

    _phoneVerificationApi = await phoneVerificationAPI(
        phone: phone,
        countryCode: userCountryCode,
        verificationCode: "",
        user: user,
        action: 'new_phone');
    _codeRequestSent =
        _phoneVerificationApi['response'] == "Update successful" ? true : false;
    print('> STAGE 2) Reponse from TW/PND: $_codeRequestSent');

    if (_codeRequestSent) {
      print('> STAGE 3) Save the phone in local memeory.');
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      try {
        await localStorage.setString('tmpPhone', phone);
      } catch (e) {
        print('ERROR: Country check page');
      }

      // print('> STAGE 4) Showing verification code entry form.');
      // String sentPhoneCode = showVerificationAlert(
      //   context: context,
      //   user: user,
      //   updateField: 'phone',
      //   title: 'Please enter the code you receive via SMS',
      // );
    } else {
      print('> STAGE 4.a) BAD Phone entered.');
      showAlertDialog(
          context: context, content: '', title: 'Phone not Valid', url: '');
    }

    return _codeRequestSent;
  }

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
          backgroundColor: mainBackground,
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
              color: Colors.green,
            )
          ],
        );
      },
    );
  }

  Widget phoneUpdatedPage() {
    final trans = ExampleLocalizations.of(context);
    final TextEditingController _verificationCodeController =
        new TextEditingController();
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

    return new Scaffold(
      backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text('Updating Phone'),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 20),
        // height: 160,
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.only(left: 40.0, right: 40.0, bottom: 40.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(padding: EdgeInsets.only(top: 40)),
                  Text(
                    'Please Enter the code you received through SMS',
                    style: whiteTitle,
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 30)),
                  TextFormField(
                    keyboardType: TextInputType.number,
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
                  ),
                  Padding(padding: EdgeInsets.only(bottom: 30)),
                  FlatButton(
                    child: Text('Submit'),
                    onPressed: () {
                      print('Sending verification code...');
                      if (!_formKey.currentState.validate()) {
                        return;
                      } else {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (profileUpdatecontext) {
                              return ProfileUpdated(
                                  user: widget.user,
                                  updateField: 'phone',
                                  value: _verificationCodeController.text,
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
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        userRepository: UserRepository(),
      ),
    );
  }

  Widget phoneUpdatedErrorPage() {
    final trans = ExampleLocalizations.of(context);

    return new Scaffold(
      backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text('Error updating phone'),
      ),
      body: Container(
        padding: EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Spacer(
              flex: 5,
            ),
            Text(
              'Phone number is not valid.',
              style: whiteTitle,
            ),
            Spacer(
              flex: 2,
            ),
            Text(
              'Please try again later',
              style: whiteTitle,
            ),
            Spacer(
              flex: 5,
            ),
            FlatButton(
              child: Text('Back To Main Page'),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return HomePageIsolate(
                        userRepository: UserRepository(),
                      );
                    },
                  ),
                  (Route<dynamic> route) =>
                      false, // No Back option for this page
                );
              },
              color: pickndellGreen,
            ),
            Spacer(
              flex: 5,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
