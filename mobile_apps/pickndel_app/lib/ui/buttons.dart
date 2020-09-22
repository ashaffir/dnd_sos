import 'package:flutter/material.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/home/dashboard.dart';

class DashboardButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text('Back To Dashboard'),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BUTTON_BORDER_RADIUS),
          side: BorderSide(color: buttonBorderColor)),
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) {
              return Dashboard();
            },
          ),
          (Route<dynamic> route) => false, // No Back option for this page
        );
      },
      textColor: buttonTextColor,
      color: pickndellGreen,
    );
  }
}
