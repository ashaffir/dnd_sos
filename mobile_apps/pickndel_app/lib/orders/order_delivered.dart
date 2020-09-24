import 'package:pickndell/common/error_page.dart';
import 'package:pickndell/common/helper.dart';
import 'package:pickndell/home/dashboard.dart';
import 'package:pickndell/home/home_page_isolate.dart';
import 'package:pickndell/login/message_page.dart';
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

class OrderDelivered extends StatefulWidget {
  final Order order;
  final User user;
  OrderDelivered({this.order, this.user});

  @override
  _OrderDeliveredState createState() => _OrderDeliveredState();
}

class _OrderDeliveredState extends State<OrderDelivered> {
  @override
  void initState() {
    super.initState();
  }

  String orderUpdated;

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: updateOrderDelivered(widget.order),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          print('ORDER DELIVERED: ${snapshot.data["response"]}');

          if (snapshot.data["response"] == "Update successful") {
            return getOrderDeliveredPage(widget.order);
          } else if (snapshot.data["response"] == "Update failed") {
            return orderDeliveredErrorPage(user: widget.user);
          } else {
            return orderDeliveredErrorPage(user: widget.user);
          }
        } else {
          print("No data:");
        }
        print('WAITING FOR DELIVERY UPDATE');
        String loaderText = "Updating Order...";

        return ColoredProgressDemo(loaderText);
      },
    );
  }

  Future updateOrderDelivered(Order order) async {
    print('Updating order delivered...');
    var orderId = order.order_id;
    try {
      final orderUpdated = await OrderRepository(user: widget.user)
          .updateOrder(orderId, 'COMPLETED');
      print('orderUpdated: $orderUpdated');
      return orderUpdated;
    } catch (e) {
      print('BANK DETAILS: Failed updating bank details. ERROR: $e');
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => ErrorPage(
                    user: widget.user,
                    errorMessage:
                        "We apologize for the inconvenience, but your information was not updated. Please contact PickNdell support or/and try again later.",
                  )));
    }
  }

  Widget getOrderDeliveredPage(Order order) {
    return new Scaffold(
      body: Container(
        child: Padding(
          padding:
              const EdgeInsets.only(left: LEFT_MARGINE, right: RIGHT_MARGINE),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Spacer(
                flex: 3,
              ),
              Center(
                child: Text(
                  "Good Job!!!",
                  style: whiteTitle,
                ),
              ),
              Spacer(flex: 2),
              Center(
                child: Image.asset(
                  'assets/images/check-icon.png',
                  width: MediaQuery.of(context).size.width * 0.50,
                ),
              ),
              Spacer(flex: 4),
              Center(child: DashboardButton()),
              Spacer(flex: 4),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        user: widget.user,
      ),
    );
  }

  Widget orderDeliveredErrorPage({User user}) {
    return new Scaffold(
      body: Container(
        child: Padding(
          padding: EdgeInsets.only(left: LEFT_MARGINE, right: RIGHT_MARGINE),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Spacer(
                flex: 3,
              ),
              Text(
                "There was a problem updating this order. Please try again later.",
                style: whiteTitle,
              ),
              Spacer(flex: 2),
              Image.asset(
                'assets/images/crying-icon.png',
                width: MediaQuery.of(context).size.width * 0.50,
              ),
              Spacer(flex: 4),
              DashboardButton(),
              Spacer(flex: 4),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        user: user,
      ),
    );
  }
}
