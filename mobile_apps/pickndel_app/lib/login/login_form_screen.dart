import 'package:pickndell/bloc/authentication_bloc.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/common/helper.dart';
import 'package:pickndell/home/prominent_disclosure.dart';
import 'package:pickndell/home/welcome.dart';
import 'package:pickndell/localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'bloc/login_bloc.dart';

class LoginFormScreen extends StatefulWidget {
  final LoginBloc loginBloc;
  final AuthenticationBloc authenticationBloc;

  LoginFormScreen({
    Key key,
    @required this.loginBloc,
    @required this.authenticationBloc,
  }) : super(key: key);

  @override
  State<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String _country;
  bool _isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  LoginBloc get _loginBloc => widget.loginBloc;

  Future checkCountry() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    _country = localStorage.getString('userCountry');
  }

  bool disclosureStatus;
  bool disclosureCurrent;

  Future checkDisclosure() async {
    SharedPreferences localstorage = await SharedPreferences.getInstance();
    disclosureCurrent = localstorage.getBool('disclosure');
    if (disclosureCurrent == null) {
      prominentDisclosure(context);
      setState(() {
        disclosureStatus = localstorage.getBool('disclosure');
        print('>>> Set new disclosure: $disclosureStatus');
      });
    } else {
      disclosureStatus = disclosureCurrent;
      print('>>> Set current disclosure: $disclosureStatus');
    }
  }

  @override
  void initState() {
    checkCountry();
    checkDisclosure();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final translations = ExampleLocalizations.of(context);
    return BlocBuilder<LoginBloc, LoginState>(
      bloc: _loginBloc,
      builder: (
        BuildContext context,
        LoginState state,
      ) {
        if (state is LoginFaliure) {
          _isLoading = false;
          _onWidgetDidBuild(() {
            String errorMessage = state.error.split(" ")[0];
            if (errorMessage == 'FormatException:') {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  // content: Text('${state.error}'),
                  content: Text(
                    'We are experiencing communication issues. Please make sure you are connected to the internet, try again later and/or visit our website.',
                    style: intrayTitleStyle,
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 10),
                ),
              );
            } else {
              Scaffold.of(context).showSnackBar(
                SnackBar(
                  // content: Text('${state.error}'),
                  content: Text(
                    'Wrong credentials used. Please make sure your account is activated and try again.',
                    style: intrayTitleStyle,
                  ),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 10),
                ),
              );
            }
          });
        }

        return Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.only(right: 40.0, left: 40.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/pickndell-logo-white.png',
                    width: MediaQuery.of(context).size.width * 0.60,
                    // height: MediaQuery.of(context).size.height * 0.50,
                    // width: 300,
                  ),
                  /////////////// Username/Email ////////////
                  Padding(padding: EdgeInsets.only(bottom: 20)),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextFormField(
                      decoration: InputDecoration(
                          // labelText: 'email', icon: Icon(Icons.person)),
                          labelText: translations.email,
                          icon: Icon(Icons.person)),
                      controller: _usernameController,
                      validator: (value) {
                        if (validateEmail(value) == null) {
                          return null;
                        } else {
                          return translations.alert_email;
                        }
                      },
                    ),
                  ),

                  /////////////// Password ////////////

                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: TextFormField(
                      decoration: InputDecoration(
                          labelText: translations.password,
                          icon: Icon(Icons.security)),
                      // labelText: AppLocalizations.of(contex).translate('password'), icon: Icon(Icons.security)),
                      controller: _passwordController,
                      obscureText: true,
                      validator: (value) {
                        if (validatePassword(value) == null) {
                          return null;
                        } else {
                          return translations.alert_password;
                        }
                      },
                    ),
                  ),
                  /////////////// Forgot password ////////////

                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(padding: EdgeInsets.only(top: 30)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RaisedButton(
                            onPressed: () {
                              if (!_formKey.currentState.validate()) {
                                return;
                              } else {
                                if (state is! LoginLoading) {
                                  _onLoginButtonPressed();
                                }
                              }
                            },
                            child: Text(!_isLoading
                                ? translations.login
                                : translations.logging_in),
                            color: !_isLoading ? Colors.red : Colors.grey,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                                side: BorderSide(color: Colors.red)),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child:
                            // InkWell(
                            Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FlatButton(
                              onPressed: _launchURL,
                              child: Text(
                                translations.forgot_password,
                                textDirection: TextDirection.ltr,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.0,
                                  decoration: TextDecoration.none,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    child: state is LoginLoading
                        ? CircularProgressIndicator()
                        : null,
                  ),
                  /////////////// Dont have an account ////////////

                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                // builder: (context) => Registration()));
                                builder: (context) => WelcomePage(
                                      country: _country,
                                    )));
                      },
                      child: Text(
                        translations.create_account,
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
            ),
          ),
        );
      },
    );
  }

  void _onWidgetDidBuild(Function callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback();
    });
  }

  _onLoginButtonPressed() {
    setState(() {
      _isLoading = true;
    });
    _loginBloc.add(LoginButtonPressed(
      username: _usernameController.text,
      password: _passwordController.text,
    ));
  }

  _launchURL() async {
    const url = 'https://pickndell.com/core/forgot-password/';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not open $url';
    }
  }
}
