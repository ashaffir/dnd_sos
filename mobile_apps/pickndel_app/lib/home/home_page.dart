import 'package:flutter/material.dart';

import '../dao/user_dao.dart';
import '../dao/user_dao.dart';
import '../dao/user_dao.dart';
import '../dao/user_dao.dart';
import '../database/user_database.dart';
import '../database/user_database.dart';
import '../model/user_model.dart';
import 'bottom_nav_bar.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: UserDao().getUser(0),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
        if (snapshot.hasData) {
          print('SNAPSH: ${snapshot.data.username}');
        } else {
          print("No data");
        }
        return getHomePage(snapshot.data);
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    build(context);
  }

  // Future getCurrentUser(int id) async {
  //   User currentUser = User();
  //   UserDao userDao = UserDao();
  //   print('ID: $id');
  //   try {
  //     print('P: 1');
  //     currentUser = await userDao.getUser(id);
  //     print('CURRENT: $currentUser');
  //   } catch (e) {
  //     print('NO FUCKING DATA. $e');
  //   }
  //   return currentUser;
  // }

  Widget getHomePage(User currentUser) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/images/pickndel-logo-1.png',
                width: MediaQuery.of(context).size.width * 0.70,
                // height: MediaQuery.of(context).size.height * 0.50,
                // width: 300,
              ),
              Padding(
                padding: EdgeInsets.only(left: 30.0),
                child: Text(
                  'Welcome: ${currentUser.token}',
                  style: TextStyle(
                    fontSize: 24.0,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(34.0, 20.0, 0.0, 0.0),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.width * 0.16,
                  // child: RaisedButton(
                  //   child: Text(
                  //     'Logout',
                  //     style: TextStyle(
                  //       fontSize: 24,
                  //     ),
                  //   ),
                  //   onPressed: () {
                  //     BlocProvider.of<AuthenticationBloc>(context)
                  //         .add(LoggedOut());
                  //   },
                  //   shape: StadiumBorder(
                  //     side: BorderSide(
                  //       color: Colors.black,
                  //       width: 2,
                  //     ),
                  //   ),
                  // ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
      // resizeToAvoidBottomPadding: false,
    );
  }
}
