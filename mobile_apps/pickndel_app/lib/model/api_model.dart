class UserLogin {
  String username;
  String password;

  UserLogin({this.username, this.password});

  Map<String, dynamic> toDatabaseJson() =>
      {"username": this.username, "password": this.password};
}

class Token {
  String token;
  String fcmToken;
  int userId;
  int isEmployee;
  String name;
  String phone;
  String businessName;
  String businessCategory;
  int isApproved;
  int numDailyOrders;
  int numOrdersInProgress;
  double dailyCost;
  String vehicle;
  String idDoc;
  int profilePending;
  double rating;
  double dailyProfit;
  int activeOrders;
  String creditCardToken;

  Token(
      {this.token,
      this.fcmToken,
      this.isEmployee,
      this.userId,
      this.name,
      this.phone,
      this.businessName,
      this.businessCategory,
      this.isApproved,
      this.numDailyOrders,
      this.numOrdersInProgress,
      this.dailyCost,
      this.vehicle,
      this.idDoc,
      this.profilePending,
      this.rating,
      this.dailyProfit,
      this.creditCardToken,
      this.activeOrders});

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
        token: json['token'],
        fcmToken: json['fcm_token'],
        isEmployee: json['is_employee'],
        userId: json['user'],
        name: json['name'],
        phone: json['phone'],
        businessName: json['business_name'],
        businessCategory: json['business_category'],
        creditCardToken: json['credit_card_token'],
        isApproved: json['is_approved'],
        numDailyOrders: json['num_daily_orders'],
        numOrdersInProgress: json['num_orders_in_progress'],
        dailyCost: json['daily_cost'],
        vehicle: json['vehicle'],
        idDoc: json['id_doc'],
        profilePending: json['profile_pending'],
        rating: json['freelancer_total_rating'],
        dailyProfit: json['daily_profit'],
        activeOrders: json['num_active_orders_total']);
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
