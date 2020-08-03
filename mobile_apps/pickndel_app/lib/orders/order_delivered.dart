import 'package:bloc_login/model/order.dart';
import 'package:bloc_login/repository/order_repository.dart';
import 'package:bloc_login/ui/bottom_nav_bar.dart';
import 'package:bloc_login/ui/progress_indicator.dart';
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
    final orderUpdated =
        await OrderRepository().updateOrder(order, 'COMPLETED');
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
