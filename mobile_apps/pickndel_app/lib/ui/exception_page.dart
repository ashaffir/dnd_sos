import 'package:pickndell/common/global.dart';
import 'package:pickndell/home/home_page_isolate.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/model/order.dart';
import 'package:pickndell/orders/order_accepted.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pickndell/bloc/authentication_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class ExceptionPage extends StatelessWidget {
  final String messageType;
  final String message;

  ExceptionPage({this.messageType, this.message});

  @override
  Widget build(BuildContext context) {
    final translations = ExampleLocalizations.of(context);

    return Scaffold(
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
                  child: messageType == "Registration"
                      ? Text(translations.messages_register_thanks,
                          style: whiteTitle)
                      : messageType == "push"
                          ? Text(
                              '$message',
                              style: whiteTitle,
                            )
                          : Text('$message'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
