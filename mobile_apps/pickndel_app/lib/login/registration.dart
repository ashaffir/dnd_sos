// REFERENCE: Login/Registration. No Bloc
// REFERENCE: Form fields and validatios: https://www.youtube.com/watch?v=nFSL-CqwRDo
// REFERENCE: Snackbar/Flushbar: https://www.youtube.com/watch?v=KNpxyyA8MDA
// REFERENCE: Dropdown text: https://www.youtube.com/watch?v=L3E4LNSrSWM
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:pickndell/api_connection/api_connection.dart';
import 'package:pickndell/common/error_page.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/common/helper.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/login/login_page.dart';
import 'package:pickndell/login/message_page.dart';
import 'package:pickndell/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:url_launcher/url_launcher.dart';

String userSelection;
String userSelectionState;

class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  // TextEditingController _userNameController = TextEditingController();
  TextEditingController _mailController = TextEditingController();
  TextEditingController _password1Controller = new TextEditingController();
  TextEditingController _password2Controller = new TextEditingController();

  // TextEditingController firstNameController = TextEditingController();
  // TextEditingController lastNameController = TextEditingController();
  // TextEditingController passwordController = TextEditingController();
  // TextEditingController phoneController = TextEditingController();
  String firstName, lastName, email, mobile, password, confirmPassword;

  UserRepository userRepository = UserRepository();
  bool _isLoading = false;
  bool checkboxValue = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _userType;
  var _registrationTypes = List<DropdownMenuItem>();
  // List<String> _registrationTypeList = ['Sender', 'Courier'];
  List<String> _registrationTypeList;

  _loadRegistrationTypes() {
    // if (ui.window.locale.languageCode == 'he') {
    //   _registrationTypeList = ['שולח', 'שליח'];
    // } else {
    _registrationTypeList = ['Sender', 'Courier'];
    // }

    _registrationTypeList.forEach((element) {
      setState(() {
        _registrationTypes.add(DropdownMenuItem(
          child: Text(element),
          value: element,
        ));
      });
    });
  }

  _getUserSelection() async {
    try {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      userSelection = localStorage.getString('userSelection');
    } catch (e) {
      print('*** Error *** Fail getting user selection. E: $e');
      userSelection = null;
    }
    setState(() {
      userSelectionState = userSelection != null ? userSelection : "";
    });
  }

  @override
  void initState() {
    super.initState();
    _loadRegistrationTypes();
    _getUserSelection();
    print('USER SELECTION: $userSelection');
  }

  @override
  Widget build(BuildContext context) {
    final trans = ExampleLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(trans.register_join),
      ),
      body: Container(
        child: Form(
            key: _formKey,
            child: Padding(
                padding: EdgeInsets.only(left: 40.0, right: 40.0, bottom: 20.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/pickndell-logo-white.png',
                        width: MediaQuery.of(context).size.width * 0.50,
                        // height: MediaQuery.of(context).size.height * 0.50,
                        // width: 300,
                      ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            userSelectionState != null
                                ? '$userSelectionState'
                                : "",
                            style: whiteTitle,
                          ),
                        ],
                      ),
                      Text(
                        trans.register_form,
                        style: whiteTitle,
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                      ),
                      DropdownButtonFormField(
                        decoration: InputDecoration(
                            labelText: trans.register_as + ":",
                            prefixIcon: Icon(Icons.category)),
                        value: _userType,
                        items: _registrationTypes,
                        validator: (value) {
                          if (dropdownMenue(value) == null) {
                            return null;
                          } else {
                            return trans.register_alert_as;
                          }
                        },
                        onChanged: (value) {
                          setState(() {
                            print('dropdown: $value');
                            _userType = value;
                          });
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: trans.email, icon: Icon(Icons.person)),
                        controller: _mailController,
                        validator: (value) {
                          if (validateEmail(value) == null) {
                            return null;
                          } else {
                            return trans.alert_email;
                          }
                        },
                        // validator: (String value) {
                        //   if (value.isEmpty) {
                        //     return "Valid email required.";
                        //   }
                      ),

                      /////////////// password ////////////

                      TextFormField(
                        decoration: InputDecoration(
                            labelText: trans.password,
                            icon: Icon(Icons.security)),
                        controller: _password1Controller,
                        obscureText: true,
                        validator: validatePassword,
                      ),

                      /////////////// confirm password ////////////

                      TextFormField(
                        decoration: InputDecoration(
                            labelText: trans.register_confirm_pass,
                            icon: Icon(Icons.security)),
                        controller: _password2Controller,
                        obscureText: true,
                        validator: (val) => validateConfirmPassword(
                            _password1Controller.text, val),
                        onSaved: (String val) {
                          confirmPassword = val;
                        },
                      ),

                      /////////////// Accept Terms ////////////
                      FormField<bool>(
                        builder: (state) {
                          return Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Checkbox(
                                      value: checkboxValue,
                                      onChanged: (value) {
                                        setState(() {
                                          //save checkbox value to variable that store terms and notify form that state changed
                                          checkboxValue = value;
                                          state.didChange(value);
                                        });
                                      }),
                                  // Text('I accept terms'),
                                  FlatButton(
                                      onPressed: _launchURL,
                                      child: Text(
                                        trans.register_terms,
                                        style: TextStyle(color: Colors.blue),
                                      )),
                                ],
                              ),
                              //display error in matching theme
                              Text(
                                state.errorText ?? '',
                                style: TextStyle(
                                  color: Theme.of(context).errorColor,
                                ),
                              )
                            ],
                          );
                        },
                        //output from validation will be displayed in state.errorText (above)
                        validator: (value) {
                          if (!checkboxValue) {
                            return trans.register_alert_terms;
                          } else {
                            return null;
                          }
                        },
                      ),

                      /////////////// Registration Button ////////////

                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: FlatButton(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: 8, bottom: 8, left: 10, right: 10),
                              child: Text(
                                _isLoading
                                    ? trans.register_creating + '...'
                                    : trans.register_create,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            color: Colors.red,
                            disabledColor: Colors.grey,
                            shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(20.0)),
                            onPressed: _isLoading
                                ? null
                                : () {
                                    if (!_formKey.currentState.validate()) {
                                      return;
                                    } else {
                                      if (_isLoading) {
                                        return null;
                                      } else {
                                        return _registerUser();
                                      }
                                    }
                                  }),
                      ),

                      /////////////// already have an account ////////////
                      Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 50),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                new MaterialPageRoute(
                                    builder: (context) => LoginPage(
                                          userRepository: userRepository,
                                        )));
                          },
                          child: Text(
                            trans.register_already_have,
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0,
                              decoration: TextDecoration.none,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ))),
      ),
    );
  }

  void errorRegistration(BuildContext context, res) {
    final trans = ExampleLocalizations.of(context);
    // String msg = res["is_employee"] == "This field may not be null."
    //     ? "Please select Sender or Courier registration."
    //     : res;
    Flushbar(
      // mainButton: FlatButton(
      //   child: Text('Retry'),
      //   onPressed: () {},
      // ),
      // backgroundGradient: LinearGradient(
      //     colors: [Colors.red[300], Colors.redAccent[700]], stops: [0.6, 1]),
      backgroundColor: Colors.red[600],
      margin: EdgeInsets.all(10),
      borderRadius: 8,
      // boxShadows: [
      //   BoxShadow(color: Colors.white, offset: Offset(3, 3), blurRadius: 3),
      // ],
      title: trans.register_err,
      message:
          '${res["email"].toString().replaceAll("[", "").replaceAll("]", "")}',
      icon: Icon(
        Icons.info_outline,
        size: 28,
        color: Colors.white,
      ),
      duration: Duration(seconds: 5),
    )..show(context);
  }

  void _registerUser() async {
    setState(() {
      _isLoading = true;
    });

    try {
      var res = await createUser(
          email: _mailController.text,
          password1: _password1Controller.text,
          password2: _password2Controller.text,
          userType: _userType);

      if (res['response'] == "Success registration.") {
        print('Sucess registration: ${res["response"]}');
        SharedPreferences localStorage = await SharedPreferences.getInstance();
        localStorage.setString('token', res['token']);
        localStorage.setString('user', json.encode(res['email']));

        Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(
              builder: (context) => MessagePage(
                    messageType: "Registration",
                  )),
          (Route<dynamic> route) => false,
        );
      } else {
        print("${res['email']}");
        errorRegistration(context, res);
      }
    } catch (e) {
      print("*** Error *** Failed regitration");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ErrorPage(
              // user: user,
              errorMessage:
                  'There was a problem communicating with the server. Please try again later.',
            );
          },
        ),
        (Route<dynamic> route) => false, // No Back option for this page
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _password2Controller.dispose();
    _password1Controller.dispose();
    _mailController.dispose();
    super.dispose();
  }

  _launchURL() async {
    const url = 'https://pickndell.com/terms/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not open $url';
    }
  }
}
