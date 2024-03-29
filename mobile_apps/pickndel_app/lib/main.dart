import 'package:pickndell/finance/payments.dart';
import 'package:pickndell/home/dashboard.dart';
import 'package:pickndell/home/profile.dart';
import 'package:pickndell/localizations.dart';
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
import 'login/logout_page.dart';
import 'model/user_model.dart';
import 'orders/get_orders_page.dart';

import 'package:flutter_localizations/flutter_localizations.dart';

User userInfo;

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
    userInfo = await userRepository.userDao.getUser(0);
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

  final String requestedOrders = "requestedOrders";
  final String startedOrders = "startedOrders";
  final String inProgressOrders = "inProgressOrders";
  final String deliveredOrders = "deliveredOrders";

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

                // return HomePageIsolate(
                //   userRepository: userRepository,
                // );

                return Dashboard(
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
                // return WelcomePage(userRepository: userRepository);
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
            '/profile': (context) => ProfilePage(),
            '/payments': (context) => PaymentsPage(),
            '/open-orders': (context) => GetOrders(
                  ordersType: openOrders,
                  user: userInfo,
                ),
            '/active-orders': (context) => GetOrders(
                  ordersType: activeOrders,
                  user: userInfo,
                ),
            '/business-orders': (context) => GetOrders(
                  ordersType: businessOrders,
                  user: userInfo,
                ),
            '/requested-orders': (context) => GetOrders(
                  ordersType: requestedOrders,
                  user: userInfo,
                ),
            '/rejected-orders': (context) => GetOrders(
                  ordersType: rejectedOrders,
                  user: userInfo,
                ),
            '/started-orders': (context) => GetOrders(
                  ordersType: startedOrders,
                  user: userInfo,
                ),
            '/in-progress-orders': (context) => GetOrders(
                  ordersType: inProgressOrders,
                  user: userInfo,
                ),
            '/delivered-orders': (context) => GetOrders(
                  ordersType: deliveredOrders,
                  user: userInfo,
                ),
            '/order-accepted': (context) => OrderAccepted(),
          },
        ));
  }
}
