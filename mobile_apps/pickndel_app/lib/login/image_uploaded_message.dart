import 'package:pickndell/common/global.dart';
import 'package:pickndell/localizations.dart';
import 'package:flutter/material.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/ui/buttons.dart';
import 'package:pickndell/ui/bottom_navigation_bar.dart';

class ImageUploaded extends StatelessWidget {
  final context;
  final uploadStatus;
  final imageType;
  final User user;

  ImageUploaded({this.context, this.uploadStatus, this.imageType, this.user});

  @override
  Widget build(BuildContext context) {
    final trans = ExampleLocalizations.of(context);

    return Scaffold(
      // backgroundColor: mainBackground,
      appBar: AppBar(
        title: imageType == 'delivery'
            ? Text(trans.orders_delivery_confirmation)
            : Text(trans.profile_update_title),
      ),
      body: Container(
        padding: EdgeInsets.only(left: LEFT_MARGINE, right: RIGHT_MARGINE),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                    right: RIGHT_MARGINE, left: LEFT_MARGINE, top: 30),
              ),
              uploadStatus == "ok"
                  ? imageType == 'delivery'
                      ? Text(
                          trans.orders_delivery_success,
                          style: bigLightBlueTitle,
                        )
                      : Text(
                          trans.profile_updated,
                          style: bigLightBlueTitle,
                        )
                  : Text(
                      trans.messages_communication_error,
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
              // ProfileButton(),
              DashboardButton(
                buttonText: trans.back_to_dashboard,
              ),
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
