import 'package:background_locator/generated/i18n.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/home/home_page_isolate.dart';
import 'package:pickndell/localizations.dart';
import 'package:flutter/material.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/repository/user_repository.dart';
import 'package:pickndell/ui/buttons.dart';
import 'package:pickndell/ui/bottom_nav_bar.dart';
import 'package:pickndell/ui/bottom_navigation_bar.dart';

class ImageUploaded extends StatelessWidget {
  final uploadStatus;
  final imageType;
  final User user;

  ImageUploaded({this.uploadStatus, this.imageType, this.user});

  @override
  Widget build(BuildContext context) {
    final translations = ExampleLocalizations.of(context);

    return Scaffold(
      // backgroundColor: mainBackground,
      appBar: AppBar(
        title: imageType == 'delivery'
            ? Text('Delivery Confirmaiton')
            : Text('Profile Update'),
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 30),
              ),
              uploadStatus == "ok"
                  ? imageType == 'delivery'
                      ? Text(
                          'Delivery and confirmation photo updated. Good Job!',
                          style: bigLightBlueTitle,
                        )
                      : Text(
                          'Your profile was successfully updated',
                          style: bigLightBlueTitle,
                        )
                  : Text(
                      'Something went wrong. Please try again later',
                      style: whiteTitle,
                    ),
              Padding(
                padding: EdgeInsets.only(top: 50),
              ),
              uploadStatus == 'ok'
                  ? Image.asset(
                      'assets/images/check-icon.png',
                      width: MediaQuery.of(context).size.width * 0.50,
                    )
                  : Image.asset(
                      'assets/images/error-icon.png',
                      width: MediaQuery.of(context).size.width * 0.50,
                    ),
              Padding(
                padding: EdgeInsets.only(top: 50),
              ),
              DashboardButton(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        user: user,
      ),
    );
  }
}
