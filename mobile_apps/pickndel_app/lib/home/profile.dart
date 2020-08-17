import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pickndell/dao/user_dao.dart';
import 'package:pickndell/model/user_model.dart';

class Profile extends InheritedWidget {
  User userData;
  final Widget child;
  Profile({this.child});

  @override
  bool updateShouldNotify(Profile oldWidget) {
    return oldWidget.userData != userData;
  }

  static Profile of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType();
}
