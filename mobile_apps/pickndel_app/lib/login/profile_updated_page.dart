import 'package:flutter/material.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/ui/bottom_navigation_bar.dart';
import 'package:pickndell/ui/buttons.dart';

class ProfileUpdatedPage extends StatelessWidget {
  final User user;
  final String message;
  final String status;

  ProfileUpdatedPage({this.user, this.message, this.status});
  @override
  Widget build(BuildContext context) {
    final trans = ExampleLocalizations.of(context);

    return Scaffold(
      // backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text(trans.profile_update_title),
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 30),
                ),
                Text(
                  status == 'statusOK'
                      ? trans.profile_updated
                      : trans.error_updating_profile,
                  style: bigLightBlueTitle,
                ),
                Padding(padding: EdgeInsets.only(top: 40)),
                Center(
                  child: status == 'statusOK'
                      ? Image.asset(
                          'assets/images/check-icon.png',
                          width: MediaQuery.of(context).size.width * 0.50,
                        )
                      : Image.asset(
                          'assets/images/fail-icon.png',
                          width: MediaQuery.of(context).size.width * 0.50,
                        ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: 100),
                ),
                DashboardButton(
                  buttonText: trans.back_to_dashboard,
                ),

                // DashboardButton(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        user: user,
      ),
    );
  }
}
