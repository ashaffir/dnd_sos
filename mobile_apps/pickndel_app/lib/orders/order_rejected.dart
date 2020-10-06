import 'package:pickndell/common/error_page.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/model/order.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/repository/order_repository.dart';
import 'package:pickndell/ui/bottom_navigation_bar.dart';
import 'package:pickndell/ui/progress_indicator.dart';
import 'package:flutter/material.dart';
import '../common/global.dart';

class OrderRejected extends StatefulWidget {
  final Order order;
  final User user;
  OrderRejected({this.order, this.user});

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
    final translations = ExampleLocalizations.of(context);

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
        print('WAITING FOR ORDER REJECTED UPDATE');
        String loaderText = "Updating Order...";

        return ColoredProgressDemo(loaderText);
      },
    );
  }

  Future updateOrderRejected(Order order) async {
    final trans = ExampleLocalizations.of(context);

    print('Updating order delivered...');
    try {
      var orderId = order.order_id;
      final orderUpdated =
          await OrderRepository(context: context, user: widget.user)
              .updateOrder(orderId, 'REJECTED');
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

  Widget getOrderRejectedPage(Order order) {
    final translations = ExampleLocalizations.of(context);

    return new Scaffold(
      // backgroundColor: mainBackground,
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
              translations.order_cancel_message,
              style: bigLightBlueTitle,
            ),
            Spacer(
              flex: 2,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        user: widget.user,
      ),
    );
  }

  Widget orderRejectedErrorPage() {
    final translations = ExampleLocalizations.of(context);

    return new Scaffold(
      // backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text(translations.order_delivered),
      ),
      body: Container(
        // padding: EdgeInsets.only(left: 50),
        child: Padding(
          padding:
              const EdgeInsets.only(left: LEFT_MARGINE, right: RIGHT_MARGINE),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Spacer(
                flex: 2,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      translations.order_p_problem,
                      style: bigLightBlueTitle,
                    ),
                  ),
                ],
              ),
              Spacer(
                flex: 2,
              ),
              Image.asset(
                'assets/images/fail-icon.png',
                width: MediaQuery.of(context).size.width * 0.50,
              ),
              Spacer(
                flex: 2,
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
