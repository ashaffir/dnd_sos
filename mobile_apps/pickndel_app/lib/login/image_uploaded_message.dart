import 'package:pickndell/common/global.dart';
import 'package:pickndell/home/home_page_isolate.dart';
import 'package:pickndell/localizations.dart';
import 'package:flutter/material.dart';
import 'package:pickndell/repository/user_repository.dart';
import 'package:pickndell/ui/bottom_nav_bar.dart';

class ImageUploaded extends StatelessWidget {
  final uploadStatus;
  final imageType;

  ImageUploaded({this.uploadStatus, this.imageType});

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
        height: 300,
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
                      style: bigLightBlueTitle,
                    ),
              Padding(
                padding: EdgeInsets.only(top: 50),
              ),
              FlatButton(
                child: Text('Back To Main Page'),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return HomePageIsolate(
                          userRepository: UserRepository(),
                        );
                      },
                    ),
                    (Route<dynamic> route) =>
                        false, // No Back option for this page
                  );
                },
                color: pickndellGreen,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
