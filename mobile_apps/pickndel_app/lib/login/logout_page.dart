import 'package:bloc_login/ui/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_login/bloc/authentication_bloc.dart';

import '../repository/user_repository.dart';
import 'login_page.dart';

class LogoutPage extends StatelessWidget {
  final UserRepository userRepository;

  LogoutPage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logout'),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.only(right: 40, left: 40, bottom: 40.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/pickndell-logo-white.png',
                  width: MediaQuery.of(context).size.width * 0.70,
                  // height: MediaQuery.of(context).size.height * 0.50,
                  // width: 300,
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30.0),
                  // child: Text(
                  //   'Logout Page',
                  //   style: TextStyle(
                  //     fontSize: 24.0,
                  //   ),
                  // ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Container(
                    // width: MediaQuery.of(context).size.width * 0.85,
                    // height: MediaQuery.of(context).size.width * 0.16,
                    child: RaisedButton(
                      child: Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      onPressed: () {
                        BlocProvider.of<AuthenticationBloc>(context)
                            .add(LoggedOut());
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginPage(
                                    userRepository: userRepository,
                                  )),
                          (Route<dynamic> route) => false,
                        );
                      },
                      shape: StadiumBorder(
                        side: BorderSide(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
