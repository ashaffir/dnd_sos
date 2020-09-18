import 'package:pickndell/common/map_utils.dart';
import 'package:pickndell/home/home_page_isolate.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/model/order.dart';
import 'package:pickndell/repository/order_repository.dart';
import 'package:pickndell/repository/user_repository.dart';
import 'package:pickndell/ui/bottom_nav_bar.dart';
import 'package:pickndell/ui/progress_indicator.dart';
import 'package:flutter/material.dart';
import '../common/global.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderAccepted extends StatefulWidget {
  final Order order;
  final String orderId;

  OrderAccepted({this.order, this.orderId});

  @override
  _OrderAcceptedState createState() => _OrderAcceptedState();
}

class _OrderAcceptedState extends State<OrderAccepted> {
  var updatedOrderId;
  @override
  void initState() {
    super.initState();
    try {
      updatedOrderId = widget.order.order_id;
    } catch (e) {
      updatedOrderId = widget.orderId;
    }
  }

  String orderUpdated;

  Widget build(BuildContext context) {
    final translations = ExampleLocalizations.of(context);
    return FutureBuilder(
      future: updateOrderAccepted(updatedOrderId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          print('ORDER ACCEPTED: ${snapshot.data}');

          if (snapshot.data["response"] == "Update successful") {
            return getOrderAcceptedPage(snapshot.data);
          } else if (snapshot.data["response"] == "Update failed") {
            return orderAcceptErrorPage();
          } else {
            return orderAcceptErrorPage();
          }
        } else {
          print("No data:");
        }
        print('WAITING FOR UPDATE');
        String loaderText = translations.order_a_updating + "...";
        return ColoredProgressDemo(loaderText);
      },
    );
  }

  Future updateOrderAccepted(dynamic updateOrderId) async {
    print('UPDATINNG ORDER...');
    final orderUpdated =
        await OrderRepository().updateOrder(updateOrderId, 'STARTED');
    print('orderUpdated: $orderUpdated');
    return orderUpdated;
  }

  Widget getOrderAcceptedPage(dynamic order) {
    final translations = ExampleLocalizations.of(context);

    return Scaffold(
      // backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text(translations.order_a_accepted),
        backgroundColor: mainBackground,
      ),
      body: Container(
        padding: EdgeInsets.only(left: 30, right: 30),
        height: 260,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Spacer(
              flex: 4,
            ),
            Text(
              translations.order_a_go_to + "!",
              style: bigLightBlueTitle,
            ),
            Spacer(
              flex: 2,
            ),
            Text(
              "Location:" + ' ${order["pick_up_address"]}',
              style: whiteTitle,
            ),
            Spacer(
              flex: 3,
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 30),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RaisedButton.icon(
                  icon: Icon(Icons.navigation),
                  color: pickndellGreen,
                  shape: StadiumBorder(side: BorderSide(color: Colors.black)),
                  onPressed: () {
                    MapUtils.openMap(
                        order["business_lat"], order["business_lon"]);
                  },
                  label: Text('Navigate'),
                ),
                Padding(
                  padding: EdgeInsets.only(right: 10.0),
                ),
                RaisedButton.icon(
                  icon: Icon(Icons.phone),
                  color: Colors.blue,
                  shape: StadiumBorder(side: BorderSide(color: Colors.black)),
                  onPressed: () {
                    launch(('tel://${order["business_phone"]}'));
                  },
                  label: Text(translations.orders_call_sender),
                ),
              ],
            )
            // Text(
            //   translations.orders_to + ": ${order["drop_off_address"]}",
            //   style: whiteTitle,
            // )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }

  Widget orderAcceptErrorPage() {
    final translations = ExampleLocalizations.of(context);

    return Scaffold(
      // backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text(translations.order_a_accepted),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 20),
        height: 260,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Spacer(
                flex: 4,
              ),
              Text(
                translations.order_a_not_available + "!",
                style: bigLightBlueTitle,
              ),
              Spacer(
                flex: 4,
              ),
              FlatButton(
                child: Text('Back To Main Page'),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return HomePageIsolate(
                          userRepository: UserRepository(),
                        );
                      },
                    ),
                    (Route<dynamic> route) =>
                        false, // No Back option for this page
                  );
                },
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
