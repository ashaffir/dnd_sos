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
import 'package:pickndell/orders/order_archived.dart';
import 'package:pickndell/orders/order_delivered.dart';
import 'package:pickndell/orders/order_picked_up.dart';
import 'package:pickndell/orders/order_rated.dart';
import 'package:pickndell/orders/order_re_requested.dart';
import 'package:pickndell/orders/order_rejected.dart';
import 'package:pickndell/orders/orders_delivered.dart';
import 'package:pickndell/orders/orders_in_progress.dart';
import 'package:pickndell/orders/orders_started.dart';
import 'package:pickndell/orders/requested_orders.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:url_launcher/url_launcher.dart';

import 'order_page.dart';

double _userRating;

class OrdersList extends StatelessWidget {
  final Orders ordersList;
  final String ordersType;
  final bool locationTracking;
  final User user;
  final String country;
  final int rookieLevelLimit;
  final int advancedLevelLimit;
  final int expertLevelLimit;
  const OrdersList(
      {Key key,
      this.ordersList,
      this.ordersType,
      this.locationTracking,
      this.user,
      this.country,
      this.rookieLevelLimit,
      this.advancedLevelLimit,
      this.expertLevelLimit})
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
                            child: Text(
                              translations.orders_cancel,
                              style: TextStyle(color: Colors.white),
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(BUTTON_BORDER_RADIUS),
                                side: BorderSide(color: buttonBorderColor)),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            color: Colors.transparent,
                          ),
                        ),
                        Spacer(),
                        // Conditions for the new status
                        newStatus == "ARCHIVED" // Order deleted
                            ? SizedBox(
                                width: MediaQuery.of(context).size.width * 0.30,
                                child: RaisedButton(
                                  child: Text(
                                    translations.order_confirm_archive,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  color: pickndellGreen,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          BUTTON_BORDER_RADIUS),
                                      side:
                                          BorderSide(color: buttonBorderColor)),
                                  onPressed: () {
                                    print('Archiving order ${order.order_id}');
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => OrderArchived(
                                          order: order,
                                          user: user,
                                        ),
                                      ),
                                      (Route<dynamic> route) =>
                                          false, // No Back option for this page
                                    );
                                  },
                                ),
                              )
                            : newStatus == "STARTED" // Order accepted
                                ? SizedBox(
                                    width: MediaQuery.of(context).size.width *
                                        0.30,
                                    child: RaisedButton(
                                      child: Text(
                                        translations.orders_confirm_button,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      color: pickndellGreen,
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              BUTTON_BORDER_RADIUS),
                                          side: BorderSide(
                                              color: buttonBorderColor)),
                                      onPressed: () {
                                        if ((user.accountLevel == 'Rookie' &&
                                                user.activeOrders <=
                                                    rookieLevelLimit) ||
                                            (user.accountLevel == 'Advanced' &&
                                                user.activeOrders <=
                                                    advancedLevelLimit) ||
                                            (user.accountLevel == 'Expert' &&
                                                user.activeOrders <=
                                                    expertLevelLimit)) {
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  OrderAccepted(
                                                order: order,
                                                user: user,
                                              ),
                                            ),
                                            (Route<dynamic> route) =>
                                                false, // No Back option for this page
                                          );
                                        } else {
                                          showAlertDialog(
                                              context: context,
                                              title: translations
                                                  .account_level_limit,
                                              content: translations
                                                      .orders_account_limit +
                                                  "${user.accountLevel}",
                                              okButtontext: translations.close);
                                        }
                                      },
                                    ),
                                  )
                                : newStatus == "COMPLETED" // Order delivered
                                    ? SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.30,
                                        child: RaisedButton(
                                          child: Text(
                                            translations
                                                .orders_confirm_delivery,
                                            style:
                                                TextStyle(color: Colors.white),
                                          ),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      BUTTON_BORDER_RADIUS),
                                              side: BorderSide(
                                                  color: buttonBorderColor)),
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
                                          color: pickndellGreen,
                                        ),
                                      )
                                    // Order Rejected
                                    : newStatus == "REJECTED"
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
                                                translations
                                                    .orders_cancel_confirm,
                                                style: TextStyle(
                                                    color: Colors.white),
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
                                                    Navigator
                                                        .pushAndRemoveUntil(
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
                                                  child: Text(
                                                    translations.orders_pick_up,
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                  color: pickndellGreen,
                                                  shape: StadiumBorder(
                                                      side: BorderSide(
                                                          color: Colors.black)),
                                                  onPressed: () {
                                                    Navigator
                                                        .pushAndRemoveUntil(
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
      // backgroundColor: mainBackground,
      body: ListView.builder(
        itemCount: ordersList.orders.length,
        itemBuilder: (context, index) {
          Order order = ordersList.orders[index];

          ////////// Freelancer Open Orders ///////////////
          ///

          if (ordersType == 'openOrders') {
            return Center(
              child: InkWell(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderPage(
                        user: user,
                        country: country,
                        order: order,
                        orderId: order.order_id,
                      ),
                    )),
                child: Card(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.only(top: 10),
                      ),
                      order != null
                          ? Text(translations.orders_owner +
                              ': ${order.business_name}')
                          : Text(translations.orders_owner +
                              ': ${translations.unknown}'),
                      ListTile(
                        ////////// Delivery/Business Icons according to type of delivery ////////////////
                        ///
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
                              ? Text(translations.orders_fare +
                                  ': ${roundDouble(order.fare * user.usdIls, 2)} ₪')
                              : Text(translations.orders_fare +
                                  ': \$ ${order.fare}'),
                          ButtonBar(
                            children: <Widget>[
                              Padding(padding: EdgeInsets.all(5.0)),
                              RaisedButton(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        BUTTON_BORDER_RADIUS),
                                    side: BorderSide(color: buttonBorderColor)),
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
                                                .orders_alert_tracking_title +
                                            "❗️",
                                        content: translations
                                            .orders_alert_tracking_content,
                                        nameRoute: '/',
                                        buttonText:
                                            translations.orders_change_status,
                                        okButtontext: translations.close,
                                        buttonBorderColor: Colors.blue);
                                    print('No tracking!!!');
                                  }
                                },
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

            ////////// Freelancer Active Orders ///////////////
            ///
          } else if (ordersType == 'activeOrders') {
            if (order.status == 'STARTED') {
              /////////////////
              // Order accepted
              /////////////////
              return Center(
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OrderPage(
                          user: user,
                          order: order,
                          orderId: order.order_id,
                        ),
                      )),
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
                                    translations.navigate,
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
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
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
                              country: country,
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
                                      // orderAlert(context, order, newStatus);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => OrderPage(
                                              user: user,
                                              country: country,
                                              order: order,
                                              orderId: order.order_id,
                                            ),
                                          ));
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
                                    translations.navigate,
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
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderPage(
                            user: user,
                            country: country,
                            order: order,
                            orderId: order.order_id,
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
                                  child: Text(
                                    translations.orders_report_pickup,
                                    style: whiteButtonTitle,
                                  ),
                                  color: pickndellGreen,
                                  shape: StadiumBorder(
                                    side: BorderSide(width: 2),
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
                ),
              );
            } else if (order.status == 'REQUESTED' ||
                order.status == 'RE_REQUESTED') {
              // In progress orders
              return Center(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderPage(
                            user: user,
                            country: country,
                            order: order,
                            orderId: order.order_id,
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(translations.orders_created +
                                      ': ${order.created}'),
                                  Text(translations.orders_update +
                                      ': ${order.updated}'),
                                  Padding(padding: EdgeInsets.only(top: 10)),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                          translations.orders_order_cost + ":"),
                                      Padding(
                                          padding: EdgeInsets.only(right: 5.0)),
                                      country == 'Israel' || country == 'ישראל'
                                          ? Text(
                                              "${roundDouble(order.price * user.usdIls, 2)} ₪",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : Text("\$ ${order.price}"),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            RaisedButton(
                              color: Colors.red,
                              shape: StadiumBorder(
                                  side: BorderSide(color: Colors.black)),
                              child: Text(
                                translations.orders_cancel_delivery,
                                style: whiteButtonTitle,
                              ),
                              onPressed: () {
                                print('Cancel Order');
                                String newStatus = 'ARCHIVED';
                                orderAlert(context, order, newStatus);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else if (order.status == 'IN_PROGRESS') {
              // In progress orders
              return Center(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderPage(
                            user: user,
                            country: country,
                            order: order,
                            orderId: order.order_id,
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
                ),
              );
            } else if (order.status == 'COMPLETED') {
              // In progress orders
              return Center(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderPage(
                            user: user,
                            country: country,
                            order: order,
                            orderId: order.order_id,
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
                                translations.orders_status_delivered,
                                style: TextStyle(
                                  backgroundColor: pickndellGreen,
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  if (order.freelancerRating != 0.0)
                                    Text(translations.orders_you_rated_courier +
                                        ":"),
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: SmoothStarRating(
                                        rating: order.freelancerRating,
                                        onRated: (value) {
                                          _userRating = value;
                                        },
                                        isReadOnly:
                                            order.freelancerRating == 0.0
                                                ? false
                                                : true,
                                        size: 30,
                                        filledIconData: Icons.star,
                                        halfFilledIconData: Icons.star_half,
                                        defaultIconData: Icons.star_border,
                                        borderColor: Colors.white30,
                                        starCount: 5,
                                        allowHalfRating: true,
                                        color: Colors.yellow,
                                        spacing: 0.0),
                                  ),
                                  if (order.freelancerRating == 0.0)
                                    RaisedButton.icon(
                                      icon: Icon(Icons.star),
                                      color: Colors.orange,
                                      shape: StadiumBorder(
                                          side:
                                              BorderSide(color: Colors.black)),
                                      onPressed: () {
                                        if (_userRating == null)
                                          showAlertDialog(
                                              context: context,
                                              title: translations
                                                  .please_choose_rating,
                                              content: translations
                                                  .click_or_drag_stars);
                                        if (_userRating != null)
                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => OrderRated(
                                                order: order,
                                                user: user,
                                                rating: _userRating,
                                              ),
                                            ),
                                            (Route<dynamic> route) =>
                                                false, // No Back option for this page
                                          );
                                      },
                                      label: Text(
                                        translations.orders_rate_courier,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            }
            ////////////// Business Orders - Filtered ////////////
            ///
          } else if (ordersType == 'requestedOrders') {
            return requestedOrders(order: order, user: user, context: context);
          } else if (ordersType == 'startedOrders') {
            return startedOrders(order: order, user: user, context: context);
          } else if (ordersType == 'inProgressOrders') {
            return ordersInProgress(order: order, user: user, context: context);
          } else if (ordersType == 'deliveredOrders') {
            return deliveredOrders(order: order, user: user, context: context);
            //////////// BUSINESS REJECTED PAGE ////////////
            ///
          } else {
            // Business Orders
            if (order.status == 'REJECTED') {
              // Order rejected
              return Center(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderPage(
                            user: user,
                            country: country,
                            order: order,
                            orderId: order.order_id,
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
                ),
              );
            } else {
              // In progress orders
              return Center(
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => OrderPage(
                            user: user,
                            country: country,
                            order: order,
                            orderId: order.order_id,
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
                      ],
                    ),
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
