import 'package:flutter/material.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/model/order.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/orders/order_list.dart';
import 'package:pickndell/orders/order_page.dart';
import 'package:url_launcher/url_launcher.dart';

Widget ordersInProgress(
    {Order order, User user, BuildContext context, String country}) {
  final trans = ExampleLocalizations.of(context);
  return Center(
    child: InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderPage(
                user: user,
                order: order,
                orderId: order.order_id,
                country: country,
              ),
            ));
      },
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    trans.orders_status_waiting_delivery,
                    style: TextStyle(
                      backgroundColor: Colors.blue[500],
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            ListTile(
              // leading: Icon(Icons.album),
              leading: CircleAvatar(
                radius: 25,
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueGrey,
                child: order.order_type.toString() == 'Documents'
                    ? Icon(Icons.collections_bookmark)
                    : order.order_type.toString() == 'Food'
                        ? Icon(Icons.restaurant)
                        : order.order_type.toString() == 'Tools'
                            ? Icon(Icons.fitness_center)
                            : order.order_type.toString() == 'Furniture'
                                ? Icon(Icons.weekend)
                                : order.order_type.toString() == 'Clothes'
                                    ? Icon(Icons.wc)
                                    : Icon(Icons.whatshot),
              ),
              title: Text(trans.orders_from + ': ${order.pick_up_address}'),
              subtitle: Text(trans.orders_to + ': ${order.drop_off_address}'),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(trans.orders_created + ': ${order.created}'),
                  Text(trans.orders_update + ': ${order.updated}'),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Text('Fee: ${order.price}'),
                ButtonBar(
                  children: <Widget>[
                    Padding(padding: EdgeInsets.all(5.0)),
                    RaisedButton.icon(
                      icon: Icon(Icons.phone),
                      color: Colors.blue,
                      shape:
                          StadiumBorder(side: BorderSide(color: Colors.black)),
                      onPressed: () {
                        launch(('tel://${order.courier_phone}'));
                      },
                      label: Text(trans.orders_call_courier),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
