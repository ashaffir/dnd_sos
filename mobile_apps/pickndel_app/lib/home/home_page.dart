import 'package:flutter/material.dart';

import '../dao/user_dao.dart';
import '../model/user_model.dart';
import '../ui/bottom_nav_bar.dart';

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
          return getHomePage(snapshot.data);
        } else {
          print("No data");
        }
        return CircularProgressIndicator();
      },
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // build(context);
  }

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
                  'Welcome: ${currentUser.userId}',
                  style: TextStyle(
                    fontSize: 24.0,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 30.0),
                child: Text(
                  'Carrier: ${currentUser.isEmployee}',
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
