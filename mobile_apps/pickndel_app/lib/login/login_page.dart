import 'package:pickndell/common/global.dart';
import 'package:pickndell/login/login_form_screen.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pickndell/repository/user_repository.dart';

import 'package:pickndell/bloc/authentication_bloc.dart';
import 'package:pickndell/login/bloc/login_bloc.dart';

class LoginPage extends StatefulWidget {
  final UserRepository userRepository;

  LoginPage({Key key, this.userRepository});
  // : assert(userRepository != null),
  //   super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

UserRepository _getUserRepo(userRepository) {
  if (userRepository == null) {
    print('NULL USER REPO');
    UserRepository().deleteToken(id: 0);
    return UserRepository();
  } else {
    return userRepository;
  }
}

class _LoginPageState extends State<LoginPage> {
  LoginBloc _loginBloc;
  AuthenticationBloc _authenticationBloc;

  UserRepository get _userRepository => widget.userRepository;

  @override
  void initState() {
    _authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    _loginBloc = LoginBloc(
      userRepository: _getUserRepo(_userRepository),
      authenticationBloc: _authenticationBloc,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PickNdel Login'),
      ),
      body: LoginFormScreen(
          authenticationBloc: _authenticationBloc, loginBloc: _loginBloc),
    );
  }

  @override
  void dispose() {
    _loginBloc.close();
    super.dispose();
  }
}
