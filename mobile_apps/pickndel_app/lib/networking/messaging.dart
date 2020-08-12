// REFERENCE: Firebase cloud messages - push notifications: https://www.youtube.com/watch?v=2TSm2YGBT1s
import 'dart:io';
import 'dart:async';

import 'package:bloc_login/dao/user_dao.dart';
import 'package:bloc_login/model/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MessagesHandler extends StatefulWidget {
  @override
  _MessagesHandlerState createState() => _MessagesHandlerState();
}

class _MessagesHandlerState extends State<MessagesHandler> {
  @override
  Widget build(BuildContext context) {
    return null;
  }

  Firestore _db = Firestore.instance;
  FirebaseMessaging _fcm = FirebaseMessaging();

  // Get user token and save to the Firestore DB
  _saveDeviceToken() async {
    User currentUser = await UserDao().getUser(0);
    String uid = currentUser.userId.toString();
    String username = currentUser.username;
    // FirebaseUser currentUser = await UserDao().getUser(0); // In production

    // Get token for this device ans save to Firestor
    String _fcmToken = await _fcm.getToken();
    if (_fcmToken != null) {
      var _tokenRef = _db
          .collection('users')
          .document(username)
          .collection('tokens')
          .document(_fcmToken);

      await _tokenRef.setData({
        'token': _fcmToken,
        'createdAt': FieldValue.serverTimestamp(), //optional
        'platform': Platform.operatingSystem // optional
      });
    }
  }

  StreamSubscription iosSubscription;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (Platform.isIOS) {
      iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        _saveDeviceToken();
      });
      _fcm.requestNotificationPermissions(IosNotificationSettings());
    } else {
      _saveDeviceToken();
    }

    _fcm.configure(onMessage: (Map<String, dynamic> message) async {
      print('onMessage: $message');

      // Show push notification in a snackbar
      final snackbar = SnackBar(
        content: Text(message['notificatiom']['title']),
        action: SnackBarAction(
          label: 'Check',
          onPressed: () {},
        ),
      );

      Scaffold.of(context).showSnackBar(snackbar);

      // Show push notification in a dialog box
      // showDialog(
      //     context: context,
      //     builder: (context) => AlertDialog(
      //           content: ListTile(
      //             title: Text(message['notification']['title']),
      //             subtitle: Text(message['notification']['body']),
      //           ),
      //           actions: <Widget>[
      //             FlatButton(
      //               child: Text('OK'),
      //               onPressed: () {
      //                 Navigator.of(context).pop();
      //               },
      //             )
      //           ],
      //         ));
    }, onResume: (Map<String, dynamic> message) async {
      // TODO:
    }, onLaunch: (Map<String, dynamic> message) async {
      // TODO:
    });
  }
}
