import 'package:pickndell/dao/user_dao.dart';
import 'package:pickndell/model/open_orders.dart';
import 'package:pickndell/networking/ApiProvider.dart';
import 'package:pickndell/model/order.dart';
import 'dart:async';
import 'dart:convert';

class OrderRepository {
  ApiProvider _provider = ApiProvider();

  Future<Orders> fetchOrderDetails(String ordersType) async {
    var _openOrdersUrl = "open-orders/?q=open";
    var _activeOrdersUrl = "active-orders/?user=";
    var _businessOrdersUrl = "business-orders/?user=";
    var _rejectedOrdersUrl = "rejected-orders/?user=";

    var _user = await UserDao().getUser(0);
    var _response = ordersType == 'openOrders'
        ? await _provider.get(_openOrdersUrl, _user)
        : ordersType == 'activeOrders'
            ? await _provider.get(_activeOrdersUrl, _user)
            : ordersType == 'businessOrders'
                ? await _provider.get(_businessOrdersUrl, _user)
                : await _provider.get(_rejectedOrdersUrl, _user);

    Orders od = Orders();
    od.orders = [];
    for (var json in _response) {
      od.orders.add(Order.fromJson(json));
      print('RESE: $json');
    }

    // check order language coming from the API call
    // var heb = od.orders[0].pick_up_address;
    // print('OID 0 >>>> : ${heb}');

    return od;
    //REFERENCE: ERROR https://stackoverflow.com/questions/51854891/error-listdynamic-is-not-a-subtype-of-type-mapstring-dynamic
  }

  Future updateOrder(String orderId, String status) async {
    var _url = "order-update/";
    try {
      var user = await UserDao().getUser(0);
      var response = await _provider.put(_url, orderId, user, status);
      print('>>> POST RESPONSE: $response');
      return response;
    } catch (e) {
      print('REPO ERROR: $e');
      return e;
    }
  }
}
