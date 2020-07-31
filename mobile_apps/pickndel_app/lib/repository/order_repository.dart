import 'package:bloc_login/model/open_orders.dart';
import 'package:bloc_login/networking/ApiProvider.dart';
import 'package:bloc_login/model/orders.dart';
import 'dart:async';
import 'dart:convert';

class OrderRepository {
  ApiProvider _provider = ApiProvider();

  Future<OpenOrders> fetchOrderDetails() async {
    var response = await _provider.get("user-orders/?format=json");
    // print('>>> RESPONSE: ${response}');
    OpenOrders od = OpenOrders();
    od.orders = [];
    for (var json in response) {
      od.orders.add(Order.fromJson(json));
    }

    // check order language coming from the API call
    // var heb = od.orders[0].pick_up_address;
    // print('OID 0 >>>> : ${heb}');

    return od;
    //REFERENCE: https://stackoverflow.com/questions/51854891/error-listdynamic-is-not-a-subtype-of-type-mapstring-dynamic
  }
}
