import 'package:bloc_login/model/order.dart';
import 'package:bloc_login/model/user_location.dart';
import 'package:bloc_login/model/user_model.dart';
import 'package:bloc_login/networking/CustomException.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'CustomException.dart';

class ApiProvider {
  final String _baseUrl = "https://361e3bca5a39.ngrok.io/api/";

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
    } on SocketException {
      throw FetchDataException('No Internet connection');
    }
    return responseJson;
  }

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

  Future<dynamic> put(String url, Order order, User user, String status) async {
    var postResponseJson;
    try {
      final response = await http.put(
        _baseUrl + url,
        headers: <String, String>{
          "Authorization": "Token ${user.token}",
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'order_id': order.order_id,
          'status': status,
          'freelancer': user.userId
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

      case 403:
        throw UnauthorisedException(response.body.toString());
      case 500:

      default:
        throw FetchDataException(
            'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
    }
  }
}
