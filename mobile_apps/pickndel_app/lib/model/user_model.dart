class User {
  int id;
  String username;
  String token;
  int userId;
  int isEmployee;

  User({this.id, this.username, this.token, this.isEmployee, this.userId});

  factory User.fromDatabaseJson(Map<String, dynamic> data) => User(
        id: data['id'],
        username: data['username'],
        token: data['token'],
        isEmployee: data['isEmployee'],
        userId: data['userId'],
      );

  Map<String, dynamic> toDatabaseJson() => {
        "id": this.id,
        "username": this.username,
        "token": this.token,
        "isEmployee": this.isEmployee,
        "userId": this.userId,
      };
}
