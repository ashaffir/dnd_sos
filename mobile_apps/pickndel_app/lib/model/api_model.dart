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
  String businessName;
  String businessCategory;
  int isApproved;
  int numDailyOrders;
  int numOrdersInProgress;
  double dailyCost;
  String vehicle;
  double rating;
  double dailyProfit;
  int activeOrders;

  Token(
      {this.token,
      this.isEmployee,
      this.userId,
      this.businessName,
      this.businessCategory,
      this.isApproved,
      this.numDailyOrders,
      this.numOrdersInProgress,
      this.dailyCost,
      this.vehicle,
      this.rating,
      this.dailyProfit,
      this.activeOrders});

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
        token: json['token'],
        isEmployee: json['is_employee'],
        userId: json['user'],
        businessName: json['business_name'],
        businessCategory: json['business_category'],
        isApproved: json['is_approved'],
        numDailyOrders: json['num_daily_orders'],
        numOrdersInProgress: json['num_orders_in_progress'],
        dailyCost: json['daily_cost'],
        vehicle: json['vehicle'],
        rating: json['rating'],
        dailyProfit: json['daily_profit'],
        activeOrders: json['active_orders']);
  }
}

class UserRegistration {
  String email;
  String password1;
  String password2;

  UserRegistration({this.email, this.password1, this.password2});

  Map<String, dynamic> toDataBaseJson() => {
        "username": this.email,
        "email": this.email,
        "password1": this.password1,
        "password2": this.password2
      };
}
