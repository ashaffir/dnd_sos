import 'package:bloc_login/bloc/authentication_bloc.dart';
import 'package:bloc_login/login/bloc/login_bloc.dart';
import 'package:bloc_login/login/login_page.dart';
import 'package:bloc_login/repository/user_repository.dart';
import 'package:bloc_login/ui/bottom_nav_bar.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:get/get.dart';

class LogoutPage extends StatelessWidget {
  final UserRepository userRepository;

  LogoutPage({Key key, @required this.userRepository})
      : assert(userRepository != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final AuthenticationBloc authenticationBloc =
        BlocProvider.of<AuthenticationBloc>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Logout'),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              Image.asset(
                'assets/images/pickndell-logo-white.png',
                width: MediaQuery.of(context).size.width * 0.70,
                // height: MediaQuery.of(context).size.height * 0.50,
                // width: 300,
              ),
              Center(
                  child: RaisedButton(
                      child: Text('logout'),
                      // onPressed: () => Phoenix.rebirth(context),
                      onPressed: () {
                        print('LOGOUT pushed.......');
                        BlocProvider.of<AuthenticationBloc>(context)
                            .add(LoggedOut());
                        Phoenix.rebirth(context);
                      }
                      //   BlocProvider.of<AuthenticationBloc>(context).add(LoggedOut());
                      //   Navigator.pushNamedAndRemoveUntil(
                      //       context, '/login', (_) => false);
                      // },
                      // onPressed: () {
                      //   authenticationBloc.add(LoggedOut());
                      //   Navigator.of(context).push(new MaterialPageRoute(
                      //       builder: (BuildContext context) => new LoginPage(
                      //             userRepository: userRepository,
                      //           )));
                      // },
                      )),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(userRepository: userRepository),
    );
  }
}
// import 'package:bloc_login/home/home_page_isolate.dart';
// import 'package:bloc_login/login/login_form.dart';
// import 'package:bloc_login/ui/bottom_nav_bar.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:bloc_login/bloc/authentication_bloc.dart';

// import '../repository/user_repository.dart';
// import 'bloc/login_bloc.dart';
// import 'login_page.dart';

// class LogoutPage extends StatefulWidget {
//   final UserRepository userRepository;

//   LogoutPage({Key key, @required this.userRepository})
//       : assert(userRepository != null),
//         super(key: key);

//   @override
//   _LogoutPageState createState() => _LogoutPageState();
// }

// class _LogoutPageState extends State<LogoutPage> {
//   bool _isLoading = false;

//   @override
//   Widget build(BuildContext context) {
//     _onLogoutButtonPressed() {
//       setState(() {
//         _isLoading = true;
//         // AuthenticationUnauthenticated();
//       });
//       BlocProvider.of<LoginBloc>(context).add(LogoutButtonPressed());
//     }

//     return BlocBuilder<LoginBloc, LoginState>(
//       builder: (context, state) {
//         return Scaffold(
//           appBar: AppBar(
//             title: Text('Logout'),
//           ),
//           body: Container(
//             child: Padding(
//               padding: const EdgeInsets.only(right: 40, left: 40, bottom: 40.0),
//               child: SingleChildScrollView(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: <Widget>[
//                     Image.asset(
//                       'assets/images/pickndell-logo-white.png',
//                       width: MediaQuery.of(context).size.width * 0.70,
//                       // height: MediaQuery.of(context).size.height * 0.50,
//                       // width: 300,
//                     ),
//                     Padding(
//                       padding: EdgeInsets.only(left: 30.0),
//                     ),
//                     Padding(
//                       padding: EdgeInsets.only(top: 100),
//                       child: Container(
//                         // width: MediaQuery.of(context).size.width * 0.85,
//                         // height: MediaQuery.of(context).size.width * 0.16,
//                         child: RaisedButton(
//                           child: Text(
//                             'Logout',
//                             style: TextStyle(
//                               fontSize: 15,
//                             ),
//                           ),
//                           onPressed: _onLogoutButtonPressed(),
//                           // () {
//                           //   BlocProvider.of<AuthenticationBloc>(context)
//                           //       .add(LoggedOut());
//                           //   Navigator.of(context).push(new MaterialPageRoute(
//                           //       builder: (BuildContext context) =>
//                           //           new LoginPage(
//                           //             userRepository: widget.userRepository,
//                           //           )));
//                           // Navigator.pushAndRemoveUntil(
//                           //   context,
//                           //   MaterialPageRoute(
//                           //       builder: (context) => HomePageIsolate()),
//                           //   (Route<dynamic> route) => false,
//                           // );
//                           // },
//                           shape: StadiumBorder(
//                             side: BorderSide(
//                               color: Colors.black,
//                               width: 2,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }
// //      Scaffold(
// //       appBar: AppBar(
// //         title: Text('Logout'),
// //       ),
// //       body: Container(
// //         child: Padding(
// //           padding: const EdgeInsets.only(right: 40, left: 40, bottom: 40.0),
// //           child: SingleChildScrollView(
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               crossAxisAlignment: CrossAxisAlignment.center,
// //               children: <Widget>[
// //                 Image.asset(
// //                   'assets/images/pickndell-logo-white.png',
// //                   width: MediaQuery.of(context).size.width * 0.70,
// //                   // height: MediaQuery.of(context).size.height * 0.50,
// //                   // width: 300,
// //                 ),
// //                 Padding(
// //                   padding: EdgeInsets.only(left: 30.0),
// //                 ),
// //                 Padding(
// //                   padding: EdgeInsets.only(top: 100),
// //                   child: Container(
// //                     // width: MediaQuery.of(context).size.width * 0.85,
// //                     // height: MediaQuery.of(context).size.width * 0.16,
// //                     child: RaisedButton(
// //                       child: Text(
// //                         'Logout',
// //                         style: TextStyle(
// //                           fontSize: 15,
// //                         ),
// //                       ),
// //                       onPressed: () {
// //                         BlocProvider.of<AuthenticationBloc>(context)
// //                             .add(LoggedOut());
// //                         Navigator.of(context).push(new MaterialPageRoute(
// //                             builder: (BuildContext context) => new LoginPage(
// //                                   userRepository: widget.userRepository,
// //                                 )));
// //                         // Navigator.pushAndRemoveUntil(
// //                         //   context,
// //                         //   MaterialPageRoute(
// //                         //       builder: (context) => HomePageIsolate()),
// //                         //   (Route<dynamic> route) => false,
// //                         // );
// //                       },
// //                       shape: StadiumBorder(
// //                         side: BorderSide(
// //                           color: Colors.black,
// //                           width: 2,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //       bottomNavigationBar: BottomNavBar(),
// //     );
// //   }
// // }
// }
