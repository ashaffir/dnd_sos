import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/common/helper.dart';
import 'package:pickndell/common/map_utils.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/model/open_orders.dart';
import 'package:pickndell/model/order.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/orders/order_accepted.dart';
import 'package:pickndell/orders/order_delivered.dart';
import 'package:pickndell/orders/order_picked_up.dart';
import 'package:pickndell/orders/order_re_requested.dart';
import 'package:pickndell/orders/order_rejected.dart';
import 'package:url_launcher/url_launcher.dart';

import 'order_page.dart';

class OrdersList extends StatelessWidget {
  final Orders ordersList;
  final String ordersType;
  final bool locationTracking;
  final User user;

  const OrdersList(
      {Key key,
      this.ordersList,
      this.ordersType,
      this.locationTracking,
      this.user})
      : super(key: key);

// REFERENCE - Alert dialog: https://www.youtube.com/watch?v=FGfhnS6skMQ
  Future<String> orderAlert(
      BuildContext context, Order order, String newStatus) {
    // To handle inputs from the dialiog, if there are any...
    // TextEditingController customController = TextEditingController();

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          final translations = ExampleLocalizations.of(context);
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)), //this right here
            child: Container(
              height: 200,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                        translations.orders_confirm + "?",
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    Padding(padding: EdgeInsets.all(10.0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          // width: 320.0,
                          width: MediaQuery.of(context).size.width * 0.30,
                          child: RaisedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              translations.orders_cancel,
                              style: TextStyle(color: Colors.white),
                            ),
                            color: Colors.transparent,
                          ),
                        ),
                        Spacer(),
                        // Conditions for the new status
                        newStatus == "STARTED" // Order accepted
                            ? SizedBox(
                                width: MediaQuery.of(context).size.width * 0.30,
                                child: RaisedButton(
                                  onPressed: () {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OrderAccepted(
                                          order: order,
                                          user: user,
                                        ),
                                      ),
                                      (Route<dynamic> route) =>
                                          false, // No Back option for this page
                                    );
                                  },
                                  child: Text(
                                    translations.orders_confirm_button,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  color: pickndellGreen,
                                ),
                              )
                            : newStatus == "COMPLETED" // Order delivered
                                ? SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.30,
                                    child: RaisedButton(
                                      onPressed: () {
                                        Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                OrderDelivered(
                                              order: order,
                                              user: user,
                                            ),
                                          ),
                                          (Route<dynamic> route) =>
                                              false, // No Back option for this page
                                        );
                                      },
                                      child: Text(
                                        translations.orders_confirm_delivery,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      color: pickndellGreen,
                                    ),
                                  )
                                // Order Rejected
                                : newStatus == "REJECTED"
                                    ? SizedBox(
                                        // width: 320.0,
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.30,
                                        child: RaisedButton(
                                          onPressed: () {
                                            Navigator.pushAndRemoveUntil(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    OrderRejected(
                                                  order: order,
                                                  user: user,
                                                ),
                                              ),
                                              (Route<dynamic> route) =>
                                                  false, // No Back option for this page
                                            );
                                          },
                                          child: Text(
                                            translations.orders_cancel_confirm,
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          color: Colors.red,
                                        ),
                                      )
                                    // RE_REQUESTED by business
                                    : newStatus == "RE_REQUESTED"
                                        ? SizedBox(
                                            // width: 320.0,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.30,
                                            child: RaisedButton(
                                              onPressed: () {
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        OrderReRequested(
                                                      order: order,
                                                      user: user,
                                                    ),
                                                  ),
                                                  (Route<dynamic> route) =>
                                                      false, // No Back option for this page
                                                );
                                              },
                                              child: Text(
                                                translations
                                                    .orders_confirm_broadcast,
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              color: Colors.red[300],
                                            ),
                                          )
                                        :
                                        // Picked up. IN_PROGRESS
                                        SizedBox(
                                            // width: 320.0,
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.30,
                                            child: RaisedButton(
                                              onPressed: () {
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        OrderPickedup(
                                                      order: order,
                                                      user: user,
                                                    ),
                                                  ),
                                                  (Route<dynamic> route) =>
                                                      false, // No Back option for this page
                                                );
                                              },
                                              child: Text(
                                                translations.orders_pick_up,
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                              color: pickndellGreen,
                                            ),
                                          ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final translations = ExampleLocalizations.of(context);

    print('TYPE: $ordersType');
    return new Scaffold(
      backgroundColor: Color(0xFF202020),
      body: ListView.builder(
        itemCount: ordersList.orders.length,
        itemBuilder: (context, index) {
          Order order = ordersList.orders[index];

          ////////// Freelancer Open Orders ///////////////
          ///

          if (ordersType == 'openOrders') {
            return Center(
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(top: 10),
                    ),
                    Text(
                        translations.orders_owner + ': ${order.business_name}'),
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
                                      : order.order_type.toString() ==
                                              'Furniture'
                                          ? Icon(Icons.weekend)
                                          : order.order_type.toString() ==
                                                  'Clothes'
                                              ? Icon(Icons.wc)
                                              : Icon(Icons.whatshot)),

                      title: Text(translations.orders_from +
                          ': ${order.pick_up_address}'),
                      subtitle: Text(translations.orders_to +
                          ': ${order.drop_off_address}'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ui.window.locale.languageCode == 'he'
                            ? Text(
                                translations.orders_fare + ': ${order.fare} ₪')
                            : Text(translations.orders_fare +
                                ': \$ ${order.fare}'),
                        ButtonBar(
                          children: <Widget>[
                            Padding(padding: EdgeInsets.all(5.0)),
                            RaisedButton(
                              color: pickndellGreen,
                              child: Text(
                                translations.orders_accept,
                                style: whiteButtonTitle,
                              ),
                              onPressed: () {
                                print('Accepted Order');
                                print('TRACKING>>>>> $locationTracking');
                                if (locationTracking) {
                                  String newStatus = "STARTED";
                                  orderAlert(context, order, newStatus);
                                } else {
                                  showAlertDialog(
                                      context: context,
                                      title: translations
                                          .orders_alert_tracking_title,
                                      content: translations
                                          .orders_alert_tracking_content,
                                      nameRoute: '/',
                                      buttonText: 'Change Status');
                                  print('No tracking!!!');
                                }

                                // Just move the "accept" screen
                                // Navigator.pushReplacementNamed(
                                //     context, '/order-accepted');

                                // orderAlert(context).then((onValue) {
                                //   Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //         builder: (context) => OrderAccepted(
                                //           order_id: order.order_id,
                                //           pick_up_address: order.pick_up_address,
                                //           drop_off_address:
                                //               order.drop_off_address,
                                //         ),
                                //       ));
                                // });

                                //Open the Alert dialog and swith to "accept" screen
                                // orderAlert(context).then((onValue) {
                                //   Navigator.pushReplacementNamed(
                                //       context, '/order-accepted');
                                // });

                                //Open the Alert dialog and show Snackbar with alert textmessage
                                // orderAlert(context).then((onValue) {
                                //   SnackBar confirmation = SnackBar(
                                //     content: Text('Confirmed: $onValue'),
                                //   );
                                //   Scaffold.of(context).showSnackBar(confirmation);
                                // });
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );

            ////////// Freelancer Active Orders ///////////////
            ///
          } else if (ordersType == 'activeOrders') {
            if (order.status == 'STARTED') {
              /////////////////
              // Order accepted
              /////////////////
              return Center(
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              translations.orders_message_pickup,
                              style: TextStyle(
                                backgroundColor: Colors.red[400],
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(padding: EdgeInsets.only(top: 10.0)),
                      Text(translations.orders_owner +
                          ': ${order.business_name}'),
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
                                      : order.order_type.toString() ==
                                              'Furniture'
                                          ? Icon(Icons.weekend)
                                          : order.order_type.toString() ==
                                                  'Clothes'
                                              ? Icon(Icons.wc)
                                              : Icon(Icons.whatshot),
                        ),
                        title: Text(translations.orders_from +
                            ': ${order.pick_up_address}'),
                        subtitle: Text(translations.orders_to +
                            ': ${order.drop_off_address}'),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // Text('Fee: ${order.price}'),
                          ButtonBar(
                            children: <Widget>[
                              RaisedButton.icon(
                                icon: Icon(Icons.phone),
                                color: Colors.blue,
                                shape: StadiumBorder(
                                    side: BorderSide(color: Colors.black)),
                                onPressed: () {
                                  launch(('tel://${order.business_phone}'));
                                },
                                label: Text(translations.orders_call_sender),
                              ),
                              Padding(padding: EdgeInsets.all(5.0)),
                              RaisedButton.icon(
                                icon: Icon(
                                  Icons.navigation,
                                  color: pickndellGreen,
                                ),
                                color: Colors.transparent,
                                shape: StadiumBorder(
                                    side: BorderSide(color: pickndellGreen)),
                                label: Text(
                                  'Navigate',
                                  style: whiteButtonTitle,
                                ),
                                onPressed: () {
                                  print(
                                      'STARTED ORDER STATUS: ${order.status}');
                                  print(
                                      '>>>>> Navigate to Business/Sender: LAT: ${order.businessLat} LON: ${order.businessLng}');
                                  MapUtils.openMap(
                                      order.businessLat, order.businessLng);
                                },
                              ),

                              // RaisedButton(
                              //   color: Colors.red,
                              //   shape: StadiumBorder(
                              //       side: BorderSide(color: Colors.black)),
                              //   child: Text(
                              //     translations.orders_cancel_delivery,
                              //     style: whiteButtonTitle,
                              //   ),
                              //   onPressed: () {
                              //     print('Cancel Order');
                              //     String newStatus = 'REJECTED';
                              //     orderAlert(context, order, newStatus);
                              //   },
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else {
              //////////////////////
              // In progress orders
              //////////////////////
              return Center(
                child: Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderPage(
                              user: user,
                              order: order,
                              orderId: order.order_id,
                            ),
                          ));
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    translations.orders_make_delivery,
                                    style: TextStyle(
                                      backgroundColor: Colors.red,
                                      fontSize: 20,
                                    ),
                                  ),
                                  Spacer(
                                    flex: 2,
                                  ),
                                  RaisedButton(
                                    color: pickndellGreen,
                                    shape: StadiumBorder(
                                        side: BorderSide(color: Colors.black)),
                                    child: Text(
                                      translations.orders_report_delivered,
                                      style: whiteButtonTitle,
                                    ),
                                    onPressed: () {
                                      print('Delivered!!');
                                      String newStatus = "COMPLETED";
                                      orderAlert(context, order, newStatus);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 10),
                        ),
                        Text(translations.orders_owner +
                            ': ${order.business_name}'),
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
                                          : order.order_type.toString() ==
                                                  'Furniture'
                                              ? Icon(Icons.weekend)
                                              : order.order_type.toString() ==
                                                      'Clothes'
                                                  ? Icon(Icons.wc)
                                                  : Icon(Icons.whatshot)),
                          // title: Text('From: ${order.pick_up_address}'),
                          title: Text(translations.orders_delivery_to +
                              ': ${order.drop_off_address}'),
                          // subtitle: Text('To: ${order.drop_off_address}'),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            // Text('Fee: ${order.price}'),
                            ButtonBar(
                              children: <Widget>[
                                RaisedButton.icon(
                                  icon: Icon(Icons.phone),
                                  color: Colors.blue,
                                  shape: StadiumBorder(
                                      side: BorderSide(color: Colors.black)),
                                  onPressed: () {
                                    launch(('tel://${order.business_phone}'));
                                  },
                                  label: Text(translations.orders_call_sender),
                                ),
                                RaisedButton.icon(
                                  icon: Icon(
                                    Icons.navigation,
                                    color: pickndellGreen,
                                  ),
                                  color: Colors.transparent,
                                  shape: StadiumBorder(
                                      side: BorderSide(color: pickndellGreen)),
                                  label: Text(
                                    'Navigate',
                                    style: whiteButtonTitle,
                                  ),
                                  onPressed: () {
                                    print(
                                        'IN PROGRESS STATUS: ${order.status}');
                                    print(
                                        '>>>>> NAVIGATE: LAT: ${order.dropoffAddressLat} LON: ${order.dropoffAddressLng}');

                                    MapUtils.openMap(order.dropoffAddressLat,
                                        order.dropoffAddressLng);
                                  },
                                ),

                                // RaisedButton(
                                //   color: pickndellGreen,
                                //   child: Text(
                                //     translations.orders_report_delivered,
                                //     style: whiteButtonTitle,
                                //   ),
                                //   onPressed: () {
                                //     print('Delivered!!');
                                //     String newStatus = "COMPLETED";
                                //     orderAlert(context, order, newStatus);
                                //   },
                                // ),
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

            ////////// Business Orders ///////////////
            ///
          } else if (ordersType == 'businessOrders') {
            // Business Orders
            if (order.status == 'STARTED') {
              // Order accepted
              return Center(
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              translations.orders_status_waiting_pickup,
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
                                      : order.order_type.toString() ==
                                              'Furniture'
                                          ? Icon(Icons.weekend)
                                          : order.order_type.toString() ==
                                                  'Clothes'
                                              ? Icon(Icons.wc)
                                              : Icon(Icons.whatshot),
                        ),
                        title: Text(translations.orders_from +
                            ': ${order.pick_up_address}'),
                        subtitle: Text(translations.orders_to +
                            ': ${order.drop_off_address}'),
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(translations.orders_created +
                                ': ${order.created}'),
                            Text(translations.orders_update +
                                ': ${order.updated}'),
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
                                shape: StadiumBorder(
                                    side: BorderSide(color: Colors.black)),
                                onPressed: () {
                                  launch(('tel://${order.courier_phone}'));
                                },
                                label: Text(translations.orders_call_courier),
                              ),
                              RaisedButton(
                                color: pickndellGreen,
                                child: Text(
                                  translations.orders_report_pickup,
                                  style: whiteButtonTitle,
                                ),
                                onPressed: () {
                                  print('Picked up!!');
                                  String newStatus = "IN_PROGRESS";
                                  orderAlert(context, order, newStatus);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else if (order.status == 'REQUESTED' ||
                order.status == 'RE_REQUESTED') {
              // In progress orders
              return Center(
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              translations.orders_status_waiting_allocaiton,
                              style: TextStyle(
                                backgroundColor: Colors.red[300],
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
                                      : order.order_type.toString() ==
                                              'Furniture'
                                          ? Icon(Icons.weekend)
                                          : order.order_type.toString() ==
                                                  'Clothes'
                                              ? Icon(Icons.wc)
                                              : Icon(Icons.whatshot),
                        ),
                        title: Text(translations.orders_from +
                            ': ${order.pick_up_address}'),
                        subtitle: Text(translations.orders_to +
                            ': ${order.drop_off_address}'),
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(translations.orders_created +
                                ': ${order.created}'),
                            Text(translations.orders_update +
                                ': ${order.updated}'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else if (order.status == 'IN_PROGRESS') {
              // In progress orders
              return Center(
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              translations.orders_status_waiting_delivery,
                              style: TextStyle(
                                backgroundColor: Colors.blue[300],
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
                                      : order.order_type.toString() ==
                                              'Furniture'
                                          ? Icon(Icons.weekend)
                                          : order.order_type.toString() ==
                                                  'Clothes'
                                              ? Icon(Icons.wc)
                                              : Icon(Icons.whatshot),
                        ),
                        title: Text(translations.orders_from +
                            ': ${order.pick_up_address}'),
                        subtitle: Text(translations.orders_to +
                            ': ${order.drop_off_address}'),
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(translations.orders_created +
                                ': ${order.created}'),
                            Text(translations.orders_update +
                                ': ${order.updated}'),
                            RaisedButton.icon(
                              icon: Icon(Icons.phone),
                              color: Colors.blue,
                              shape: StadiumBorder(
                                  side: BorderSide(color: Colors.black)),
                              onPressed: () {
                                launch(('tel://${order.courier_phone}'));
                              },
                              label: Text(translations.orders_call_courier),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }

            //////////// BUSINESS REJECTED PAGE ////////////
            ///
          } else {
            // Business Orders
            if (order.status == 'REJECTED') {
              // Order accepted
              return Center(
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              translations.orders_status_rejected,
                              style: TextStyle(
                                backgroundColor: Colors.red[500],
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
                                        : order.order_type.toString() ==
                                                'Furniture'
                                            ? Icon(Icons.weekend)
                                            : order.order_type.toString() ==
                                                    'Clothes'
                                                ? Icon(Icons.wc)
                                                : Icon(Icons.whatshot)),
                        title: Text(translations.orders_from +
                            ': ${order.pick_up_address}'),
                        subtitle: Text(translations.orders_to +
                            ': ${order.drop_off_address}'),
                      ),
                      Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(translations.orders_created +
                                ': ${order.created}'),
                            Text(translations.orders_update +
                                ': ${order.updated}'),
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
                              RaisedButton(
                                color: pickndellGreen,
                                child: Text(
                                  translations.orders_request_courier,
                                  style: whiteButtonTitle,
                                ),
                                onPressed: () {
                                  print('Request Courier');
                                  String newStatus = 'RE_REQUESTED';
                                  orderAlert(context, order, newStatus);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            } else {
              // In progress orders
              return Center(
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              translations.orders_check,
                              style: TextStyle(
                                backgroundColor: Colors.red[300],
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
                                        : order.order_type.toString() ==
                                                'Furniture'
                                            ? Icon(Icons.weekend)
                                            : order.order_type.toString() ==
                                                    'Clothes'
                                                ? Icon(Icons.wc)
                                                : Icon(Icons.whatshot)),
                        title: Text(translations.orders_from +
                            ': ${order.pick_up_address}'),
                        subtitle: Text(translations.orders_to +
                            ': ${order.drop_off_address}'),
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.center,
                      //   children: [
                      //     // Text('Fee: ${order.price}'),
                      //     ButtonBar(
                      //       children: <Widget>[
                      //         Padding(padding: EdgeInsets.all(5.0)),
                      //         RaisedButton(
                      //           color: pickndellGreen,
                      //           child: Text(
                      //             "Report Delivered",
                      //             style: whiteButtonTitle,
                      //           ),
                      //           onPressed: () {
                      //             print('Delivered!!');
                      //             String newStatus = "COMPLETED";
                      //             orderAlert(context, order, newStatus);
                      //           },
                      //         ),
                      //       ],
                      //     ),
                      //   ],
                      // ),
                    ],
                  ),
                ),
              );
            }
          }
        },
        // itemCount: ordersList.length,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
      ),
    );
  }
}
