import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:bloc_login/networking/CustomException.dart';
import 'package:bloc_login/networking/Response.dart';
import 'package:http/http.dart' as http;
import 'package:bloc_login/model/api_model.dart';

// final _base = "https://home-hub-app.herokuapp.com";
// final _tokenEndpoint = "/api-token-auth/";
final _base = "https://361e3bca5a39.ngrok.io";
final _tokenEndpoint = "/api/login/";
final _registrationEndpoint = "/api/register/";

final _tokenURL = _base + _tokenEndpoint;
final _registrationURL = _base + _registrationEndpoint;

Future<Token> getToken(UserLogin userLogin) async {
  final http.Response response = await http.post(
    _tokenURL,
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(userLogin.toDatabaseJson()),
  );
  if (response.statusCode == 200) {
    print('RESPONSE: ${response.body});');
    return Token.fromJson(json.decode(response.body));
  } else {
    print(json.decode(response.body).toString());
    throw Exception(json.decode(response.body));
  }
}

Future<dynamic> createUser(
    {String email, String password1, String password2, String userType}) async {
  var postResponseJson;
  bool is_employee;
  bool is_employer;
  if (userType == 'Business') {
    is_employer = true;
    is_employee = false;
  } else if (userType == 'Carrier') {
    is_employee = true;
    is_employer = false;
  } else {
    is_employee = null;
    is_employer = null;
  }
  try {
    final response = await http.post(
      _registrationURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        "email": email,
        "username": email,
        "password1": password1,
        "password2": password2,
        "is_employee": is_employee,
        "is_employer": is_employer,
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
      // print('RESPONSE>>> $responseJson');
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
// Future<int> createUser(UserRegistration userRegistration) async {
// Future<int> createUser1(
//     {String email, String password1, String password2}) async {
//   final http.Response response =
//       await http.post(_registrationURL, headers: <String, String>{
//     'Content-Type': 'application/json; charset=UTF-8',
//   },
//           // body: jsonEncode(userRegistration.toDatabaseJson()),
//           body: {
//   "email": email,
// "username": email,
// "password1": password1,
// "password2": password2
//       });
//   if (response.statusCode == 200) {
//     print('RESPONSE: ${response.body});');
//     return response.statusCode;
//   } else {
//     print(json.decode(response.body).toString());
//     throw Exception(json.decode(response.body));
//   }
// }
