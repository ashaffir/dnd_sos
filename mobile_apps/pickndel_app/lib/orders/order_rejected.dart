import 'package:bloc_login/model/order.dart';
import 'package:bloc_login/repository/order_repository.dart';
import 'package:bloc_login/ui/bottom_nav_bar.dart';
import 'package:bloc_login/ui/progress_indicator.dart';
import 'package:flutter/material.dart';
import '../common/global.dart';

class OrderRejected extends StatefulWidget {
  final Order order;
  OrderRejected({this.order});

  @override
  _OrderRejectedState createState() => _OrderRejectedState();
}

class _OrderRejectedState extends State<OrderRejected> {
  @override
  void initState() {
    super.initState();
  }

  String orderUpdated;

  Widget build(BuildContext context) {
    return FutureBuilder(
      future: updateOrderRejected(widget.order),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          print('ORDER REJECTED: ${snapshot.data["response"]}');

          if (snapshot.data["response"] == "Update successful") {
            return getOrderRejectedPage(widget.order);
          } else if (snapshot.data["response"] == "Update failed") {
            return orderRejectedErrorPage();
          } else {
            return orderRejectedErrorPage();
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

  Future updateOrderRejected(Order order) async {
    print('Updating order delivered...');
    final orderUpdated = await OrderRepository().updateOrder(order, 'REJECTED');
    print('orderUpdated: $orderUpdated');
    return orderUpdated;
  }

  Widget getOrderRejectedPage(Order order) {
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
              "Order Canceled.",
              style: bigLightBlueTitle,
            ),
            Spacer(
              flex: 2,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }

  Widget orderRejectedErrorPage() {
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
