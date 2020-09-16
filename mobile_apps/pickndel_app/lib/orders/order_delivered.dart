import 'package:pickndell/common/helper.dart';
import 'package:pickndell/home/home_page_isolate.dart';
import 'package:pickndell/model/order.dart';
import 'package:pickndell/repository/order_repository.dart';
import 'package:pickndell/repository/user_repository.dart';
import 'package:pickndell/ui/bottom_nav_bar.dart';
import 'package:pickndell/ui/progress_indicator.dart';
import 'package:flutter/material.dart';
import '../common/global.dart';

class OrderDelivered extends StatefulWidget {
  final Order order;
  OrderDelivered({this.order});

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
    final orderUpdated =
        await OrderRepository().updateOrder(orderId, 'COMPLETED');
    print('orderUpdated: $orderUpdated');
    return orderUpdated;
  }

  Widget getOrderDeliveredPage(Order order) {
    return new Scaffold(
      backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text('Order Delivered'),
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
              "Good Job!!!",
              style: bigLightBlueTitle,
            ),
            Spacer(
              flex: 2,
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
      bottomNavigationBar: BottomNavBar(),
    );
  }

  Widget orderDeliveredErrorPage() {
    return new Scaffold(
      backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text('Order Delivered'),
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
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
