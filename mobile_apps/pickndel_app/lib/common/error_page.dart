import 'package:flutter/material.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/ui/bottom_navigation_bar.dart';
import 'package:pickndell/ui/buttons.dart';

class ErrorPage extends StatelessWidget {
  final String errorMessage;
  final User user;

  final Function onRetryPressed;

  const ErrorPage({Key key, this.errorMessage, this.onRetryPressed, this.user})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final trans = ExampleLocalizations.of(context);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text('Error'),
      // ),
      // backgroundColor: mainBackground,
      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.only(right: RIGHT_MARGINE, left: LEFT_MARGINE),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Spacer(
                flex: 1,
              ),
              Image.asset(
                'assets/images/error-icon.png',
                width: MediaQuery.of(context).size.width * 0.50,
              ),
              Spacer(
                flex: 1,
              ),

              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
              Spacer(
                flex: 2,
              ),
              user != null
                  ? DashboardButton()
                  : LoginButton(
                      buttonText: trans.back_to_login,
                    ),
              Spacer(
                flex: 3,
              )
              // SizedBox(height: 8),
              // RaisedButton(
              //   color: Colors.white,
              //   child: Text('Retry', style: TextStyle(color: Colors.black)),
              //   onPressed: onRetryPressed,
              // )
            ],
          ),
        ),
      ),
    );
  }
}
