import 'package:pickndell/api_connection/api_connection.dart';
import 'package:pickndell/dao/user_dao.dart';
import 'package:pickndell/database/user_database.dart';
import 'package:pickndell/home/home_page_isolate.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/model/order.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/repository/order_repository.dart';
import 'package:pickndell/ui/bottom_nav_bar.dart';
import 'package:pickndell/ui/progress_indicator.dart';
import 'package:flutter/material.dart';
import '../common/global.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileUpdated extends StatefulWidget {
  final String updateField;
  final String value;
  final User user;

  ProfileUpdated({this.user, this.updateField, this.value});

  @override
  _ProfileUpdatedState createState() => _ProfileUpdatedState();
}

class _ProfileUpdatedState extends State<ProfileUpdated> {
  @override
  void initState() {
    super.initState();
  }

  String orderUpdated;
  final dbProvider = DatabaseProvider.dbProvider;
  final userTable = 'userTable';

  // REFERENCE: Updating row in the DB
  //https://stackoverflow.com/questions/54102043/how-to-do-a-database-update-with-sqflite-in-flutter
  Future<int> rowUpdate(dynamic data) async {
    final db = await dbProvider.database;
    // final currentUser = await UserDao().getUser(0);
    final currentUser = widget.user;
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

  Widget build(BuildContext context) {
    final trans = ExampleLocalizations.of(context);
    return FutureBuilder(
      future: updateRemoteProfile(widget.updateField, widget.value),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          print('PROFILE UPDATED: ${snapshot.data}');

          if (snapshot.data["response"] == "Update successful") {
            rowUpdate(snapshot.data);

            print('FINISHED PROFILE UPDATED!!!!');
            if (widget.updateField == 'name') {
              return HomePageIsolate();
            } else {
              return getProfileUpdatedPage(snapshot.data);
            }
          } else if (snapshot.data["response"] == "Update failed") {
            print('Falied with server response. ');
            return profileUpdatedErrorPage();
          } else {
            print('Falied WITHOUT server response. RESPONSE: ${snapshot.data}');
            return profileUpdatedErrorPage();
          }
        } else {
          print("No data:");
        }
        print('WAITING FOR UPDATE');
        String loaderText = "Updating Profile...";
        return ColoredProgressDemo(loaderText);
      },
    );
  }

  Future updateRemoteProfile(String updateField, String value) async {
    print('UPDATINNG REMOTE PROFILE. CHANGING $updateField');
    var updateResponse;
    updateResponse = await updateUser(
        user: widget.user, value: value, updateField: updateField);
    print('Field updated: $updateResponse');
    return updateResponse;
  }

  Widget getProfileUpdatedPage(dynamic order) {
    final trans = ExampleLocalizations.of(context);

    return Scaffold(
      backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text('Profile Update'),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 50),
        height: 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Spacer(
              flex: 4,
            ),
            Text(
              'Your profile was successfully updated',
              style: bigLightBlueTitle,
            ),
            Spacer(
              flex: 2,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }

  Widget profileUpdatedErrorPage() {
    final trans = ExampleLocalizations.of(context);

    return new Scaffold(
      backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text('Error updating profile'),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 20),
        height: 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Spacer(
              flex: 4,
            ),
            Text(
              'Please try again later',
              style: bigLightBlueTitle,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}

// TODO: Add the pick and drop addresses coordinates

class MapUtils {
  MapUtils._();

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}
