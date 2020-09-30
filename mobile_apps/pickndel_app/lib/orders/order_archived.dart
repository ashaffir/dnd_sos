import 'package:pickndell/localizations.dart';
import 'package:pickndell/model/order.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/repository/order_repository.dart';
import 'package:pickndell/ui/bottom_navigation_bar.dart';
import 'package:pickndell/ui/buttons.dart';
import 'package:pickndell/ui/progress_indicator.dart';
import 'package:flutter/material.dart';
import '../common/global.dart';

class OrderArchived extends StatefulWidget {
  final Order order;
  final String orderId;
  final User user;

  OrderArchived({this.order, this.orderId, this.user});

  @override
  _OrderArchivedState createState() => _OrderArchivedState();
}

class _OrderArchivedState extends State<OrderArchived> {
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
    final translations = ExampleLocalizations.of(context);
    return FutureBuilder(
      future: updateOrderArchived(updatedOrderId),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          print('ORDER ARHIVED: ${snapshot.data}');

          if (snapshot.data["response"] == "Update successful") {
            return getOrderArchivedPage(snapshot.data);
          } else if (snapshot.data["response"] == "Update failed") {
            return orderArchiveErrorPage();
          } else {
            return orderArchiveErrorPage();
          }
        } else {
          print("No data:");
        }
        print('WAITING FOR ORDER ARCHIVED UPDATE');
        String loaderText = translations.order_a_updating + "...";
        return ColoredProgressDemo(loaderText);
      },
    );
  }

  Future updateOrderArchived(dynamic updateOrderId) async {
    print('UPDATINNG ORDER...');
    final orderUpdated =
        await OrderRepository(user: widget.user, context: context)
            .updateOrder(updateOrderId, 'ARCHIVED');
    print('orderUpdated: $orderUpdated');
    return orderUpdated;
  }

  Widget getOrderArchivedPage(dynamic order) {
    final translations = ExampleLocalizations.of(context);

    return Scaffold(
      // backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text(translations.order_cancel_message),
        backgroundColor: mainBackground,
      ),
      body: Container(
        padding: EdgeInsets.only(left: LEFT_MARGINE, right: RIGHT_MARGINE),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Spacer(
                    flex: 2,
                  ),
                  Text(
                    translations.order_cenceled_successfuly,
                    style: bigLightBlueTitle,
                  ),
                  Spacer(
                    flex: 2,
                  ),
                  Image.asset(
                    'assets/images/check-icon.png',
                    width: MediaQuery.of(context).size.width * 0.50,
                  ),
                  Padding(padding: EdgeInsets.only(top: 30)),
                  DashboardButton(
                    buttonText: translations.back_to_dashboard,
                  ),
                  Spacer(
                    flex: 3,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        user: widget.user,
      ),
    );
  }

  Widget orderArchiveErrorPage() {
    final translations = ExampleLocalizations.of(context);

    return Scaffold(
      // backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text(translations.orders_error),
      ),
      body: Container(
        padding: EdgeInsets.only(right: RIGHT_MARGINE, left: LEFT_MARGINE),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Spacer(
                flex: 2,
              ),
              Text(
                translations.orders_update_error,
                style: whiteTitleH2,
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
              DashboardButton(
                buttonText: translations.back_to_dashboard,
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
