import 'package:flutter/material.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/location/geo_helpers.dart';
import 'package:pickndell/login/registration.dart';
import 'package:pickndell/repository/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WelcomePage extends StatefulWidget {
  final UserRepository userRepository;
  final String country;

  WelcomePage({this.userRepository, this.country});
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  void initState() {
    print('${widget.country}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return getWelcomePage(widget.userRepository);
  }

  _saveUserSelection(String userSelection) async {
    try {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      await localStorage.setString('userSelection', userSelection);
      print('SEVED SEL...');
    } catch (e) {
      print('*** Error *** Setting user selection. E: $e');
    }
  }

  Widget getWelcomePage(UserRepository userRepository) {
    final trans = ExampleLocalizations.of(context);
    return SafeArea(
      child: Stack(children: <Widget>[
        Positioned.fill(
          //
          child: Image(
            image: widget.country == 'IL' || widget.country == 'ישראל'
                ? AssetImage('assets/images/mobile-background-rtl.jpg')
                : AssetImage('assets/images/mobile-background.jpg'),
            fit: BoxFit.fill,
          ),
        ),
        Column(
          children: <Widget>[
            Spacer(),
            Row(
              children: <Widget>[
                Spacer(flex: 3),
                RaisedButton(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Text(
                        trans.welcome_send,
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        "(${trans.sender})",
                        style: TextStyle(color: Colors.black),
                      )
                    ],
                  ),
                  onPressed: () {
                    print('Send');
                    _saveUserSelection('Sender');
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => Registration(
                                  userSelection: 'Sender',
                                  // builder: (context) => LoginPage(
                                  //       userRepository: userRepository,
                                )));

                    // return getHomePageIsolate(currentUser);
                  },
                  color: Colors.green,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
                Spacer(flex: 1),
              ],
            ),
            Spacer(),
            Row(
              children: <Widget>[
                Spacer(flex: 1),
                RaisedButton(
                  padding: EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Text(
                        trans.welcome_deliver,
                        style: TextStyle(
                          fontSize: 24,
                        ),
                      ),
                      Text("(${trans.courier})")
                    ],
                  ),
                  color: ordersBackground,
                  onPressed: () {
                    print('Deliver');
                    // _saveUserSelection('Courier');
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            // builder: (context) => LoginPage(
                            builder: (context) => Registration(
                                  userSelection: 'Courier',
                                )));
                    // return getHomePageIsolate(currentUser);
                  },
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
                Spacer(flex: 3),
              ],
            ),
            Spacer(),
          ],
        )
        // Expanded(
        //   child: Container(
        //     child: Text('UPPER'),
        //   ),
        // ),
      ]),
    );
  }
}
