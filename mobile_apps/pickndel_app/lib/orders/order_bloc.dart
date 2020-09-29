import 'dart:async';
import 'package:pickndell/model/open_orders.dart';
import 'package:pickndell/networking/Response.dart';
import 'package:pickndell/repository/order_repository.dart';

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
      orderDataSink.add(Response.loading(''));
    } else if (ordersType == 'activeOrders') {
      orderDataSink.add(Response.loading(''));
    } else if (ordersType == 'businessOrders') {
      orderDataSink.add(Response.loading(''));
    } else if (ordersType == 'rejectedOrders') {
      orderDataSink.add(Response.loading(''));
    } else {
      orderDataSink.add(Response.error('Error loading orders list'));
    }
    try {
      Orders orderDetails =
          await _orderRepository.fetchOrderDetails(ordersType);
      print('OID 1 >>> ${orderDetails.orders[0].order_id}');

      if (_isStreaming) orderDataSink.add(Response.completed(orderDetails));
    } catch (e) {
      // print('EEEEE: ${e.toString().split(" ")[0]}');
      if (e.toString().split(" ")[0] == 'RangeError') {
        orderDataSink.add(Response.empty(e.toString()));
        print('INFO >> ORDER BLOC: Empty orders list. Message: $e');
      } else if (_isStreaming) orderDataSink.add(Response.error(e.toString()));
      print('ERROR >> ORDER BLOC: Failed to load orders. ERROR: $e');
    }
  }

  dispose() {
    _isStreaming = false;
    _orderDataController?.close();
  }
}
