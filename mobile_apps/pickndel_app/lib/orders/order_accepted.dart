import 'package:pickndell/model/order.dart';
import 'package:pickndell/repository/order_repository.dart';
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
        String loaderText = "Updating Order...";
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
    return new Scaffold(
      backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text('Order Accepted'),
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
              "Go to pick up!",
              style: bigLightBlueTitle,
            ),
            Spacer(
              flex: 2,
            ),
            Text(
              'From: ${order["pick_up_address"]}',
              style: whiteTitle,
            ),
            Spacer(
              flex: 2,
            ),
            Text(
              "To: ${order["drop_off_address"]}",
              style: whiteTitle,
            )
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }

  Widget orderAcceptErrorPage() {
    return new Scaffold(
      backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text('Order Accepted'),
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
              "This order is no longer available!",
              style: bigLightBlueTitle,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}

// TODO: Add the pick and drop addresses coordinates

class MapUtils {
  MapUtils._();

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}
