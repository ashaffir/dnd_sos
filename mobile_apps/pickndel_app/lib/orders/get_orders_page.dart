import 'dart:ui' as ui;
import 'package:pickndell/location/geo_helpers.dart';
import 'package:pickndell/ui/bottom_navigation_bar.dart';
import 'package:pickndell/ui/progress_indicator.dart';

import '../common/common.dart';
import 'package:pickndell/dao/user_dao.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/orders/empty_list.dart';
import 'package:pickndell/orders/order_bloc.dart';
import 'package:pickndell/orders/order_list.dart';
import 'package:pickndell/common/global.dart';
import 'package:flutter/material.dart';
import 'package:pickndell/networking/Response.dart';
import 'package:pickndell/model/open_orders.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GetOrders extends StatefulWidget {
  final String ordersType;
  final User user;
  GetOrders({this.ordersType, this.user});

  @override
  _GetOrdersState createState() => _GetOrdersState();
}

class _GetOrdersState extends State<GetOrders> {
  OrdersBloc _bloc;
  String pageTitle;
  bool locationTracking;
  User _currentUser;
  String _country;

  Future<bool> _checkTrackingStatus() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    locationTracking = await localStorage.get('locationTracking');
    if (locationTracking == null) {
      return false;
    } else {
      return locationTracking;
    }
  }

  Future _checkCountry() async {
    _country = await getCountryName();
  }

  Future _checkUser() async {
    _currentUser = await UserDao().getUser(0);
  }

  @override
  void initState() {
    super.initState();
    _checkUser();
    _checkTrackingStatus();
    _checkCountry();
    _bloc = OrdersBloc(widget.ordersType);
  }

  @override
  Widget build(BuildContext context) {
    final translations = ExampleLocalizations.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _bloc.fetchOrder(widget.ordersType);
        },
        elevation: 2.0,
        tooltip: 'Refresh list',
        backgroundColor: FLOATING_RELOAD_BUTTON_COLOR,
        child: new Icon(Icons.refresh),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      appBar: AppBar(
        elevation: 0.0,
        automaticallyImplyLeading: false,
        title: Text(
            widget.ordersType == 'openOrders'
                ? translations.orders_title_open
                : widget.ordersType == 'activeOrders'
                    ? translations.orders_title_active
                    : widget.ordersType == 'businessOrders'
                        ? translations.orders_title_business
                        : widget.ordersType == 'rejectedOrders'
                            ? translations.orders_title_rejected
                            : '---',
            style: TextStyle(color: Colors.white, fontSize: 20)),
        backgroundColor: mainBackground,
      ),
      // backgroundColor: mainBackground,
      body: RefreshIndicator(
        onRefresh: () => _bloc.fetchOrder(widget.ordersType),
        child: StreamBuilder<Response<Orders>>(
          stream: _bloc.orderDataStream,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot != null) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  // return Loading(loadingMessage: snapshot.data.message);
                  return ColoredProgressDemo(translations.loading_orders);
                  break;
                case Status.COMPLETED:
                  return OrdersList(
                    user: _currentUser,
                    ordersList: snapshot.data.data,
                    ordersType: widget.ordersType,
                    locationTracking: locationTracking,
                    country: _country,
                  );
                  break;
                case Status.EMPTY:
                  return EmptyList();
                  break;
                case Status.ERROR:
                  return ErrorPage(
                    user: widget.user,
                    errorMessage:
                        'There is a problem communicating with our server. Please try again later.',
                    // onRetryPressed: () => _bloc.fetchOrder(),
                  );
                  break;
              }
            }
            return Container();
          },
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        user: _currentUser,
      ),
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
