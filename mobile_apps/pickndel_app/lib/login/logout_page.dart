import 'package:background_locator/background_locator.dart';
import 'package:pickndell/bloc/authentication_bloc.dart';
import 'package:pickndell/repository/user_repository.dart';
import 'package:pickndell/ui/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class LogoutPage extends StatelessWidget {
  final UserRepository userRepository;

  LogoutPage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthenticationBloc authenticationBloc =
        BlocProvider.of<AuthenticationBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Logout'),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Image.asset(
                'assets/images/pickndell-logo-white.png',
                width: MediaQuery.of(context).size.width * 0.70,
              ),
              Center(
                  child: RaisedButton(
                      child: Text('logout'),
                      onPressed: () {
                        BackgroundLocator.unRegisterLocationUpdate();
                        BlocProvider.of<AuthenticationBloc>(context)
                            .add(LoggedOut());
                        Phoenix.rebirth(context);
                      })),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(userRepository: userRepository),
    );
  }
}
