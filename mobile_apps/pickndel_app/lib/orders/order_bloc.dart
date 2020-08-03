import 'dart:async';
import 'package:bloc_login/model/open_orders.dart';
import 'package:bloc_login/networking/Response.dart';
import 'package:bloc_login/repository/order_repository.dart';

class OrdersBloc {
  final String ordersType;

  OrderRepository _orderRepository;
  StreamController _orderDataController;
  bool _isStreaming;

  StreamSink<Response<Orders>> get orderDataSink => _orderDataController.sink;

  Stream<Response<Orders>> get orderDataStream => _orderDataController.stream;

  OrdersBloc(this.ordersType) {
    _orderDataController = StreamController<Response<Orders>>();
    _orderRepository = OrderRepository();
    _isStreaming = true;
    fetchOrder(ordersType);
  }

  fetchOrder(String ordersType) async {
    if (ordersType == 'openOrders') {
      orderDataSink.add(Response.loading('Getting Open Orders'));
    } else {
      orderDataSink.add(Response.loading('Getting Active Orders'));
    }
    try {
      Orders orderDetails =
          await _orderRepository.fetchOrderDetails(ordersType);
      print('OID 1 >>> ${orderDetails.orders[0].order_id}');
      if (_isStreaming) orderDataSink.add(Response.completed(orderDetails));
    } catch (e) {
      if (_isStreaming) orderDataSink.add(Response.error(e.toString()));
      print(e);
    }
  }

  dispose() {
    _isStreaming = false;
    _orderDataController?.close();
  }
}
