import 'package:pickndell/common/global.dart';
import 'package:pickndell/location/place.dart';
import 'package:pickndell/model/user_location.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/networking/CustomException.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'CustomException.dart';

class ApiProvider {
  final String _baseUrl = serverDomain + "/api/";
  // final String _baseUrl = "https://pickndell.com/api/";

  Future<dynamic> get(String url, User user) async {
    var responseJson;
    try {
      final response = await http.get(
        _baseUrl + url + user.userId.toString(),
        headers: <String, String>{
          "Authorization": "Token ${user.token}",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        // body: jsonEncode(userLogin.toDatabaseJson()),
      );
      responseJson = _response(response);
      print('RESPONSE ORDERS API (Truncated): $responseJson');
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

// Updating courier's availability
  Future<dynamic> putAvailability(
      String url, User user, bool availability) async {
    var postResponseJson;

    try {
      final response = await http.put(
        _baseUrl + url,
        headers: <String, String>{
          "Authorization": "Token ${user.token}",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'available': availability,
        }),
      );
      postResponseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return postResponseJson;
  }

// Updating location
  Future<dynamic> putLocation(
      String url, User user, UserLocation location) async {
    var postResponseJson;

    try {
      final response = await http.put(
        _baseUrl + url,
        headers: <String, String>{
          "Authorization": "Token ${user.token}",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'lat': location.latitude,
          'lon': location.longitude,
        }),
      );
      postResponseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return postResponseJson;
  }

// Updating Orders
  Future<dynamic> put(
      String url, String orderId, User user, String status) async {
    var postResponseJson;
    var freelancerPayload;
    var businessPayload;
    var orderUpdatePayload;
    print('>>>>>>>>>>>> 1 $user <<<<<<<<<<<');

    freelancerPayload = {
      'order_id': orderId,
      'status': status,
      'freelancer': user.userId
    };

    businessPayload = {'order_id': orderId, 'status': status};

    orderUpdatePayload =
        user.isEmployee == 1 ? freelancerPayload : businessPayload;
    try {
      final response = await http.put(
        _baseUrl + url,
        headers: <String, String>{
          "Authorization": "Token ${user.token}",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(orderUpdatePayload),
      );
      print('>>>>>>>>>>>> 2 <<<<<<<<<<<');
      postResponseJson = _response(response);
      print('>>>>>>>>>>>> 3 <<<<<<<<<<<');
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return postResponseJson;
  }

// Get current pricing parameters
  Future<dynamic> priceParams({User user, String url}) async {
    var postResponseJson;

    try {
      final response = await http.post(
        _baseUrl + url,
        headers: <String, String>{
          "Authorization": "Token ${user.token}",
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );
      postResponseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return postResponseJson;
  }

// New Order
  Future<dynamic> postNewOrder(
      {String url,
      bool priceOrder,
      OrderAddress pickupAddress,
      OrderAddress dropoffAddress,
      User user,
      String packageType,
      String urgency}) async {
    var postResponseJson;
    try {
      final response = await http.post(
        _baseUrl + url,
        headers: <String, String>{
          "Authorization": "Token ${user.token}",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'pickup_address': pickupAddress,
          'dropoff_address': dropoffAddress,
          'user_id': user.userId,
          'is_employee': user.isEmployee,
          "package_type": packageType,
          "urgency": urgency,
          "price_order": priceOrder
        }),
      );
      postResponseJson = _response(response);
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return postResponseJson;
  }

  dynamic _response(http.Response response) {
    switch (response.statusCode) {
      case 200:
        // var responseJson = json.decode(response.body.toString());
        var responseJson =
            jsonDecode(utf8.decode(response.bodyBytes)); //For HEBREW text
        // print('RESPONSE>>> ${responseJson}');
        return responseJson;
      case 400:
        throw BadRequestException(response.body.toString());
      case 401:
        print('ERROR API respose (40*): ${response.statusCode}');
        throw BadRequestException(response.body.toString());
      case 403:
        print('ERROR API respose (40*): ${response.statusCode}');
        throw UnauthorisedException(response.body.toString());
      case 500:
        print('ERROR ORDER API respose (50*): ${response.statusCode}');
        throw UnauthorisedException(response.body.toString());
      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}
