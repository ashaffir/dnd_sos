import 'package:bloc_login/dao/user_dao.dart';
import 'package:bloc_login/model/open_orders.dart';
import 'package:bloc_login/networking/ApiProvider.dart';
import 'package:bloc_login/model/order.dart';
import 'dart:async';
import 'dart:convert';

class OrderRepository {
  ApiProvider _provider = ApiProvider();

  Future<Orders> fetchOrderDetails(String ordersType) async {
    var _openOrdersUrl = "open-orders/?q=open";
    var _activeOrdersUrl = "active-orders/?user=";

    var _user = await UserDao().getUser(0);
    var _response = ordersType == 'openOrders'
        ? await _provider.get(_openOrdersUrl, _user)
        : await _provider.get(_activeOrdersUrl, _user);

    Orders od = Orders();
    od.orders = [];
    for (var json in _response) {
      od.orders.add(Order.fromJson(json));
    }

    // check order language coming from the API call
    // var heb = od.orders[0].pick_up_address;
    // print('OID 0 >>>> : ${heb}');

    return od;
    //REFERENCE: debug stuff: https://stackoverflow.com/questions/51854891/error-listdynamic-is-not-a-subtype-of-type-mapstring-dynamic
  }

  Future updateOrder(Order order, String status) async {
    var _url = "order-update/";
    try {
      var user = await UserDao().getUser(0);
      var response = await _provider.put(_url, order, user, status);
      print('>>> POST RESPONSE: $response');
      return response;
    } catch (e) {
      print('REPO ERROR: $e');
      return e;
    }
  }
}
