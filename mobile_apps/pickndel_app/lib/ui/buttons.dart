import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/home/dashboard.dart';
import 'package:pickndell/home/profile.dart';
import 'package:pickndell/login/login_page.dart';
import 'package:pickndell/model/user_model.dart';

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
      // color: pickndellGreen,
    );
  }
}

class ProfileButton extends StatelessWidget {
  final User user;
  ProfileButton({this.user});
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text('Back To Profile'),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BUTTON_BORDER_RADIUS),
          side: BorderSide(color: buttonBorderColor)),
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ProfilePage(
                user: user,
              );
            },
          ),
          (Route<dynamic> route) => false, // No Back option for this page
        );
      },
      textColor: buttonTextColor,
      // color: pickndellGreen,
    );
  }
}

class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FlatButton(
      child: Text('Back To Login'),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(BUTTON_BORDER_RADIUS),
          side: BorderSide(color: buttonBorderColor)),
      onPressed: () {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) {
              return LoginPage();
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

class MyBackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Row(
      children: [
        Padding(
          padding: EdgeInsets.only(top: 30.0, left: LEFT_MARGINE),
        ),
        InkWell(
          child: Row(
            children: <Widget>[
              Icon(Icons.arrow_back),
              Padding(padding: EdgeInsets.only(right: 10.0)),
              Text('Back'),
            ],
          ),
          onTap: () {
            print('BACK');
            Navigator.pop(context);
          },
        ),
      ],
    ));
  }
}

class QuestionTooltip extends StatelessWidget {
  final String tooltipMessage;
  QuestionTooltip({this.tooltipMessage});
  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "$tooltipMessage",
      // height: 100,
      padding: EdgeInsets.all(20),
      showDuration: Duration(seconds: 5),
      // textStyle: whiteButtonTitle,
      child: FaIcon(
        FontAwesomeIcons.questionCircle,
        // size: 25,
      ),
      preferBelow: true,
    );
  }
}
