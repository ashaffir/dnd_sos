import 'dart:async';
import 'package:bloc_login/model/user_model.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:bloc_login/model/api_model.dart';
import 'package:bloc_login/api_connection/api_connection.dart';
import 'package:bloc_login/dao/user_dao.dart';

// REFERENCE: Inherited idget

class UserRepository {
// class UserRepository extends InheritedWidget {
  // final userDao;
  // final Widget child;
  // UserRepository({this.child, this.userDao});

  // @override
  // bool updateShouldNotify(UserRepository oldWidget) {
  //   return oldWidget.userDao != userDao;
  // }

  // static UserRepository of(BuildContext context) =>
  //     context.dependOnInheritedWidgetOfExactType();

  final userDao = UserDao();

  Future<User> authenticate({
    @required String username,
    @required String password,
  }) async {
    UserLogin userLogin = UserLogin(username: username, password: password);
    Token token = await getToken(userLogin);
    User user = User(
        id: 0,
        username: username,
        token: token.token,
        userId: token.userId,
        isEmployee: token.isEmployee,
        businessName: token.businessName,
        businessCategory: token.businessCategory,
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

  Future<void> delteToken({@required int id}) async {
    await userDao.deleteUser(id);
  }

  Future<bool> hasToken() async {
    bool result = await userDao.checkUser(0);
    return result;
  }

  // Future<int> userRegistration({
  //   @required String email,
  //   @required String password1,
  //   @required String password2,
  // }) async {
  //   int registrationConfirmation;
  //   UserRegistration userRegistration = UserRegistration(
  //       email: email, password1: password1, password2: password2);
  //   registrationConfirmation = createUser(userRegistration);
  // }
}
