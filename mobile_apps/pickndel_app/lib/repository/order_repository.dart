import 'package:bloc_login/model/open_orders.dart';
import 'package:bloc_login/networking/ApiProvider.dart';
import 'package:bloc_login/model/orders.dart';
import 'dart:async';

class OrderRepository {
  ApiProvider _provider = ApiProvider();

  Future<OpenOrders> fetchOrderDetails() async {
    var response = await _provider.get("user-orders/?format=json");
    print('>>> RESPONSE: ${response}');
    OpenOrders od = OpenOrders();
    od.orders = [];
    for (var json in response) {
      od.orders.add(Order.fromJson(json));
    }
    print('OID 0 >>>> : ${od.orders[0].order_id}');

    return od;
    //REFERENCE: https://stackoverflow.com/questions/51854891/error-listdynamic-is-not-a-subtype-of-type-mapstring-dynamic
  }
}
