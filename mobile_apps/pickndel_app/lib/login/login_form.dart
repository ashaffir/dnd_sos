import 'package:bloc_login/common/helper.dart';
import 'package:bloc_login/login/registration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_login/login/bloc/login_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginForm extends StatefulWidget {
  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    _onLoginButtonPressed() {
      setState(() {
        _isLoading = true;
      });
      BlocProvider.of<LoginBloc>(context).add(LoginButtonPressed(
        username: _usernameController.text,
        password: _passwordController.text,
      ));
    }

    return BlocListener<LoginBloc, LoginState>(
      listener: (context, state) {
        if (state is LoginFaliure) {
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Failed to login: ${state.error}'),
            backgroundColor: Colors.red,
          ));
        }
      },
      child: BlocBuilder<LoginBloc, LoginState>(
        builder: (context, state) {
          return Container(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(40.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    /////////////// Username/Email ////////////

                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'email', icon: Icon(Icons.person)),
                      controller: _usernameController,
                      validator: (value) {
                        if (validateEmail(value) == null) {
                          return null;
                        } else {
                          return "Please enter a valid email";
                        }
                      },
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                          labelText: 'password', icon: Icon(Icons.security)),
                      controller: _passwordController,
                      obscureText: true,
                      validator: (value) {
                        if (validatePassword(value) == null) {
                          return null;
                        } else {
                          return "Please enter password.";
                        }
                      },
                    ),

                    /////////////// Forgot password ////////////

                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child:
                              // InkWell(
                              FlatButton(
                            onPressed: _launchURL,
                            child: Text(
                              'Forgot your password?',
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10.0,
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    /////////////// Login Button ////////////

                    Container(
                      // width: MediaQuery.of(context).size.width * 0.55,
                      // height: MediaQuery.of(context).size.width * 0.22,
                      child: Padding(
                        padding: EdgeInsets.only(top: 30.0),
                        child: Column(
                          children: <Widget>[
                            RaisedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      if (!_formKey.currentState.validate()) {
                                        return;
                                      } else {
                                        // state != LoginLoading()
                                        //     ? _onLoginButtonPressed()
                                        //     : null;
                                        if (state != LoginLoading()) {
                                          return _onLoginButtonPressed();
                                        } else {
                                          print('FINISHED');
                                          setState(() {
                                            _isLoading = false;
                                          });
                                          return null;
                                        }
                                      }
                                    },

                              // () {
                              //   if (state != LoginLoading()) {
                              //     return _onLoginButtonPressed();
                              //   } else {
                              //     return null;
                              //   }
                              // },

                              child: Text(
                                // state is! LoginLoading ? 'Login' : 'Logging in',
                                _isLoading ? 'Loggin in...' : 'Login',
                                style: TextStyle(
                                  fontSize: 15.0,
                                ),
                              ),
                              shape: StadiumBorder(
                                side: BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(top: 20.0),
                            ),

                            //////////// Horizontal line  ////////////

                            // Padding(
                            //   padding: EdgeInsets.symmetric(horizontal: 10.0),
                            //   child: Container(
                            //     height: 1.0,
                            //     color: Colors.white,
                            //   ),
                            // ),
                            // Padding(
                            //   padding: EdgeInsets.only(top: 20.0),
                            // ),

                            /////////////// Dont have an account ////////////

                            Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      new MaterialPageRoute(
                                          builder: (context) =>
                                              Registration()));
                                },
                                child: Text(
                                  'Create a new account',
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
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
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
