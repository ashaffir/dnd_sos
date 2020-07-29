import 'dart:async';

import 'package:bloc_login/networking/Response.dart';
import 'package:bloc_login/repository/open_orders_repository.dart';
import 'package:bloc_login/model/open_orders.dart';

class OpenOrdersBloc {
  OpenOrdersRepository _openOrdersRepository;
  StreamController _openOrdersListController;

  StreamSink<Response<OpenOrders>> get openOrdersListSink =>
      _openOrdersListController.sink;

  Stream<Response<OpenOrders>> get openOrdersListStream =>
      _openOrdersListController.stream;

  OpenOrdersBloc() {
    _openOrdersListController = StreamController<Response<OpenOrders>>();
    _openOrdersRepository = OpenOrdersRepository();
    fetchOpenOrders();
  }

  fetchOpenOrders() async {
    openOrdersListSink.add(Response.loading('Getting Open Orders.'));
    try {
      OpenOrders openOrds = await _openOrdersRepository.fetchOpenOrdersData();
      openOrdersListSink.add(Response.completed(openOrds));
    } catch (e) {
      openOrdersListSink.add(Response.error(e.toString()));
      print('>>>> ERROR ${e}');
    }
  }

  dispose() {
    _openOrdersListController?.close();
  }
}
