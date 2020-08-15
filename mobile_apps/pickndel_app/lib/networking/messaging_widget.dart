import 'package:bloc_login/login/message_page.dart';
import 'package:bloc_login/model/notification_message.dart';
import 'package:bloc_login/model/order.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class MessagingWidget extends StatefulWidget {
  @override
  _MessagingWidgetState createState() => _MessagingWidgetState();
}

class _MessagingWidgetState extends State<MessagingWidget> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<NotificationMessage> messages = [];

  var title;
  var body;
  var data;
  Order newOrder = Order();

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        final notification = message['notification'];
        // print('ORDER DATA: ${message["data"]}');
        data = message['data'];

        // New order information redeived
        newOrder.order_id = data['order_id'];
        // newOrder.pick_up_address = data['pick_up_address'];
        // newOrder.drop_off_address = data['drop_off_address'];
        // newOrder.price = data['price'];
        // newOrder.created = data['created'];
        // newOrder.updated = data['updated'];
        // newOrder.order_type = data['order_type'];
        // newOrder.order_city_name = data['order_city_name'];
        // newOrder.order_street_name = data['order_street_name'];
        // newOrder.distance_to_business = data['distance_to_business'];
        // newOrder.status = data['status'];

        // print('>>>>> ORDER DATA: $data');
        print('>>>>> NEW ORDER ID: ${newOrder.order_id}');
        // newOrder = Order.fromJson(json.decode(data));
        // print('>>>>> NEW ORDER DATA: $newOrder');

        setState(() {
          messages.add(NotificationMessage(
              title: notification['title'], body: notification['body']));
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => MessagePage(
                        messageType: 'push',
                        message: message['notification'],
                        data: message['data'],
                        order: newOrder,
                      )));
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");

        final notification = message['data'];
        setState(() {
          title = notification['title'];
          body = notification['body'];

          messages.add(NotificationMessage(
            title: '${notification['title']}',
            body: '${notification['body']}',
          ));
        });
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        final notification = message['notification'];
        setState(() {
          messages.add(NotificationMessage(
              title: notification['title'], body: notification['body']));
          Navigator.push(
              context,
              new MaterialPageRoute(
                  builder: (context) => MessagePage(
                        messageType: 'push',
                        message: message['notification'],
                        data: message['data'],
                        order: newOrder,
                      )));
        });
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
