import 'package:flutter/cupertino.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/login/id_upload.dart';
import 'package:pickndell/model/order.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/orders/order_delivery.dart';
import 'package:pickndell/repository/order_repository.dart';
import 'package:pickndell/ui/bottom_nav_bar.dart';
import 'package:pickndell/ui/progress_indicator.dart';
import 'package:flutter/material.dart';
import '../common/global.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderPage extends StatefulWidget {
  final Order order;
  final String orderId;
  final User user;

  OrderPage({this.order, this.orderId, this.user});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
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
    return new Scaffold(
      // backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text('Order Page'),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 20, right: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Spacer(
              flex: 2,
            ),
            Text(
              "Order Details",
              style: bigLightBlueTitle,
            ),
            Spacer(
              flex: 1,
            ),
            Text(
              translations.orders_from + ': ${widget.order.pick_up_address}',
              style: whiteTitle,
            ),
            Spacer(
              flex: 1,
            ),
            Text(
              translations.orders_to + ": ${widget.order.drop_off_address}",
              style: whiteTitle,
            ),
            Spacer(
              flex: 6,
            ),
            ButtonBar(
              children: <Widget>[
                RaisedButton.icon(
                  icon: Icon(Icons.phone),
                  color: Colors.blue,
                  onPressed: () {
                    // launch(('tel://${order.business_phone}'));
                  },
                  label: Text(translations.orders_call_sender),
                ),
                Padding(padding: EdgeInsets.all(5.0)),
                RaisedButton(
                  color: Colors.green,
                  child: Text(
                    translations.orders_report_delivered,
                    style: whiteButtonTitle,
                  ),
                  onPressed: () {
                    print('Delivered!!');
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => OrderDelivery(
                                user: widget.user,
                                updateField: 'delivery_photo',
                                order: widget.order,
                              )),
                    );
                    // orderAlert(context, order, newStatus);
                  },
                ),
              ],
            ),
            Spacer(
              flex: 10,
            ),
            CupertinoActionSheetAction(
              child: Text("Cancel",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Spacer(
              flex: 10,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
