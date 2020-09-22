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
            return orderDeliveredErrorPage();
          } else {
            return orderDeliveredErrorPage();
          }
        } else {
          print("No data:");
        }
        print('WAITING FOR UPDATE');
        String loaderText = "Updating Order...";

        return ColoredProgressDemo(loaderText);
      },
    );
  }

  Future updateOrderDelivered(Order order) async {
    print('Updating order delivered...');
    var orderId = order.order_id;
    try {
      final orderUpdated =
          await OrderRepository().updateOrder(orderId, 'COMPLETED');
      print('orderUpdated: $orderUpdated');
      return orderUpdated;
    } catch (e) {
      print('BANK DETAILS: Failed updating bank details. ERROR: $e');
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => MessagePage(
                    user: widget.user,
                    messageType: "Error",
                    content:
                        "We apologize for the inconvenience, but your information was not updated. Please contact PickNdell support or/and try again later.",
                  )));
    }
  }

  Widget getOrderDeliveredPage(Order order) {
    return new Scaffold(
      backgroundColor: mainBackground,
      // appBar: AppBar(
      //   title: Text('Order Delivered'),
      // ),
      body: Container(
        padding: EdgeInsets.only(left: LEFT_MARGINE, right: RIGHT_MARGINE),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Text(
              "Good Job!!!",
              style: bigLightBlueTitle,
            ),
            Image.asset(
              'assets/images/like-face.png',
              width: MediaQuery.of(context).size.width * 0.50,
            ),

            FlatButton(
              child: Text('Back To Main Page'),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return Dashboard(
                        userRepository: UserRepository(),
                      );
                    },
                  ),
                  (Route<dynamic> route) =>
                      false, // No Back option for this page
                );
              },
              color: pickndellGreen,
            ),
            // Text(
            //   'From: ${order.pick_up_address}',
            //   style: whiteTitle,
            // ),
            // Spacer(
            //   flex: 2,
            // ),
            // Text(
            //   "To: ${order.drop_off_address}",
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

  Widget orderDeliveredErrorPage() {
    return new Scaffold(
      backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text('Order Delivered'),
      ),
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
              Spacer(flex: 6),
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
