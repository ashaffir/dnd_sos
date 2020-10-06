import 'package:pickndell/common/error_page.dart';
import 'package:pickndell/common/map_utils.dart';
import 'package:pickndell/home/dashboard.dart';
import 'package:pickndell/home/home_page_isolate.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/model/order.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/repository/order_repository.dart';
import 'package:pickndell/repository/user_repository.dart';
import 'package:pickndell/ui/bottom_nav_bar.dart';
import 'package:pickndell/ui/bottom_navigation_bar.dart';
import 'package:pickndell/ui/buttons.dart';
import 'package:pickndell/ui/progress_indicator.dart';
import 'package:flutter/material.dart';
import '../common/global.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderAccepted extends StatefulWidget {
  final Order order;
  final String orderId;
  final User user;

  OrderAccepted({this.order, this.orderId, this.user});

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
        print('WAITING FOR ORDER ACCEPTED UPDATE');
        String loaderText = translations.order_a_updating + "...";
        return ColoredProgressDemo(loaderText);
      },
    );
  }

  Future updateOrderAccepted(dynamic updateOrderId) async {
    print('UPDATINNG ORDER...');
    final trans = ExampleLocalizations.of(context);

    try {
      final orderUpdated =
          await OrderRepository(user: widget.user, context: context)
              .updateOrder(updateOrderId, 'STARTED');
      print('orderUpdated: $orderUpdated');
      return orderUpdated;
    } catch (e) {
      return Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ErrorPage(
              user: widget.user,
              errorMessage: trans.messages_communication_error,
            );
          },
        ),
        (Route<dynamic> route) => false, // No Back option for this page
      );
    }
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Spacer(
              flex: 2,
            ),
            Text(
              translations.order_a_go_to + "!",
              style: bigLightBlueTitle,
            ),
            Spacer(
              flex: 2,
            ),
            Text(
              '${translations.order_location}:  ${order["pick_up_address"]}',
              style: whiteTitle,
            ),
            Spacer(
              flex: 3,
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Spacer(
                  flex: 1,
                ),
                RaisedButton.icon(
                  label: Text(translations.navigate),
                  icon: Icon(
                    Icons.navigation,
                    color: pickndellGreen,
                  ),
                  color: Colors.transparent,
                  shape: StadiumBorder(side: BorderSide(color: pickndellGreen)),
                  onPressed: () {
                    MapUtils.openMap(
                        order["business_lat"], order["business_lon"]);
                  },
                ),
                Spacer(
                  flex: 1,
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
                Spacer(
                  flex: 1,
                ),
              ],
            ),
            Padding(padding: EdgeInsets.only(top: 30)),
            DashboardButton(
              buttonText: translations.back_to_dashboard,
            ),
            Spacer(
              flex: 3,
            ),

            // Text(
            //   translations.orders_to + ": ${order["drop_off_address"]}",
            //   style: whiteTitle,
            // )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        user: widget.user,
      ),
    );
  }

  Widget orderAcceptErrorPage() {
    final translations = ExampleLocalizations.of(context);

    return Scaffold(
      // backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text(translations.orders_error),
      ),
      body: Container(
        padding: EdgeInsets.only(left: LEFT_MARGINE, right: RIGHT_MARGINE),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Spacer(
                flex: 2,
              ),
              Text(
                translations.order_a_not_available + "!",
                style: bigLightBlueTitle,
              ),
              Spacer(
                flex: 2,
              ),
              DashboardButton(
                buttonText: translations.back_to_dashboard,
              ),
              Spacer(
                flex: 4,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        user: widget.user,
      ),
    );
  }
}
