import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_login/repository/user_repository.dart';

import 'package:bloc_login/bloc/authentication_bloc.dart';
import 'package:bloc_login/login/bloc/login_bloc.dart';
import 'package:bloc_login/login/login_form.dart';

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
            );
          },
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(3.0),
              ),
              // Image.asset(
              //   'assets/images/pickndel-logo-1.png',
              //   width: MediaQuery.of(context).size.width * 0.30,
              // ),
              LoginForm(),
            ],
          )),
    );
  }
}
