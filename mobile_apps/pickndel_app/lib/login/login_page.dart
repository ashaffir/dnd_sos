import 'package:bloc_login/common/global.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_login/repository/user_repository.dart';

import 'package:bloc_login/bloc/authentication_bloc.dart';
import 'package:bloc_login/login/bloc/login_bloc.dart';
import 'package:bloc_login/login/login_form.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatelessWidget {
  final UserRepository userRepository;

  LoginPage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PickNdel Login'),
      ),
      body: BlocProvider(
          create: (context) {
            return LoginBloc(
              authenticationBloc: BlocProvider.of<AuthenticationBloc>(context),
              userRepository: userRepository,
              // userRepository: Provider.of<UserRepository>(context),
            );
          },
          child: SingleChildScrollView(
            child: Column(
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
                  'Login Form',
                  style: whiteTitle,
                ),
                LoginForm(),
              ],
            ),
          )),
    );
  }
}
