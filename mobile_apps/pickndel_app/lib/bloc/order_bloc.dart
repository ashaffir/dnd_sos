import 'dart:async';
import 'package:bloc_login/model/open_orders.dart';
import 'package:bloc_login/networking/Response.dart';
import 'package:bloc_login/repository/order_repository.dart';
import 'package:bloc_login/model/orders.dart';

class OrderBloc {
  OrderRepository _orderRepository;
  StreamController _orderDataController;
  bool _isStreaming;

  StreamSink<Response<OpenOrders>> get orderDataSink =>
      _orderDataController.sink;

  Stream<Response<OpenOrders>> get orderDataStream =>
      _orderDataController.stream;

  OrderBloc() {
    _orderDataController = StreamController<Response<OpenOrders>>();
    _orderRepository = OrderRepository();
    _isStreaming = true;
    fetchOrder();
  }

  fetchOrder() async {
    orderDataSink.add(Response.loading('Getting Open Orders'));
    try {
      OpenOrders orderDetails = await _orderRepository.fetchOrderDetails();
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
