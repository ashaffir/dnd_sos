import 'package:flutter/material.dart';
import 'package:pickndell/common/error_page.dart';
import 'package:pickndell/dao/user_dao.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/location/place.dart';
import 'package:pickndell/model/open_orders.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/networking/ApiProvider.dart';
import 'package:pickndell/model/order.dart';
import 'dart:async';

class OrderRepository {
  ApiProvider _provider = ApiProvider();

  User user;
  BuildContext context;

  OrderRepository({this.user, this.context});

  Future<Orders> fetchOrderDetails(String ordersType) async {
    var _openOrdersUrl = "open-orders/?q=open";
    var _activeOrdersUrl = "active-orders/?user=";
    var _businessOrdersUrl = "business-orders/?user=";
    var _rejectedOrdersUrl = "rejected-orders/?user=";
    var _requestedOrdersUrl = "requested-orders/?user=";
    var _startedOrdersUrl = "started-orders/?user=";
    var _inProgressOrdersUrl = "in-progress-orders/?user=";
    var _deliveredOrdersUrl = "delivered-orders/?user=";

    var _user = await UserDao().getUser(0);
    var _response = ordersType == 'openOrders'
        ? await _provider.get(_openOrdersUrl, _user)
        : ordersType == 'activeOrders'
            ? await _provider.get(_activeOrdersUrl, _user)
            : ordersType == 'businessOrders'
                ? await _provider.get(_businessOrdersUrl, _user)
                : ordersType == 'requestedOrders'
                    ? await _provider.get(_requestedOrdersUrl, _user)
                    : ordersType == 'startedOrders'
                        ? await _provider.get(_startedOrdersUrl, _user)
                        : ordersType == 'inProgressOrders'
                            ? await _provider.get(_inProgressOrdersUrl, _user)
                            : ordersType == 'deliveredOrders'
                                ? await _provider.get(
                                    _deliveredOrdersUrl, _user)
                                : await _provider.get(
                                    _rejectedOrdersUrl, _user);

    Orders od = Orders();
    od.orders = [];
    for (var json in _response) {
      od.orders.add(Order.fromJson(json));
      // print('RESE: $json');
    }

    // check order language coming from the API call
    // var heb = od.orders[0].pick_up_address;
    // print('OID 0 >>>> : ${heb}');

    return od;
    //REFERENCE: ERROR https://stackoverflow.com/questions/51854891/error-listdynamic-is-not-a-subtype-of-type-mapstring-dynamic
  }

  Future updateOrder(String orderId, String status) async {
    final trans = ExampleLocalizations.of(context);
    var _url = "order-update/";
    try {
      // var user = await UserDao().getUser(0);
      var response = await _provider.put(_url, orderId, user, status);
      // print('>>>UPDATE ORDER POST RESPONSE: $response');
      return response;
    } catch (e) {
      print('UPDATE ORDER ERROR: $e');
      return Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ErrorPage(
              user: user,
              errorMessage: trans.messages_communication_error,
            );
          },
        ),
        (Route<dynamic> route) => false, // No Back option for this page
      );
    }
  }

  Future getPriceParamsRepo({User user}) async {
    final trans = ExampleLocalizations.of(context);

    var _url = "price-parameteres/";
    try {
      var response = await _provider.priceParams(user: user, url: _url);
      print('Price Params: $response');
      return response;
    } catch (e) {
      print('ERROR GETTING CURRENT PRICE PARAMS: $e');
      return Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ErrorPage(
              user: user,
              errorMessage: trans.messages_communication_error,
            );
          },
        ),
        (Route<dynamic> route) => false, // No Back option for this page
      );
    }
  }

  Future newOrderRepo(
      {OrderAddress pickupAddress,
      OrderAddress dropoffAddress,
      User user,
      bool priceOrder,
      String packageType,
      String urgency}) async {
    var _url = "new-order/";
    ApiProvider _provider = ApiProvider();
    final trans = ExampleLocalizations.of(context);

    try {
      // var user = await UserDao().getUser(0);
      var response = await _provider.postNewOrder(
          url: _url,
          pickupAddress: pickupAddress,
          dropoffAddress: dropoffAddress,
          user: user,
          priceOrder: priceOrder,
          packageType: packageType,
          urgency: urgency);
      print('>>> NEW ORDER RESPONSE: $response');
      return response;
    } catch (e) {
      print('NEW ORDER REPO ERROR: $e');
      return Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ErrorPage(
              user: user,
              errorMessage: trans.messages_communication_error,
            );
          },
        ),
        (Route<dynamic> route) => false, // No Back option for this page
      );
    }
  }
}
