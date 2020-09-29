import 'package:pickndell/common/error_page.dart';
import 'package:pickndell/common/helper.dart';

import 'package:pickndell/localizations.dart';
import 'package:pickndell/model/order.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/repository/order_repository.dart';
import 'package:pickndell/ui/bottom_navigation_bar.dart';
import 'package:pickndell/ui/buttons.dart';
import 'package:pickndell/ui/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../common/global.dart';

class OrderPickedup extends StatefulWidget {
  final Order order;
  final User user;
  OrderPickedup({this.order, this.user});

  @override
  _OrderPickedupState createState() => _OrderPickedupState();
}

class _OrderPickedupState extends State<OrderPickedup> {
  @override
  void initState() {
    super.initState();
  }

  String orderUpdated;

  Widget build(BuildContext context) {
    final translations = ExampleLocalizations.of(context);
    return FutureBuilder(
      future: updateOrderPickedup(widget.order, widget.user),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          print('ORDER PICKED UP: ${snapshot.data["response"]}');

          if (snapshot.data["response"] == "Update successful") {
            return getOrderPickedupPage(widget.order);
          } else if (snapshot.data["response"] == "Update failed") {
            return orderPickedupErrorPage();
          } else {
            return orderPickedupErrorPage();
          }
        } else {
          print("No data:");
        }
        print('WAITING FOR ORDER PICKUP UPDATE');
        String loaderText = translations.order_a_updating + "...";

        return ColoredProgressDemo(loaderText);
      },
    );
  }

  Future updateOrderPickedup(Order order, User user) async {
    print('Order picked up');
    var orderId = order.order_id;
    try {
      final orderUpdated =
          await OrderRepository(user: user).updateOrder(orderId, 'IN_PROGRESS');
      print('orderUpdated: $orderUpdated');
      return orderUpdated;
    } catch (e) {
      print('Failed report order picked up. E: $e');
      return ErrorPage(
        user: user,
        errorMessage:
            'There was a problem reporting the pick up of the order. Please try again later.',
      );
    }
  }

  Widget getOrderPickedupPage(Order order) {
    final translations = ExampleLocalizations.of(context);
    return new Scaffold(
      // backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text(translations.order_p_picked),
      ),
      body: Container(
        padding: EdgeInsets.only(left: LEFT_MARGINE, right: RIGHT_MARGINE),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Spacer(
              flex: 2,
            ),
            Text(
              translations.order_p_report,
              style: bigLightBlueTitle,
            ),
            Spacer(
              flex: 2,
            ),
            Image.asset(
              'assets/images/check-icon.png',
              width: MediaQuery.of(context).size.width * 0.50,
            ),
            Spacer(
              flex: 4,
            ),
            DashboardButton(),
            Spacer(
              flex: 4,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        user: widget.user,
      ),
    );
  }

  Widget orderPickedupErrorPage() {
    final translations = ExampleLocalizations.of(context);
    return new Scaffold(
      backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text(translations.order_p_picked),
      ),
      body: Container(
        padding: EdgeInsets.only(left: LEFT_MARGINE, right: RIGHT_MARGINE),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Spacer(
              flex: 2,
            ),
            Text(
              translations.order_p_problem,
              style: bigLightBlueTitle,
            ),
            Spacer(
              flex: 2,
            ),
            Image.asset(
              'assets/images/fail-icon.png',
              width: MediaQuery.of(context).size.width * 0.50,
            ),
            Spacer(
              flex: 4,
            ),
            Row(
              children: [
                Text(translations.order_p_update_pnd),
                Padding(padding: EdgeInsets.only(right: 10)),
                IconButton(
                    icon: Icon(Icons.email),
                    onPressed: () {
                      print('Contact email sent');
                      launch(_emailLaunchUri.toString());
                    }),
              ],
            ),
            Spacer(
              flex: 2,
            ),
            DashboardButton(),
            Spacer(
              flex: 4,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        user: widget.user,
      ),
    );
  }

  final Uri _emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'info@pickndell.com',
      queryParameters: {'subject': 'PickNdell Support - Error Updating Order'});
}
