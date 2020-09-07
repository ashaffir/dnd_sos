class Place {
  String name;
  String address;
  String formatAddress;
  String placeId;
  double lat;
  double lng;

  Place({this.placeId, this.name, this.address});

  static List<Place> fromNative(List results) {
    return results.map((p) => Place.fromJson(p)).toList();
  }

  factory Place.fromJson(Map<dynamic, dynamic> json) => Place(
      placeId: json['id'],
      name: json['name'],
      address: json['address'] != null ? json['address'] : "");
}

class OrderAddress {
  String name;
  String placeId;
  String orderType;
  String urgency;
  double lat;
  double lng;

  OrderAddress(
      {this.name,
      this.placeId,
      this.lat,
      this.lng,
      this.orderType,
      this.urgency});

  OrderAddress.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        placeId = json['placeId'],
        lat = json['lat'],
        lng = json['lng'];

  Map<String, dynamic> toJson() => {
        'name': name,
        'placeId': placeId,
        'lat': lat,
        'lng': lng,
      };
}
