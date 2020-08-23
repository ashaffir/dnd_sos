import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/networking/CustomException.dart';
import 'package:http/http.dart' as http;
import 'package:pickndell/model/api_model.dart';

// final _base = "https://home-hub-app.herokuapp.com";
// final _tokenEndpoint = "/api-token-auth/";

// final _base = "https://88c41a0bdd84.ngrok.io";
final _base = "https://pickndell.com";
final _tokenEndpoint = "/api/login/";
final _registrationEndpoint = "/api/register/";
final _fcmRegistratioEndpoint = "/api/devices/";

final _tokenURL = _base + _tokenEndpoint;
final _registrationURL = _base + _registrationEndpoint;
final _fcmRegistratioURL = _base + _fcmRegistratioEndpoint;

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
//   final String _url = 'https://8c1d164fa909.ngrok.io/api/';

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
