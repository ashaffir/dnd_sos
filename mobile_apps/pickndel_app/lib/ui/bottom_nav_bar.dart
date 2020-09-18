import 'package:pickndell/api_connection/api_connection.dart';
import 'package:pickndell/common/common.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/dao/user_dao.dart';
import 'package:pickndell/home/home_page_isolate.dart';
import 'package:pickndell/model/api_model.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/repository/user_repository.dart';
import 'package:flutter/material.dart';

// Reference: https://www.youtube.com/watch?v=DNCV1K5eVMw
class BottomNavBar extends StatefulWidget {
  final UserRepository userRepository;
  BottomNavBar({this.userRepository});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: UserDao().getUser(0),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data.isEmployee == 1) {
            return getCourierBottomNavBar(snapshot.data);
          } else if (snapshot.data.isEmployee == 0) {
            return getBusinessBottomNavBar(snapshot.data);
          }
        } else {
          print(">>>>> No user data for the Nav bar");
        }
        return CircularProgressIndicator();
      },
    );
  }

  getCourierBottomNavBar(User currentUser) {
    return Container(
      height: 65.0,
      padding: EdgeInsets.only(top: 5, bottom: 30),
      color: Colors.green,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Spacer(
            flex: 1,
          ),
          IconButton(
            icon: Icon(
              Icons.home,
              size: NAVBAR_ICON_SIZE,
            ),
            onPressed: () {
              // Navigator.pushReplacementNamed(context, '/');

              // Navigator.push(
              //     context,
              //     new MaterialPageRoute(
              //         builder: (context) => HomePageIsolate()));

              // Update user profile

              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => HomePageIsolate()),
                  (Route<dynamic> route) => false);
            },
          ),
          Spacer(
            flex: 2,
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_active,
              size: NAVBAR_ICON_SIZE,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/open-orders');
            },
          ),
          Spacer(
            flex: 4,
          ),
          IconButton(
            icon: Icon(
              Icons.motorcycle,
              size: NAVBAR_ICON_SIZE,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/active-orders');
            },
          ),
          Spacer(
            flex: 2,
          ),
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              size: NAVBAR_ICON_SIZE,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/logout');
            },
          ),
          Spacer(
            flex: 2,
          ),
        ],
      ),
    );
  }

  getBusinessBottomNavBar(User currentUser) {
    return Container(
      height: 75.0,
      padding: EdgeInsets.only(top: 5, bottom: 30),
      color: Colors.green,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.home,
              size: 44.0,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_active,
              size: 44.0,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/rejected-orders');
            },
          ),
          IconButton(
            icon: Icon(
              Icons.dashboard,
              size: 44.0,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/business-orders');
            },
          ),
          IconButton(
            icon: Icon(
              Icons.exit_to_app,
              size: 44.0,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/logout');
            },
          )
        ],
      ),
    );
  }
}
