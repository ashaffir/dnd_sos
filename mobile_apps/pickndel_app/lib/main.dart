import 'package:pickndell/app_localizations.dart';
import 'package:pickndell/home/welcome.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/location/gmap.dart';
import 'package:pickndell/orders/order_accepted.dart';
import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pickndell/repository/user_repository.dart';

import 'package:pickndell/bloc/authentication_bloc.dart';
import 'package:pickndell/ui/splash.dart';
import 'package:pickndell/login/login_page.dart';
import 'package:pickndell/common/common.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bloc/authentication_bloc.dart';
import 'home/home_page_isolate.dart';
import 'login/logout_page.dart';
import 'orders/get_orders_page.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

class SimpleBlocDelegate extends BlocDelegate {
  @override
  void onEvent(Bloc bloc, Object event) {
    super.onEvent(bloc, event);
    print(event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    print(transition);
  }

  @override
  void onError(Bloc bloc, Object error, StackTrace stacktrace) {
    super.onError(bloc, error, stacktrace);
  }
}

void main() async {
  BlocSupervisor.delegate = SimpleBlocDelegate();
  final userRepository = UserRepository();
  runApp(BlocProvider<AuthenticationBloc>(
    create: (context) {
      print('STARTING APP.........');
      return AuthenticationBloc(userRepository: userRepository)
        ..add(AppStarted());
    },
    child: Phoenix(child: App(userRepository: userRepository)),
  ));

  SharedPreferences localStorage = await SharedPreferences.getInstance();
  try {
    final userInfo = await userRepository.userDao.getUser(0);
    int isEmployee = userInfo.isEmployee;
    await localStorage.setInt('isEmployee', isEmployee);
  } catch (e) {
    print('Main page access USER repository');
  }
}

class App extends StatelessWidget {
  final String openOrders = "openOrders";
  final String activeOrders = "activeOrders";
  final String businessOrders = "businessOrders";
  final String rejectedOrders = "rejectedOrders";

  final UserRepository userRepository;

  App({Key key, @required this.userRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
        create: (context) => UserRepository(),
        child: MaterialApp(
          //////////// LANGUAGE SUPPORT ///////////
          localizationsDelegates: [
            ExampleLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: ExampleLocalizations.supportedLocales,
          //////////// END LANGUAGE ///////////
          theme: ThemeData(
            primarySwatch: Colors.red,
            brightness: Brightness.dark,
          ),
          home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
            builder: (context, state) {
              if (state is AuthenticationUninitialized) {
                return SplashPage();
              } else if (state is AuthenticationAuthenticated) {
                // return WelcomePage(
                //   userRepository: userRepository,
                // );
                return HomePageIsolate(
                  userRepository: userRepository,
                );

                // return MaterialApp(
                //   title: 'Flutter Google Maps Demo',
                //   home: GMap(),
                // );
              } else if (state is AuthenticationUnauthenticated) {
                return LoginPage(
                  userRepository: userRepository,
                );
                // WelcomePage();
              } else if (state is AuthenticationLoading) {
                return LoadingIndicator();
              }
            },
          ),
          routes: {
            '/logout': (context) => LogoutPage(
                  userRepository: userRepository,
                ),
            '/login': (context) => LoginPage(
                  userRepository: null,
                ),
            '/open-orders': (context) => GetOrders(openOrders),
            '/active-orders': (context) => GetOrders(activeOrders),
            '/business-orders': (context) => GetOrders(businessOrders),
            '/rejected-orders': (context) => GetOrders(rejectedOrders),
            '/order-accepted': (context) => OrderAccepted(),
          },
        ));
  }
}
