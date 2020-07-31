import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:bloc_login/model/api_model.dart';

// final _base = "https://home-hub-app.herokuapp.com";
// final _tokenEndpoint = "/api-token-auth/";
final _base = "https://361e3bca5a39.ngrok.io";
final _tokenEndpoint = "/api/login/";

final _tokenURL = _base + _tokenEndpoint;

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
