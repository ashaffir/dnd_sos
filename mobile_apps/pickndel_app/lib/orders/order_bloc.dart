import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pickndell/common/error_page.dart';
import 'package:pickndell/model/open_orders.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/networking/Response.dart';
import 'package:pickndell/repository/order_repository.dart';

class OrdersBloc {
  final String ordersType;
  final BuildContext context;
  final User user;

  OrderRepository _orderRepository;
  StreamController _orderDataController;
  bool _isStreaming;

  StreamSink<Response<Orders>> get orderDataSink => _orderDataController.sink;

  Stream<Response<Orders>> get orderDataStream => _orderDataController.stream;

  OrdersBloc({this.context, this.ordersType, this.user}) {
    _orderDataController = StreamController<Response<Orders>>();
    _orderRepository = OrderRepository();
    _isStreaming = true;
    fetchOrder(ordersType);
  }

  fetchOrder(String ordersType) async {
    // final trans = ExampleLocalizations.of(context);

    if (ordersType == 'openOrders') {
      orderDataSink.add(Response.loading(''));
    } else if (ordersType == 'activeOrders') {
      orderDataSink.add(Response.loading(''));
    } else if (ordersType == 'businessOrders') {
      orderDataSink.add(Response.loading(''));
    } else if (ordersType == 'rejectedOrders') {
      orderDataSink.add(Response.loading(''));
    } else if (ordersType == 'requestedOrders') {
      orderDataSink.add(Response.loading(''));
    } else if (ordersType == 'startedOrders') {
      orderDataSink.add(Response.loading(''));
    } else if (ordersType == 'inProgressOrders') {
      orderDataSink.add(Response.loading(''));
    } else if (ordersType == 'deliveredOrders') {
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
      } else if (_isStreaming) {
        orderDataSink.add(Response.error(e.toString()));
        print('ERROR >> ORDER BLOC: Failed to load orders. ERROR: $e');
        return Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ErrorPage(
                user: user,
                errorMessage: 'Error server communications',
              );
            },
          ),
          (Route<dynamic> route) => false, // No Back option for this page
        );
      }
    }
  }

  dispose() {
    _isStreaming = false;
    _orderDataController?.close();
  }
}
