import 'package:pickndell/localizations.dart';
import 'package:pickndell/model/order.dart';
import 'package:pickndell/repository/order_repository.dart';
import 'package:pickndell/ui/bottom_nav_bar.dart';
import 'package:pickndell/ui/progress_indicator.dart';
import 'package:flutter/material.dart';
import '../common/global.dart';

class OrderPickedup extends StatefulWidget {
  final Order order;
  OrderPickedup({this.order});

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
      future: updateOrderPickedup(widget.order),
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
        print('WAITING FOR UPDATE');
        String loaderText = translations.order_a_updating + "...";

        return ColoredProgressDemo(loaderText);
      },
    );
  }

  Future updateOrderPickedup(Order order) async {
    print('Order picked up');
    var orderId = order.order_id;
    final orderUpdated =
        await OrderRepository().updateOrder(orderId, 'IN_PROGRESS');
    print('orderUpdated: $orderUpdated');
    return orderUpdated;
  }

  Widget getOrderPickedupPage(Order order) {
    final translations = ExampleLocalizations.of(context);
    return new Scaffold(
      backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text(translations.order_p_picked),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 40, right: 40),
        height: 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Spacer(
              flex: 4,
            ),
            Text(
              translations.order_p_report,
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

  Widget orderPickedupErrorPage() {
    final translations = ExampleLocalizations.of(context);
    return new Scaffold(
      backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text(translations.order_p_picked),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 40),
        height: 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Spacer(
            //   flex: 4,
            // ),
            Text(
              translations.order_p_problem,
              style: bigLightBlueTitle,
            ),
            Padding(padding: EdgeInsets.only(top: 30.0)),
            Text(translations.order_p_update_pnd)
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
