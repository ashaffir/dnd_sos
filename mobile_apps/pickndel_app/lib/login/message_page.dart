import 'package:bloc_login/common/global.dart';
import 'package:bloc_login/home/home_page_isolate.dart';
import 'package:bloc_login/model/order.dart';
import 'package:bloc_login/orders/order_accepted.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_login/bloc/authentication_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

class MessagePage extends StatelessWidget {
  final String messageType;
  var data;
  var message;
  final Order order;

  MessagePage({this.messageType, this.message, this.data, this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: messageType == "Registration"
            ? Text('Confirmation')
            : messageType == "push"
                ? Text('${message["title"]}')
                : Text('$message'),
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
                  child: messageType == "Registration"
                      ? Text('Thank you.', style: whiteTitle)
                      : messageType == "push"
                          ? Text(
                              '${message["body"]}',
                              style: whiteTitle,
                            )
                          : Text('$message'),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 30.0, top: 30.0),
                  child: messageType == "Registration"
                      ? Text(
                          'We have sent you an activation email. Please check your email box and to activate your account.',
                          style: TextStyle(
                            fontSize: 15.0,
                          ),
                        )
                      : messageType == "push"
                          ? Column(children: [
                              Text(
                                  'Pick up address: ${data["pick_up_address"]}'),
                              Padding(
                                padding: EdgeInsets.only(bottom: 20.0),
                              ),
                              Text(
                                  'Drop off address: ${data["drop_off_address"]}'),
                              Padding(
                                padding: EdgeInsets.only(bottom: 20.0),
                              ),
                            ])
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
                              'Go to Login',
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
                                          color: Colors.green,
                                          child: Text(
                                            "Accept",
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
                                                      order: order);
                                                } else if (messageType ==
                                                    "push") {
                                                  return OrderAccepted(
                                                      orderId: order.order_id);
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
                                            "Ignore",
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
                            : Text('$message'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
