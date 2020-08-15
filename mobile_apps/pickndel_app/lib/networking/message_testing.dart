import 'package:bloc_login/model/notification_message.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class MessagingWidgetTest extends StatefulWidget {
  @override
  _MessagingWidgetTestState createState() => _MessagingWidgetTestState();
}

class _MessagingWidgetTestState extends State<MessagingWidgetTest> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<NotificationMessage> messages = [];

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage IIIIDIIDIDIDDIID : $message");
        final notification = message['notification'];
        setState(() {
          messages.add(NotificationMessage(
              title: notification['title'], body: notification['body']));
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");

        final notification = message['data'];
        setState(() {
          messages.add(NotificationMessage(
            title: '${notification['title']}',
            body: '${notification['body']}',
          ));
        });
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
  // => ListView(
  //       children: messages.map(buildMessage).toList(),
  //     );

  // Widget buildMessage(NotificationMessage message) => ListTile(
  //       title: Text(message.title),
  //       subtitle: Text(message.body),
  //     );
}
