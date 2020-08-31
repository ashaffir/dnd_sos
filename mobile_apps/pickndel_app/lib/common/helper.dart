import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:pickndell/api_connection/api_connection.dart';
import 'package:pickndell/bloc/authentication_bloc.dart';
import 'package:pickndell/dao/user_dao.dart';
import 'package:pickndell/database/user_database.dart';
import 'package:pickndell/home/home_page_isolate.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import './constants.dart';

// Pic color from Gimp and use as following exmaple (pickndell logo green):
// color: Color(hexColor('8bc34a')), ...
hexColor(String colorHexCode) {
  String colorNew = '0xFF' + colorHexCode;
  int colorInt = int.parse(colorNew);
  return colorInt;
}

String timeConvert(String dateTime) {
  String convertedTime = dateTime.split('T')[0] +
      " " +
      dateTime.split('T')[1].split(':')[0] +
      ":" +
      dateTime.split('T')[1].split(':')[1];
  return convertedTime;
}

String validateName(String value) {
  String patttern = r'(^[a-zA-Z ]*$)';
  RegExp regExp = new RegExp(patttern);
  if (value.length == 0) {
    return "Name is Required";
  } else if (!regExp.hasMatch(value)) {
    return "Name must be a-z and A-Z";
  }
  return null;
}

String validateMobile(String value) {
  String patttern = r'(^[0-9]*$)';
  RegExp regExp = new RegExp(patttern);
  if (value.length < 8) {
    return "Mobile is Required";
  } else if (!regExp.hasMatch(value)) {
    return "Mobile Number must be digits";
  }
  return null;
}

String validateVerificationCode(String value) {
  String patttern = r'(^[0-9]{5}$)';
  RegExp regExp = new RegExp(patttern);
  if (value.length == 0) {
    return "Verification code required";
  } else if (!regExp.hasMatch(value)) {
    return "Code Number must be five digits";
  }
  return null;
}

String validatePassword(String value) {
  if (value.length < 6)
    return 'Password must be more than 5 charater';
  else
    return null;
}

String validateEmail(String value) {
  Pattern pattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regex = new RegExp(pattern);
  if (!regex.hasMatch(value)) {
    print('EMIL NOT VALID');
    return 'Enter Valid Email';
  } else
    return null;
}

String dropdownMenue(String value) {
  if (value == null) {
    return 'Please choose registration type';
  } else {
    print('bad dropdown: $value');
    return null;
  }
}

String validateConfirmPassword(String password, String confirmPassword) {
  print("$password $confirmPassword");
  if (password != confirmPassword) {
    return 'Password doesn\'t match';
  } else if (confirmPassword.length == 0) {
    return 'Confirm password is required';
  } else {
    return null;
  }
}

//helper method to show progress
ProgressDialog progressDialog;

showProgress(BuildContext context, String message, bool isDismissible) async {
  progressDialog = new ProgressDialog(context,
      type: ProgressDialogType.Normal, isDismissible: isDismissible);
  progressDialog.style(
      message: message,
      borderRadius: 10.0,
      backgroundColor: Color(COLOR_PRIMARY),
      progressWidget: Container(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(
            backgroundColor: Colors.white,
          )),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      messageTextStyle: TextStyle(
          color: Colors.white, fontSize: 19.0, fontWeight: FontWeight.w600));
  await progressDialog.show();
}

updateProgress(String message) {
  progressDialog.update(message: message);
}

hideProgress() async {
  await progressDialog.hide();
}

launchURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not open $url';
  }
}

//helper method to show alert dialog
showAlertDialog(
    {BuildContext context, String title, String content, String url}) {
  // set up the AlertDialog
  Widget okButton = FlatButton(
    child: Text("OK"),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  // This button will log out the user so that he will need to log back in to update the profile
  Widget urlButton = FlatButton(
    child: Text('Go to Website'),
    color: Colors.green,
    onPressed: () {
      BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
      Phoenix.rebirth(context);
      if (url != '') {
        launchURL(url);
      }
    },
  );

  AlertDialog alert = AlertDialog(
    title: Text(title),
    content: Text(content),
    actions: [
      okButton,
      url != '' ? urlButton : null,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

pushReplacement(BuildContext context, Widget destination) {
  Navigator.of(context).pushReplacement(
      new MaterialPageRoute(builder: (context) => destination));
}

push(BuildContext context, Widget destination) {
  Navigator.of(context)
      .push(new MaterialPageRoute(builder: (context) => destination));
}

pushAndRemoveUntil(BuildContext context, Widget destination, bool predict) {
  Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => destination),
      (Route<dynamic> route) => predict);
}

Widget displayCircleImage(String picUrl, double size, hasBorder) =>
    CachedNetworkImage(
        imageBuilder: (context, imageProvider) =>
            _getCircularImageProvider(imageProvider, size, false),
        imageUrl: picUrl,
        placeholder: (context, url) =>
            _getPlaceholderOrErrorImage(size, hasBorder),
        errorWidget: (context, url, error) =>
            _getPlaceholderOrErrorImage(size, hasBorder));

Widget _getPlaceholderOrErrorImage(double size, hasBorder) => Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xff7c94b6),
        borderRadius: new BorderRadius.all(new Radius.circular(size / 2)),
        border: new Border.all(
          color: Colors.white,
          width: hasBorder ? 2.0 : 0.0,
        ),
      ),
      child: ClipOval(
          child: Image.asset(
        'assets/images/placeholder.jpg',
        fit: BoxFit.cover,
        height: size,
        width: size,
      )),
    );

Widget _getCircularImageProvider(
    ImageProvider provider, double size, bool hasBorder) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: const Color(0xff7c94b6),
      borderRadius: new BorderRadius.all(new Radius.circular(size / 2)),
      border: new Border.all(
        color: Colors.white,
        width: hasBorder ? 2.0 : 0.0,
      ),
    ),
    child: ClipOval(
        child: FadeInImage(
            fit: BoxFit.cover,
            placeholder: Image.asset(
              'assets/images/placeholder.jpg',
              fit: BoxFit.cover,
              height: size,
              width: size,
            ).image,
            image: provider)),
  );
}

// REFERENCE: Updating row in the DB
//https://stackoverflow.com/questions/54102043/how-to-do-a-database-update-with-sqflite-in-flutter
Future<int> rowUpdate({User user, dynamic data}) async {
  final dbProvider = DatabaseProvider.dbProvider;
  final userTable = 'userTable';

  final db = await dbProvider.database;
  // final currentUser = await UserDao().getUser(0);
  final currentUser = user;
  int updateCount;
  if (currentUser.isEmployee == 1) {
    updateCount = await db.rawUpdate('''
    UPDATE $userTable 
    SET name = ?, username = ?, phone = ? , vehicle = ?
    WHERE id = ?
    ''', [data['name'], data['email'], data['phone'], data['vehicle'], 0]);
  } else {
    updateCount = await db.rawUpdate('''
    UPDATE $userTable 
    SET businessName = ?, phone = ?, username = ?, businessCategory = ?
    WHERE id = ?
    ''', [
      data['business_name'],
      data['phone'],
      data['email'],
      data['business_category'],
      0
    ]);
  }
  print('ROWS UPDATED: $updateCount ');

  return updateCount;
}
