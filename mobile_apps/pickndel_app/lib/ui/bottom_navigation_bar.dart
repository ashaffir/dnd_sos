import 'package:flutter/material.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/dao/user_dao.dart';
import 'package:pickndell/login/logout_page.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/repository/user_repository.dart';

class BottomNavigation extends StatefulWidget {
  final User user;

  BottomNavigation({this.user});

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  User _currentUser;
  User currentUser;

  Future _checkUser() async {
    _currentUser = await UserDao().getUser(0);
    setState(() {
      currentUser = _currentUser;
    });
  }

  @override
  void initState() {
    _checkUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: BottomAppBar(
          color: bottomNavigationBarColor,
          shape: CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.dashboard),
                color: Colors.white,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.send,
                  // size: 44.0,
                ),
                onPressed: () {
                  if (currentUser.isEmployee == 1) {
                    Navigator.pushReplacementNamed(context, '/open-orders');
                  } else {
                    Navigator.pushReplacementNamed(context, '/rejected-orders');
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.notifications_active,
                  // size: 44.0,
                ),
                onPressed: () {
                  if (currentUser.isEmployee == 1) {
                    Navigator.pushReplacementNamed(context, '/active-orders');
                  } else {
                    Navigator.pushReplacementNamed(context, '/business-orders');
                  }
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.exit_to_app,
                  // size: 44.0,
                ),
                onPressed: () {
                  // Navigator.pushReplacementNamed(context, '/logout');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LogoutPage(
                              user: currentUser,
                              userRepository: UserRepository(),
                            )),
                  );
                },
              )
            ],
          )),
    );
  }
}
