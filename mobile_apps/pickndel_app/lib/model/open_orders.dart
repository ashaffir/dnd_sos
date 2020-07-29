import 'orders.dart';

class OpenOrders {
  List<Order> orders;

  OpenOrders({this.orders});

  OpenOrders.fromJson(Map<String, dynamic> json) {
    if (json['questions'] != null) {
      orders = new List<Order>();
      json['orders'].forEach((v) {
        orders.add(new Order.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.orders != null) {
      data['orders'] = this.orders.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
