import 'package:background_locator/background_locator.dart';
import 'package:flutter/rendering.dart';
import 'package:pickndell/bloc/authentication_bloc.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/repository/user_repository.dart';
import 'package:pickndell/ui/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:pickndell/ui/bottom_navigation_bar.dart';

class LogoutPage extends StatelessWidget {
  final UserRepository userRepository;
  final User user;

  LogoutPage({Key key, @required this.userRepository, this.user})
      : assert(userRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final translatios = ExampleLocalizations.of(context);
    final AuthenticationBloc authenticationBloc =
        BlocProvider.of<AuthenticationBloc>(context);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(translatios.logout),
      // ),
      body: SafeArea(
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(
                  top: 40,
                )),
                Image.asset(
                  'assets/images/pickndell-logo-white.png',
                  width: MediaQuery.of(context).size.width * 0.60,
                ),
                Padding(
                    padding: EdgeInsets.only(
                  top: 40,
                )),
                Center(
                    child: RaisedButton(
                        child: Text(translatios.logout),
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(BUTTON_BORDER_RADIUS),
                            side: BorderSide(color: Colors.red)),
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
      ),
      bottomNavigationBar: BottomNavigation(
        user: user,
      ),
    );
  }
}
