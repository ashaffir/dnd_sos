import 'package:pickndell/common/helper.dart';

class Order {
  String order_id;
  String created;
  String updated;
  String pick_up_address;
  String drop_off_address;
  String order_type;
  String order_city_name;
  String order_street_name;
  String order_country;
  double distance_to_business;
  double price;
  int isUrgent;
  double fare;
  String status;
  String business_phone;
  String business_name;
  String courier_phone;
  String courier_name;
  double pickUpAddressLat;
  double pickUpAddressLng;
  double dropoffAddressLat;
  double dropoffAddressLng;
  double businessLat;
  double businessLng;
  double freelancerRating;
  double businessRating;

  Order({
    this.order_id,
    this.created,
    this.updated,
    this.pick_up_address,
    this.drop_off_address,
    this.order_type,
    this.order_city_name,
    this.order_street_name,
    this.distance_to_business,
    this.price,
    this.isUrgent,
    this.fare,
    this.status,
    this.business_phone,
    this.business_name,
    this.courier_name,
    this.courier_phone,
    this.order_country,
    this.pickUpAddressLat,
    this.pickUpAddressLng,
    this.dropoffAddressLat,
    this.dropoffAddressLng,
    this.businessLat,
    this.businessLng,
    this.freelancerRating,
    this.businessRating,
  });

  Order.fromJson(Map<String, dynamic> json) {
    String createdString = json['created'];
    String updateString = json['updated'];

    order_id = json['order_id'];

    created = timeConvert(json['created']);
    updated = timeConvert(json['updated']);

    pick_up_address = json['pick_up_address'];
    drop_off_address = json['drop_off_address'];
    order_type = json['order_type'];
    order_country = json['order_country'];
    order_city_name = json['order_city_name'];
    order_street_name = json['order_street_name'];
    distance_to_business = json['distance_to_business'];
    price = json['price'];
    isUrgent = json['is_urgent'] == true ? 1 : 0;
    fare = json['fare'];
    status = json['status'];

    try {
      business_phone = json['business']['phone_number'];
      business_name = json['business']['first_name'];
    } catch (e) {
      print('ORDER business ERROR: $e');
    }

    try {
      courier_phone = json['freelancer']['phone_number'];
      courier_name = json['freelancer']['first_name'];
    } catch (e) {
      print('ORDER courier ERROR: $e');
    }

    pickUpAddressLat = json['business']['lat'];
    pickUpAddressLng = json['business']['lon'];

    dropoffAddressLat = json['order_lat'];
    dropoffAddressLng = json['order_lon'];

    businessLat = json['business_lat'];
    businessLng = json['business_lon'];

    freelancerRating =
        json['freelancer_rating'] == null ? 0 : json['freelancer_rating'];
    businessRating =
        json['business_rating'] == null ? 0 : json['business_rating'];
  }

// Order.activeDuration()

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['order_id'] = this.order_id;
    data['created'] = this.created;
    data['updated'] = this.updated;
    data['pick_up_address'] = this.pick_up_address;
    data['drop_off_address'] = this.drop_off_address;
    data['order_country'] = this.order_country;
    data['order_type'] = this.order_type;
    data['order_city_name'] = this.order_city_name;
    data['order_street_name'] = this.order_street_name;
    data['distance_to_business'] = this.distance_to_business;
    data['price'] = this.price;
    data['is_urgent'] = this.isUrgent;
    data['fare'] = this.fare;
    data['status'] = this.status;
    data['lat'] = this.pickUpAddressLat;
    data['lon'] = this.pickUpAddressLng;
    data['business_lat'] = this.businessLat;
    data['business_lon'] = this.businessLng;
    data['order_lat'] = this.dropoffAddressLat;
    data['order_lon'] = this.dropoffAddressLng;

    data['freelancer_rating'] = this.freelancerRating;
    data['business_rating'] = this.businessRating;
    return data;
  }
}

class PriceParams {
  double basicPrice;
  double unitPrice;

  PriceParams({this.basicPrice, this.unitPrice});
  PriceParams.fromJson(Map<String, dynamic> json) {
    basicPrice = json['basic_price'];
    unitPrice = json['unit_price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['bais_price'] = this.basicPrice;
    data['unit_price'] = this.unitPrice;
    return data;
  }
}
