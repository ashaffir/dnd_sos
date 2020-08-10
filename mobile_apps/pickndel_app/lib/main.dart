import 'package:bloc_login/orders/order_accepted.dart';
import 'package:flutter/material.dart';

import 'package:bloc/bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_login/repository/user_repository.dart';

import 'package:bloc_login/bloc/authentication_bloc.dart';
import 'package:bloc_login/ui/splash.dart';
import 'package:bloc_login/login/login_page.dart';
import 'package:bloc_login/home/home.dart';
import 'package:bloc_login/common/common.dart';

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
      return AuthenticationBloc(userRepository: userRepository)
        ..add(AppStarted());
    },
    child: App(userRepository: userRepository),
  ));
}

class App extends StatelessWidget {
  final String openOrders = "openOrders";
  final String activeOrders = "activeOrders";

  final UserRepository userRepository;

  App({Key key, @required this.userRepository}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        const Locale("en", ""),
        const Locale("he", ""),
      ],
      theme: ThemeData(
        primarySwatch: Colors.red,
        brightness: Brightness.dark,
      ),
      home: BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
          if (state is AuthenticationUnintialized) {
            print('--------- 1 -----------');
            return SplashPage();
          } else if (state is AuthenticationAuthenticated) {
            // return HomePage();
            print('--------- 2 -----------');
            print('Loading Home page...');
            return HomePageIsolate(
              userRepository: userRepository,
            );
          } else if (state is AuthenticationUnauthenticated) {
            print('--------- 3 -----------');
            return LoginPage(
              userRepository: userRepository,
            );
          } else if (state is AuthenticationLoading) {
            print('--------- 4 -----------');
            return LoadingIndicator();
          }
        },
      ),
      routes: {
        '/logout': (context) => LogoutPage(
              userRepository: userRepository,
            ),
        '/open-orders': (context) => GetOrders(openOrders),
        '/active-orders': (context) => GetOrders(activeOrders),
        '/order-accepted': (context) => OrderAccepted(),
      },
    );
  }
}
