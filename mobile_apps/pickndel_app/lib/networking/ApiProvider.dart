import 'package:pickndell/model/order.dart';
import 'package:pickndell/model/user_location.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/networking/CustomException.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'CustomException.dart';

class ApiProvider {
  // final String _baseUrl = "https://88c41a0bdd84.ngrok.io/api/";
  final String _baseUrl = "https://pickndell.com/api/";

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
      print('RESPONSE: $responseJson');
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
    try {
      final response = await http.put(
        _baseUrl + url,
        headers: <String, String>{
          "Authorization": "Token ${user.token}",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(
            {'order_id': orderId, 'status': status, 'freelancer': user.userId}),
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

      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:

      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}
