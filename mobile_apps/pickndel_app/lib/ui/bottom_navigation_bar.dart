import 'package:flutter/material.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/dao/user_dao.dart';
import 'package:pickndell/home/profile.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/location/geo_helpers.dart';
import 'package:pickndell/login/logout_page.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/repository/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNavigation extends StatefulWidget {
  final User user;

  BottomNavigation({@required this.user});

  @override
  _BottomNavigationState createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  User _currentUser;
  User currentUser;

  String _country;

  Future _getCountry() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    _country = localStorage.getString('userCountry');
  }

  Future _checkUser() async {
    _currentUser = await UserDao().getUser(0);
    setState(() {
      currentUser = _currentUser;
    });
  }

  @override
  void initState() {
    _getCountry();
    _checkUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final trans = ExampleLocalizations.of(context);

    return Container(
      child: BottomAppBar(
          elevation: 0,
          color: bottomNavigationBarColor,
          shape: CircularNotchedRectangle(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            height: 56.0,
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
                      Navigator.pushReplacementNamed(
                          context, '/business-orders');
                    }
                  },
                ),
                Padding(padding: EdgeInsets.all(10)),
                IconButton(
                  icon: Icon(
                    Icons.notifications_active,
                    // size: 44.0,
                  ),
                  onPressed: () {
                    if (currentUser.isEmployee == 1) {
                      Navigator.pushReplacementNamed(context, '/active-orders');
                    } else {
                      Navigator.pushReplacementNamed(
                          context, '/rejected-orders');
                    }
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.menu,
                    // size: 44.0,
                  ),
                  onPressed: () {
                    // Navigator.pushReplacementNamed(context, '/logout');

                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //       builder: (context) => LogoutPage(
                    //             user: currentUser,
                    //             userRepository: UserRepository(),
                    //           )),
                    // );
                    showMenu(currentUser);
                  },
                )
              ],
            ),
          )),
    );
  }

  showMenu(User user) {
    print('USER: ${user.userId}');
    final trans = ExampleLocalizations.of(context);
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  color: pickndellGreen),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    height: 36,
                  ),
                  SizedBox(
                      height: (56 * 5).toDouble(),
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.0),
                              topRight: Radius.circular(16.0),
                            ),
                            color: Color(0xff344955),
                          ),
                          child: Stack(
                            alignment: Alignment(0, 0),
                            overflow: Overflow.visible,
                            children: <Widget>[
                              Positioned(
                                top: -36,
                                child: Container(
                                  // decoration: BoxDecoration(
                                  //     borderRadius:
                                  //         BorderRadius.all(Radius.circular(50)),
                                  //     border: Border.all(
                                  //         color: Color(0xff232f34), width: 10)),
                                  child: Center(
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/pickndell-logotype-512x512.jpg',
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.10,
                                      ),

                                      // Image.network(
                                      //   "https://i.stack.imgur.com/S11YG.jpg?s=64&g=1",
                                      //   fit: BoxFit.cover,
                                      //   height: 36,
                                      //   width: 36,
                                      // ),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                child: ListView(
                                  physics: NeverScrollableScrollPhysics(),
                                  children: <Widget>[
                                    ////////// Main ///////////
                                    ///
                                    ListTile(
                                      title: Text(
                                        trans.main,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      leading: Icon(
                                        Icons.dashboard,
                                        color: Colors.white,
                                      ),
                                      onTap: () {
                                        Navigator.pushReplacementNamed(
                                            context, '/');
                                      },
                                    ),
                                    if (user.isEmployee == 1)
                                      ////////// Open Orders ///////////
                                      ///
                                      ListTile(
                                        title: Text(
                                          trans.open_orders,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        leading: Icon(
                                          Icons.send,
                                          color: Colors.white,
                                        ),
                                        onTap: () {
                                          Navigator.pushReplacementNamed(
                                              context, '/open-orders');
                                        },
                                      ),

                                    if (user.isEmployee == 1)
                                      ////////// Active Orders ///////////
                                      ///
                                      ListTile(
                                        title: Text(
                                          trans.active_orders,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        leading: Icon(
                                          Icons.notifications_active,
                                          color: Colors.white,
                                        ),
                                        onTap: () {
                                          Navigator.pushReplacementNamed(
                                              context, '/active-orders');
                                        },
                                      ),

                                    if (user.isEmployee == 0)
                                      ////////// Business Orders ///////////
                                      ///
                                      ListTile(
                                        title: Text(
                                          trans.orders,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        leading: Icon(
                                          Icons.send,
                                          color: Colors.white,
                                        ),
                                        onTap: () {
                                          Navigator.pushReplacementNamed(
                                              context, '/business-orders');
                                        },
                                      ),

                                    if (user.isEmployee == 0)
                                      ////////// Rejected Orders ///////////
                                      ///
                                      ListTile(
                                        title: Text(
                                          trans.alerts,
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        leading: Icon(
                                          Icons.notifications_active,
                                          color: Colors.white,
                                        ),
                                        onTap: () {
                                          Navigator.pushReplacementNamed(
                                              context, '/rejected-orders');
                                        },
                                      ),

                                    ListTile(
                                      title: Text(
                                        trans.profile,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      leading: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                      onTap: () {
                                        // Navigator.pushReplacementNamed(
                                        //     context, '/profile');
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => ProfilePage(
                                                    user: user,
                                                    userCountry: _country,
                                                  )),
                                        );
                                      },
                                    ),

                                    ////////// Logout ///////////
                                    ///
                                    ListTile(
                                      title: Text(
                                        trans.logout,
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      leading: Icon(
                                        Icons.exit_to_app,
                                        color: Colors.white,
                                      ),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => LogoutPage(
                                                    user: currentUser,
                                                    userRepository:
                                                        UserRepository(),
                                                  )),
                                        );
                                      },
                                    ),
///////////////// END MENU ///////////////
                                  ],
                                ),
                              )
                            ],
                          ))),
                  Container(
                    height: 56,
                    color: ordersBackground,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: LEFT_MARGINE, right: RIGHT_MARGINE),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: <Widget>[
                          InkWell(
                            child: Text(trans.close),
                            onTap: () {
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
