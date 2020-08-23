import 'package:flutter/material.dart';
import 'package:pickndell/dao/user_dao.dart';
import 'package:pickndell/home/home_page_isolate.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/repository/user_repository.dart';

class WelcomePage extends StatefulWidget {
  final UserRepository userRepository;

  WelcomePage({this.userRepository});
  @override
  _WelcomePageState createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return getWelcomePage(widget.userRepository);
  }

  Widget getWelcomePage(UserRepository userRepository) {
    return SafeArea(
      child: Stack(children: <Widget>[
        Positioned.fill(
          //
          child: Image(
            image: AssetImage('assets/images/mobile-background.jpg'),
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
                  child: Text(
                    'Send',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    print('Send');
                    Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => HomePageIsolate(
                                  userRepository: userRepository,
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
                  child: Text(
                    'Deliver',
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  color: Colors.brown[900],
                  onPressed: () {
                    print('Deliver');
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
