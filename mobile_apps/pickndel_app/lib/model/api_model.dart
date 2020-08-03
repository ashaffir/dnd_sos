class UserLogin {
  String username;
  String password;

  UserLogin({this.username, this.password});

  Map<String, dynamic> toDatabaseJson() =>
      {"username": this.username, "password": this.password};
}

class Token {
  String token;
  int userId;
  int isEmployee;

  Token({this.token, this.isEmployee, this.userId});

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      token: json['token'],
      isEmployee: json['is_employee'],
      userId: json['user'],
    );
  }
}
