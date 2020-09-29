import 'package:pickndell/common/error_page.dart';
import 'package:pickndell/model/order.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/repository/order_repository.dart';
import 'package:pickndell/ui/bottom_nav_bar.dart';
import 'package:pickndell/ui/bottom_navigation_bar.dart';
import 'package:pickndell/ui/buttons.dart';
import 'package:pickndell/ui/progress_indicator.dart';
import 'package:flutter/material.dart';
import '../common/global.dart';

class OrderReRequested extends StatefulWidget {
  final Order order;
  final User user;
  OrderReRequested({this.order, this.user});

  @override
  _OrderReRequestedState createState() => _OrderReRequestedState();
}

class _OrderReRequestedState extends State<OrderReRequested> {
  @override
  void initState() {
    super.initState();
  }

  String orderUpdated;

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: updateOrderReRequested(widget.order, widget.user),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          print('ORDER RE-REQUESTED: ${snapshot.data["response"]}');

          if (snapshot.data["response"] == "Update successful") {
            return getOrderReRequestedPage(widget.order);
          } else if (snapshot.data["response"] == "Update failed") {
            return orderReRequestedErrorPage();
          } else {
            return orderReRequestedErrorPage();
          }
        } else {
          print("No data:");
        }
        print('WAITING FOR ORDER RE_REQUEST UPDATE');
        String loaderText = "Updating Order...";

        return ColoredProgressDemo(loaderText);
      },
    );
  }

  Future updateOrderReRequested(Order order, User user) async {
    print('Broadcasting order re-request...');
    var orderId = order.order_id;
    try {
      final orderUpdated = await OrderRepository(user: user)
          .updateOrder(orderId, 'RE_REQUESTED');
      print('orderUpdated: $orderUpdated');
      return orderUpdated;
    } catch (e) {
      print('Faled Re-Requesting the order. ERROR: $e');
      return ErrorPage(
        user: user,
        errorMessage:
            'There was a problem broadcasting the order. Please try again later.',
      );
    }
  }

  Widget getOrderReRequestedPage(Order order) {
    return new Scaffold(
      backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text('Order Broadcast'),
      ),
      body: Container(
        padding: EdgeInsets.only(right: RIGHT_MARGINE, left: LEFT_MARGINE),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Spacer(
              flex: 2,
            ),
            Text(
              "Order Broadcast Completed.",
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

  Widget orderReRequestedErrorPage() {
    return new Scaffold(
      backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text('Order Broadcast'),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 50),
        height: 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Spacer(
              flex: 4,
            ),
            Text(
              "There was a problem updating this order",
              style: bigLightBlueTitle,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        user: widget.user,
      ),
    );
  }
}
