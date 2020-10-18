import 'dart:ui' as ui;
import 'package:pickndell/lang/lang_helper.dart';
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

class FilteredOrders {
  final String title;
  final String uri;
  final String ordersType;
  final Icon icon;
  FilteredOrders({this.title, this.uri, this.ordersType, this.icon});
}

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
  String _userCountry;

  int _rookieLevelLimit;
  int _advancedLevelLimit;
  int _expertLevelLimit;

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
    _userCountry = await getCountryName();
    setState(() {
      _country = _userCountry;
    });
  }

  int _isEmployee;
  // int currentIsEmployee;

  Future _checkUser() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    _isEmployee = localStorage.getInt('isEmployee');
    _currentUser = await UserDao().getUser(0);
  }

  Future _checAccountLevels() async {
    SharedPreferences localStorage = await SharedPreferences.getInstance();
    _rookieLevelLimit = localStorage.getInt('rookieLevel');
    _advancedLevelLimit = localStorage.getInt('advancedLevel');
    _expertLevelLimit = localStorage.getInt('expertLevel');
  }

  FilteredOrders _filteredOrders;
  List<FilteredOrders> _filteredOrdersList = <FilteredOrders>[
    FilteredOrders(
        title: 'All Orders',
        uri: '/business-orders',
        ordersType: 'businessOrders'),
    FilteredOrders(
        title: 'Requested',
        uri: '/requested-orders',
        ordersType: 'requestedOrders'),
    FilteredOrders(
        title: 'Started', uri: '/started-orders', ordersType: 'startedOrders'),
    FilteredOrders(
        title: 'In Progress',
        uri: '/in-progress-orders',
        ordersType: "inProgressOrders"),
    FilteredOrders(
        title: 'Delivered',
        uri: '/delivered-orders',
        ordersType: 'deliveredOrders'),
    FilteredOrders(
        title: 'Rejected',
        uri: '/rejected-orders',
        ordersType: 'rejectedOrders')
  ];

  @override
  void initState() {
    super.initState();
    _checkUser();
    _checkTrackingStatus();
    _checkCountry();
    _checAccountLevels();
    _bloc = OrdersBloc(
        context: context, ordersType: widget.ordersType, user: widget.user);
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
        title: Row(
          children: [
            Text(
                widget.ordersType == 'openOrders'
                    ? translations.orders_title_open
                    : widget.ordersType == 'activeOrders'
                        ? translations.orders_title_active
                        : widget.ordersType == 'businessOrders'
                            ? translations.orders_title_open
                            : widget.ordersType == 'rejectedOrders'
                                ? translations.alerts
                                : widget.ordersType == 'requestedOrders'
                                    ? translations.orders_title_new_orders
                                    : widget.ordersType == 'startedOrders'
                                        ? translations.orders_title_business
                                        : widget.ordersType ==
                                                'inProgressOrders'
                                            ? translations
                                                .business_orders_in_progress
                                            : widget.ordersType ==
                                                    'deliveredOrders'
                                                ? translations.delivered_orders
                                                : '---',
                style: TextStyle(color: Colors.white, fontSize: 20)),
            // if (widget.user.isEmployee == 0)
            if (_isEmployee == 0)
              DropdownButton(
                underline: SizedBox(),
                icon: Icon(Icons.filter_list),
                value: _filteredOrders,
                onChanged: (value) {
                  print('Filter: $_country');
                  setState(() {
                    print('VALUE: ${value.title}');
                    _filteredOrders = value;
                  });
                  print('Filtering: ${_filteredOrders.uri}');
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return GetOrders(
                          user: widget.user,
                          ordersType: _filteredOrders.ordersType,
                        );
                      },
                    ),
                    (Route<dynamic> route) =>
                        false, // No Back option for this page
                  );
                  // Navigator.pushReplacementNamed(
                  //     context, '${_filteredOrders.uri}');
                },
                items: _filteredOrdersList
                    .map<DropdownMenuItem<FilteredOrders>>(
                        (FilteredOrders value) {
                  return DropdownMenuItem<FilteredOrders>(
                    value: value,
                    child: _country == 'Israel' || _country == 'ישראל'
                        ? Text(translateOrdersList(value.title))
                        : Text(value.title),
                  );
                }).toList(),
              ),
          ],
        ),
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
                    rookieLevelLimit: _rookieLevelLimit,
                    advancedLevelLimit: _advancedLevelLimit,
                    expertLevelLimit: _expertLevelLimit,
                  );
                  break;
                case Status.EMPTY:
                  return EmptyList();
                  break;
                case Status.ERROR:
                  return ErrorPage(
                    user: widget.user,
                    errorMessage: translations.messages_communication_error,
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
