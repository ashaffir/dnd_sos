import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/networking/CustomException.dart';
import 'package:http/http.dart' as http;
import 'package:pickndell/model/api_model.dart';

// final _base = "https://home-hub-app.herokuapp.com";
// final _tokenEndpoint = "/api-token-auth/";

final _base = "https://59f721d4650b.ngrok.io";
// final _base = "https://pickndell.com";
final _tokenEndpoint = "/api/login/";
final _registrationEndpoint = "/api/register/";
final _profileEndpoint = "/api/user-profile/";
final _fcmRegistratioEndpoint = "/api/devices/";

final _tokenURL = _base + _tokenEndpoint;
final _registrationURL = _base + _registrationEndpoint;
final _fcmRegistratioURL = _base + _fcmRegistratioEndpoint;
final _profileURL = _base + _profileEndpoint;

/////////// Login ///////////
Future<Token> serverAuthentication(UserLogin userLogin) async {
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

/////////// FCM token registration ///////////
Future<dynamic> fcmTokenRegistration(
    {String fcmToken, String osType, String userToken}) async {
  var postResponseJson;
  var deviceName = userToken.substring(userToken.length - 5);
  try {
    final http.Response response = await http.post(
      _fcmRegistratioURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $userToken',
      },
      body: jsonEncode({
        "registration_id": fcmToken,
        "type": osType,
        "device_id": userToken,
        "name": deviceName
      }),
    );
    postResponseJson = _response(response);
  } on SocketException {
    throw FetchDataException('No Internet connection');
  }
  return postResponseJson;
}

// class CallApi {
//   final String _url = 'https://59f721d4650b.ngrok.io/api/';

//   postData(data, apiUrl) async {
//     var fullUrl = _url + apiUrl;
//     final http.Response response = await http.post(fullUrl,
//         body: jsonEncode(data), headers: _setHeaders());
//     print('RESPONSE: ${response.body});');
//     // return Token.fromJson(json.decode(response.body));
//     return response;
//   }

//   getData(apiUrl) async {
//     var fullUrl = _url + apiUrl + await _getToken();
//     return await http.get(fullUrl, headers: _setHeaders());
//   }

//   _setHeaders() => {
//         'Content-type': 'application/json',
//         'Accept': 'application/json',
//       };

//   _getToken() async {
//     SharedPreferences localStorage = await SharedPreferences.getInstance();
//     var token = localStorage.getString('token');
//     return '?token=$token';
//   }
// }

///////////// New user registration /////////////
///
Future<dynamic> createUser(
    {String email, String password1, String password2, String userType}) async {
  var postResponseJson;
  bool is_employee;
  bool is_employer;
  if (userType == 'Sender') {
    is_employer = true;
    is_employee = false;
  } else if (userType == 'Courier') {
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

///////////// Check User profile info /////////////
///
Future<dynamic> getProfile({User user}) async {
  var postResponseJson;
  String userToken = user.token;
  try {
    final http.Response response = await http.post(
      _profileURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $userToken',
      },
      // email field is special due to django requirements
      body:
          jsonEncode({"user_id": user.userId, "is_employee": user.isEmployee}),
    );
    postResponseJson = _response(response);
  } on SocketException {
    throw FetchDataException('No Internet connection');
  }
  return postResponseJson;
}

/////////// Update User Profile ///////////
Future<dynamic> updateUser({
  User user,
  String updateField,
  String value,
}) async {
  var postResponseJson;

  String userToken = user.token;
  print('USER TOKEN: $userToken');
  print('UPDATE FIELD $updateField');
  print('UPDATE VALUE $value');

  if (updateField == 'name' && user.isEmployee == 0) {
    updateField = 'business_name';
  } else if (updateField == 'business category') {
    updateField = 'business_category';
  }

  try {
    final http.Response response = await http.put(
      _profileURL,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Token $userToken',
      },
      // email field is special due to django requirements
      body: updateField == 'email'
          ? jsonEncode({
              "email": value,
              "user_id": user.userId,
              "is_employee": user.isEmployee
            })
          : jsonEncode({
              "$updateField": value,
              "email": user.username,
              "user_id": user.userId,
              "is_employee": user.isEmployee
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
    case 201:
      // var responseJson = json.decode(response.body.toString());
      var responseJson =
          jsonDecode(utf8.decode(response.bodyBytes)); //For HEBREW text
      // print('RESPONSE>>> $responseJson');
      return responseJson;
    case 400:
      print('ERROR API respose (40*): ${response.statusCode}');
      throw BadRequestException(response.body.toString());
    case 401:
      print('ERROR API respose (40*): ${response.statusCode}');
      throw BadRequestException(response.body.toString());
    case 403:
      print('ERROR API respose (40*): ${response.statusCode}');
      throw UnauthorisedException(response.body.toString());
    case 500:
      print('ERROR API respose (50*): ${response.statusCode}');
      throw UnauthorisedException(response.body.toString());
    default:
      throw FetchDataException(
          'Error occured while Communication with Server with StatusCode : ${response.statusCode}');
  }
}
