// REFERENCE: Login/Registration. No Bloc
// REFERENCE: Form fields and validatios: https://www.youtube.com/watch?v=nFSL-CqwRDo
// REFERENCE: Snackbar/Flushbar: https://www.youtube.com/watch?v=KNpxyyA8MDA
// REFERENCE: Dropdown text: https://www.youtube.com/watch?v=L3E4LNSrSWM
import 'dart:convert';

import 'package:pickndell/api_connection/api_connection.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/common/helper.dart';
import 'package:pickndell/login/login_page.dart';
import 'package:pickndell/login/message_page.dart';
import 'package:pickndell/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:url_launcher/url_launcher.dart';

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
  List<String> _registrationTypeList = ['Business', 'Carrier'];

  _loadRegistrationTypes() {
    _registrationTypeList.forEach((element) {
      setState(() {
        _registrationTypes.add(DropdownMenuItem(
          child: Text(element),
          value: element,
        ));
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _loadRegistrationTypes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join PickNdel'),
      ),
      body: Container(
        child: Form(
            key: _formKey,
            child: Padding(
                padding: EdgeInsets.only(left: 40.0, right: 40.0, bottom: 40.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/pickndell-logo-white.png',
                        width: MediaQuery.of(context).size.width * 0.70,
                        // height: MediaQuery.of(context).size.height * 0.50,
                        // width: 300,
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                      ),
                      Text(
                        'Registration Form',
                        style: whiteTitle,
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                      ),
                      DropdownButtonFormField(
                        decoration: InputDecoration(
                            labelText: "Registration as:",
                            prefixIcon: Icon(Icons.category)),
                        value: _userType,
                        items: _registrationTypes,
                        validator: (value) {
                          if (dropdownMenue(value) == null) {
                            return null;
                          } else {
                            return "Please choose a registration type";
                          }
                        },
                        onChanged: (value) {
                          setState(() {
                            print('dropdown: $value');
                            _userType = value;
                          });
                        },
                        // hint: Text("Registration as:"),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                      ),
                      TextFormField(
                        decoration: InputDecoration(
                            labelText: 'email', icon: Icon(Icons.person)),
                        controller: _mailController,
                        validator: (value) {
                          if (validateEmail(value) == null) {
                            return null;
                          } else {
                            return "Enter Valid Email";
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
                            labelText: 'password', icon: Icon(Icons.security)),
                        controller: _password1Controller,
                        obscureText: true,
                        validator: validatePassword,
                      ),

                      /////////////// confirm password ////////////

                      TextFormField(
                        decoration: InputDecoration(
                            labelText: 'confirm password',
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
                                        'I accept PickNdell terms',
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
                            return "Please accept PickNdell's terms and conditions";
                          } else {
                            return null;
                          }
                        },
                      ),

                      /////////////// SignUp Button ////////////

                      Padding(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: FlatButton(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  top: 8, bottom: 8, left: 10, right: 10),
                              child: Text(
                                _isLoading ? 'Creating...' : 'Create account',
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
                                        return _handleLogin();
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
                            'Already have an Account',
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
    // String msg = res["is_employee"] == "This field may not be null."
    //     ? "Please select Business or Carrier registration."
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
      title: 'Error',
      message: 'Please fill out all fields. $res',
      icon: Icon(
        Icons.info_outline,
        size: 28,
        color: Colors.white,
      ),
      duration: Duration(seconds: 5),
    )..show(context);
  }

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

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

      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => MessagePage(
                    messageType: "Registration",
                  )));
    } else {
      print("Failed registration process. Error: $res");
      errorRegistration(context, res);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _password2Controller.dispose();
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
