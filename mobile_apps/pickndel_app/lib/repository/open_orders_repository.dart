import 'package:bloc_login/networking/ApiProvider.dart';
import 'dart:async';
import 'package:bloc_login/model/open_orders.dart';

class OpenOrdersRepository {
  ApiProvider _provider = ApiProvider();

  Future<OpenOrders> fetchOpenOrdersData() async {
    final response = await _provider.get("user-orders/");
    return OpenOrders.fromJson(response);
  }
}
