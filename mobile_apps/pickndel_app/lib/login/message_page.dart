import 'package:pickndell/common/global.dart';
import 'package:pickndell/home/home_page_isolate.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/model/order.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/orders/order_accepted.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pickndell/bloc/authentication_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:pickndell/ui/bottom_navigation_bar.dart';
import 'package:pickndell/ui/buttons.dart';

class MessagePage extends StatelessWidget {
  final String messageType;
  var data;
  var message;
  final String content;
  final Order order;
  final User user;

  MessagePage(
      {this.messageType,
      this.message,
      this.data,
      this.order,
      this.user,
      this.content});

  @override
  Widget build(BuildContext context) {
    final translations = ExampleLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: messageType == "Registration"
            ? Text(translations.messages_register_title)
            : messageType == "push"
                ? Text('${message["title"]}')
                : (messageType == 'statusOK' || messageType == "Error")
                    ? Text("")
                    : Text('$message'),
      ),
      body: Container(
        child: Padding(
          padding:
              const EdgeInsets.only(right: RIGHT_MARGINE, left: LEFT_MARGINE),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(padding: EdgeInsets.only(top: TOP_MARGINE)),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[]),
                messageType == 'statusOK'
                    ? Image.asset(
                        'assets/images/check-icon.png',
                        width: MediaQuery.of(context).size.width * 0.50,
                      )
                    : messageType == 'Error'
                        ? Image.asset(
                            'assets/images/fail-icon.png',
                            width: MediaQuery.of(context).size.width * 0.50,
                          )
                        : Image.asset(
                            'assets/images/pickndell-logo-white.png',
                            width: MediaQuery.of(context).size.width * 0.60,
                            // height: MediaQuery.of(context).size.height * 0.50,
                            // width: 300,
                          ),
                Padding(
                  padding: EdgeInsets.only(
                      top: 30.0, left: LEFT_MARGINE, right: RIGHT_MARGINE),
                  child: messageType == "Registration"
                      ? Text(translations.messages_register_thanks,
                          style: whiteTitle)
                      : messageType == "push"
                          ? Text(
                              '${message["body"]}',
                              style: whiteTitle,
                            )
                          : (messageType == "statusOK" ||
                                  messageType == "Error")
                              ? Text("")
                              : Text('$message'),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: messageType == "Registration"
                      ? Text(
                          translations.messages_register_activation,
                          style: TextStyle(
                            fontSize: 15.0,
                          ),
                        )
                      : messageType == "push"
                          ? Column(children: [
                              Text(translations.messages_register_pickup +
                                  ': ${data["pick_up_address"]}'),
                              Padding(
                                padding: EdgeInsets.only(bottom: 20.0),
                              ),
                              Text(translations.messages_register_drop +
                                  ': ${data["drop_off_address"]}'),
                              Padding(
                                padding: EdgeInsets.only(bottom: 20.0),
                              ),
                            ])
                          : messageType == "statusOK"
                              ? Text(
                                  "Your profile was updated",
                                  style: whiteTitle,
                                )
                              : messageType == "Error"
                                  ? Text(
                                      content,
                                      style: intrayTitleStyle,
                                    )
                                  : Text('$message'),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Container(
                    // width: MediaQuery.of(context).size.width * 0.85,
                    // height: MediaQuery.of(context).size.width * 0.16,
                    child: messageType == "Registration"
                        ? RaisedButton(
                            child: Text(
                              translations.messages_register_button,
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            onPressed: () {
                              BlocProvider.of<AuthenticationBloc>(context)
                                  .add(LoggedOut());
                              Phoenix.rebirth(context);
                            },
                            shape: StadiumBorder(
                              side: BorderSide(
                                color: Colors.black,
                                width: 2,
                              ),
                            ),
                          )
                        : messageType == "push"
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  ButtonBar(
                                    children: <Widget>[
                                      Padding(padding: EdgeInsets.all(5.0)),
                                      SizedBox(
                                        width: 80,
                                        child: RaisedButton(
                                          color: pickndellGreen,
                                          child: Text(
                                            translations.messages_push_accept,
                                            style: whiteButtonTitle,
                                          ),
                                          onPressed: () {
                                            print('Accepted Order');
                                            String newStatus = "STARTED";
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                                // HomePageIsolate(),
                                                if (messageType ==
                                                    "Registration") {
                                                  return OrderAccepted(
                                                    order: order,
                                                    user: user,
                                                  );
                                                } else if (messageType ==
                                                    "push") {
                                                  return OrderAccepted(
                                                    orderId: order.order_id,
                                                    user: user,
                                                  );
                                                } else {
                                                  print('ERROR Message type');
                                                }
                                              }),
                                              (Route<dynamic> route) =>
                                                  false, // No Back option for this page
                                            );
                                          },
                                        ),
                                      ),
                                      Padding(padding: EdgeInsets.all(5.0)),
                                      SizedBox(
                                        width: 80,
                                        child: RaisedButton(
                                          color: Colors.red[200],
                                          child: Text(
                                            translations.messages_push_ignore,
                                            style: whiteButtonTitle,
                                          ),
                                          onPressed: () {
                                            print('Ignored');
                                            Navigator.pop(context);
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              )
                            : (messageType == 'statusOK' ||
                                    messageType == "Error")
                                ? Text("")
                                : Text('$message'),
                  ),
                ),
                messageType != "Registration" ? DashboardButton() : Text(""),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: messageType == "Registration"
          ? Text("")
          : BottomNavigation(
              user: user,
            ),
    );
  }
}
