import 'package:bloc_login/common/global.dart';
import 'package:flutter/material.dart';
import 'package:splashscreen/splashscreen.dart';

class SplashPage extends StatelessWidget {
  static Route route() {
    return MaterialPageRoute<void>(builder: (_) => SplashPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // body: Center(child: CircularProgressIndicator()),
        body: Column(
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
          'Loading PickNdell...',
          style: whiteTitle,
        ),
      ],
    ));
  }
}

// class SplashPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//
//       ),
//     );
//   }
// }
