import 'dart:ui' as ui;
import '../common/common.dart';
import 'package:pickndell/common/helper.dart';
import 'package:pickndell/common/loading.dart';
import 'package:pickndell/dao/user_dao.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/orders/empty_list.dart';
import 'package:pickndell/orders/order_bloc.dart';
import 'package:pickndell/orders/order_delivered.dart';
import 'package:pickndell/orders/order_list.dart';
import 'package:pickndell/orders/order_page.dart';
import 'package:pickndell/orders/order_picked_up.dart';
import 'package:pickndell/orders/order_re_requested.dart';
import 'package:pickndell/orders/order_rejected.dart';
import 'package:pickndell/ui/bottom_nav_bar.dart';
import 'package:pickndell/model/order.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/orders/order_accepted.dart';
import 'package:flutter/material.dart';
import 'package:pickndell/networking/Response.dart';
import 'package:pickndell/model/open_orders.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class GetOrders extends StatefulWidget {
  final String ordersType;
  GetOrders(this.ordersType);

  @override
  _GetOrdersState createState() => _GetOrdersState();
}

class _GetOrdersState extends State<GetOrders> {
  OrdersBloc _bloc;
  String pageTitle;
  bool locationTracking;
  User _currentUser;

  Future<bool> _checkTrackingStatus() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    locationTracking = await localStorage.get('locationTracking');
    if (locationTracking == null) {
      return false;
    } else {
      return locationTracking;
    }
  }

  Future _checkUser() async {
    _currentUser = await UserDao().getUser(0);
  }

  @override
  void initState() {
    super.initState();
    _checkUser();
    _checkTrackingStatus();
    _bloc = OrdersBloc(widget.ordersType);
    // if (widget.ordersType == 'openOrders') {
    //   pageTitle = 'Open Orders';
    // } else if (widget.ordersType == 'activeOrders') {
    //   pageTitle = 'Active Orders';
    // } else if (widget.ordersType == 'businessOrders') {
    //   pageTitle = 'Current Open Orders';
    // } else if (widget.ordersType == 'rejectedOrders') {
    //   pageTitle = 'Orders Require Your Attention';
    // } else {
    //   pageTitle = '';
    // }
    // pageTitle =
    //     widget.ordersType == 'openOrders' ? 'Open Orders' : 'Active Orders';
  }

  @override
  Widget build(BuildContext context) {
    final translations = ExampleLocalizations.of(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _bloc.fetchOrder(widget.ordersType);
        },
        backgroundColor: Colors.green[100],
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
      backgroundColor: mainBackground,
      body: RefreshIndicator(
        onRefresh: () => _bloc.fetchOrder(widget.ordersType),
        child: StreamBuilder<Response<Orders>>(
          stream: _bloc.orderDataStream,
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot != null) {
              switch (snapshot.data.status) {
                case Status.LOADING:
                  return Loading(loadingMessage: snapshot.data.message);
                  break;
                case Status.COMPLETED:
                  return OrdersList(
                    currentUser: _currentUser,
                    ordersList: snapshot.data.data,
                    ordersType: widget.ordersType,
                    locationTracking: locationTracking,
                  );
                  break;
                case Status.ERROR:
                  {
                    if (snapshot.data.data == null) {
                      return EmptyList();
                    } else {
                      return Error(
                        errorMessage: snapshot.data.message,
                        // onRetryPressed: () => _bloc.fetchOrder(),
                      );
                    }
                  }
                  break;
              }
            }
            return Container();
          },
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }
}
