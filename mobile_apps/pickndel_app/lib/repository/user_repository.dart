import 'dart:async';
import 'dart:io';
import 'package:pickndell/model/user_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:pickndell/model/api_model.dart';
import 'package:pickndell/api_connection/api_connection.dart';
import 'package:pickndell/dao/user_dao.dart';

// REFERENCE: Inherited idget

class UserRepository {
  final userDao = UserDao();
  FirebaseMessaging _fcm = FirebaseMessaging();
  String fcmToken;
  String deviceOs;

  Future<User> authenticate({
    @required String username,
    @required String password,
  }) async {
    // Login Authentication
    UserLogin userLogin = UserLogin(username: username, password: password);
    Token token = await serverAuthentication(userLogin);
    StreamSubscription iosSubscription;

    try {
      // Setting FCM token
      if (token.fcmToken == '0') {
        // If iOS, need to ask for permission to share device Token ID
        if (Platform.isIOS) {
          iosSubscription = _fcm.onIosSettingsRegistered.listen((data) async {
            fcmToken = await _fcm.getToken();
          });
          _fcm.requestNotificationPermissions(
              IosNotificationSettings(sound: true, badge: true, alert: true));
        } else {
          fcmToken = await _fcm.getToken();
        }

        deviceOs = Platform.operatingSystem;
        var fcmRegistrationReponse = await fcmTokenRegistration(
            fcmToken: fcmToken, osType: deviceOs, userToken: token.token);

        print('>>>> REGISTERED NEW FCM TOKEN: $fcmToken');
      } else {
        print('>>>> FCM TOKEN EXISTS: $fcmToken');
      }
    } catch (e) {
      print('ERROR FCM TOKEN: $e');
    }
    // Retreiving user information from the server
    User user = User(
        id: 0,
        username: username,
        token: token.token,
        userId: token.userId,
        isEmployee: token.isEmployee,
        name: token.name,
        phone: token.phone,
        businessName: token.businessName,
        businessCategory: token.businessCategory,
        creditCardToken: token.creditCardToken,
        isApproved: token.isApproved,
        numDailyOrders: token.numDailyOrders,
        numOrdersInProgress: token.numOrdersInProgress,
        dailyCost: token.dailyCost,
        vehicle: token.vehicle,
        rating: token.rating,
        dailyProfit: token.dailyProfit,
        activeOrders: token.activeOrders);
    return user;
  }

  Future<void> persistToken({@required User user}) async {
    // write token with the user to the database
    await userDao.createUser(user);
  }

  Future<void> deleteToken({@required int id}) async {
    await userDao.deleteUser(id);
  }

  Future<bool> hasToken() async {
    bool result = await userDao.checkUser(0);
    return result;
  }
}
