import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:pickndell/api_connection/api_connection.dart';
import 'package:pickndell/bloc/authentication_bloc.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/dao/user_dao.dart';
import 'package:pickndell/database/user_database.dart';
import 'package:pickndell/home/home_page_isolate.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/repository/user_repository.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';
import './constants.dart';

// Pic color from Gimp and use as following example (pickndell logo green):
// color: Color(hexColor('8bc34a')), ...
hexColor(String colorHexCode) {
  String colorNew = '0xFF' + colorHexCode;
  int colorInt = int.parse(colorNew);
  return colorInt;
}

double roundDouble(double value, int places) {
  double mod = pow(10.0, places);
  return ((value * mod).round().toDouble() / mod);
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
  String patttern = r"(^[a-zA-Z\u05D0-\u05EA' ]*$)";
  RegExp regExp = new RegExp(patttern);
  if (value.length == 0) {
    return "Name is Required";
  } else if (!regExp.hasMatch(value)) {
    return "Name must be a-z and A-Z";
  }
  return null;
}

String validateMobile(String value) {
  String patttern = r'(^\+?[0-9]*$)';
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

String validateYear(String value) {
  switch (value) {
    case '19':
      return null;
      break;
    case '20':
      return null;
      break;
    case '21':
      return null;
      break;
    case '22':
      return null;
      break;
    case '23':
      return null;
      break;
    case '24':
      return null;
      break;
    case '25':
      return null;
      break;
    case '26':
      return null;
      break;
    case '27':
      return null;
      break;
    case '28':
      return null;
      break;
    case '29':
      return null;
      break;
    case '30':
      return null;
      break;
    case '31':
      return null;
      break;
    default:
      return "Year entered is not valid";
  }
}

String validateCvv(String cvvNumber) {
  if (cvvNumber.length == 3) {
    return null;
  } else {
    return "CVV number is not valid";
  }
}

String validateMonth(String value) {
  if (value.length != 2) {
    return "Month entered is not valid.";
  } else if (value[0] != '0') {
    int month = int.parse(value);
    if (month > 0 && month < 13) {
      return null;
    } else {
      return "Year entered is not valid";
    }
  } else {
    return null;
  }
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
    print('EMAIL NOT VALID');
    return 'Enter Valid Email';
  } else
    return null;
}

String dropdownMenue(String value) {
  if (value == null) {
    return 'Please choose registration type';
  } else {
    print('Dropdown selected: $value');
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
      backgroundColor: mainBackground,
      progressWidget: Container(
          padding: EdgeInsets.all(8.0),
          child: CircularProgressIndicator(
            valueColor: new AlwaysStoppedAnimation<Color>(Colors.blue),
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
    {BuildContext context,
    String title,
    String content,
    String url,
    String nameRoute,
    String buttonText,
    Color buttonColor,
    Color buttonTextColor,
    Color buttonBorderColor}) {
  // set up the AlertDialog
  Widget okButton = FlatButton(
    child: Text("Close"),
    onPressed: () {
      Navigator.pop(context);
    },
  );

  // This button will log out the user so that he will need to log back in to update the profile
  Widget urlButton = FlatButton(
    child: Text('Go to Website'),
    color: pickndellGreen,
    onPressed: () {
      // This is to log out the user if redirects to outside URL
      BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
      Phoenix.rebirth(context);
      if (url != null) {
        launchURL(url);
      }
    },
  );

  Widget redirectButton = FlatButton(
    child: Text(buttonText != null ? buttonText : "Go"),
    textColor: buttonTextColor != null ? buttonTextColor : Colors.white,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(BUTTON_BORDER_RADIUS),
        side: BorderSide(
            color:
                buttonBorderColor != null ? buttonBorderColor : Colors.white)),
    color: buttonColor != null ? buttonColor : pickndellGreen,
    onPressed: () {
      if (nameRoute != null) {
        Navigator.pop(context);
        Navigator.pushNamed(context, nameRoute);
      } else {
        print('No nameRoute');
      }
    },
  );

  AlertDialog alert = AlertDialog(
    title: title != null ? Text(title) : Text(""),
    content: content != null ? Text(content) : Text(""),
    actions: [
      okButton,
      url != null ? urlButton : nameRoute != null ? redirectButton : null,
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
    SET name = ?, username = ?, phone = ? , vehicle = ?, isApproved = ?, 
    idDoc = ?, profilePending = ?, rating = ?, activeOrders = ?,
    balance = ?, dailyProfit = ?, usdIls = ?, usdEur = ?, preferredPaymentMethod = ?,
    bankDetails = ?, accountLevel = ?
    WHERE id = ?
    ''', [
      data['name'],
      data['email'],
      data['phone'],
      data['vehicle'],
      data['is_approved'],
      data['id_doc'],
      data['profile_pending'],
      data['freelancer_total_rating'],
      data['num_active_orders_total'],
      data['balance'],
      data['daily_profit'],
      data['usd_ils'],
      data['usd_eur'],
      data['preferred_payment_method'],
      data['bank_details'],
      data['account_level'],
      0
    ]);
  } else {
    updateCount = await db.rawUpdate('''
    UPDATE $userTable 
    SET businessName = ?, phone = ?, username = ?, businessCategory = ?, 
    creditCardToken = ?, isApproved = ?
    WHERE id = ?
    ''', [
      data['business_name'],
      data['phone'],
      data['email'],
      data['business_category'],
      data['credit_card_token'],
      data['is_approved'],
      0
    ]);
  }
  print('ROWS UPDATED: $updateCount ');

  return updateCount;
}
