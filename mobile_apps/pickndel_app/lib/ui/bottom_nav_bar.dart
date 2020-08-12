import 'package:bloc_login/dao/user_dao.dart';
import 'package:bloc_login/home/home_page_isolate.dart';
import 'package:bloc_login/model/api_model.dart';
import 'package:bloc_login/model/user_model.dart';
import 'package:bloc_login/repository/user_repository.dart';
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
            return getCarrierBottomNavBar(snapshot.data);
          } else if (snapshot.data.isEmployee == 0) {
            return getBusinessBottomNavBar(snapshot.data);
          }
        } else {
          print("No data");
        }
        return CircularProgressIndicator();
      },
    );
  }

  getCarrierBottomNavBar(User currentUser) {
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
              // Navigator.pushReplacementNamed(context, '/');
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => HomePageIsolate()));
            },
          ),
          IconButton(
            icon: Icon(
              Icons.notifications_active,
              size: 44.0,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/open-orders');
            },
          ),
          IconButton(
            icon: Icon(
              Icons.motorcycle,
              size: 44.0,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/active-orders');
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
              Navigator.pushReplacementNamed(context, '/open-orders');
            },
          ),
          IconButton(
            icon: Icon(
              Icons.dashboard,
              size: 44.0,
            ),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/active-orders');
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
