class TestOrder {
  String orderId;
  String created;
  String updated;
  String pickUpAddress;
  String dropOffAddress;
  String orderType;
  String orderCityName;
  String orderStreetName;
  double distanceToBusiness;
  double price;
  String status;

  TestOrder({
    this.orderId,
    this.created,
    this.updated,
    this.pickUpAddress,
    this.dropOffAddress,
    this.orderType,
    this.orderCityName,
    this.orderStreetName,
    this.distanceToBusiness,
    this.price,
    this.status,
  });

  factory TestOrder.fromJson(Map<String, dynamic> json) {
    return TestOrder(
        orderId: json['order_id'],
        created: json['created'],
        updated: json['updated'],
        pickUpAddress: json['pick_up_address'],
        dropOffAddress: json['drop_off_address'],
        orderType: json['order_type'],
        orderCityName: json['order_city_name'],
        orderStreetName: json['order_street_name'],
        distanceToBusiness: json['distance_to_business'],
        price: json['price'],
        status: json['status']);
  }
}
