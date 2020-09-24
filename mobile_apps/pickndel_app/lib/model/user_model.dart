class User {
  int id;
  String username;
  String token;
  int userId;
  int isEmployee;
  int isApproved;

  // Business
  String businessName;
  String businessCategory;
  int numDailyOrders;
  int numOrdersInProgress;
  double dailyCost;
  String creditCardToken;

  // Courier
  String name;
  String phone;
  String vehicle;
  String idDoc;
  int profilePending;
  double rating;
  double dailyProfit;
  double balance;
  double usdIls;
  double usdEur;
  int activeOrders;

  User(
      {this.id,
      this.username,
      this.token,
      this.isEmployee,
      this.userId,
      this.name,
      this.phone,
      this.businessName,
      this.businessCategory,
      this.creditCardToken,
      this.isApproved,
      this.numDailyOrders,
      this.numOrdersInProgress,
      this.dailyCost,
      this.vehicle,
      this.idDoc,
      this.profilePending,
      this.rating,
      this.dailyProfit,
      this.balance,
      this.usdIls,
      this.usdEur,
      this.activeOrders});

  factory User.fromDatabaseJson(Map<String, dynamic> data) => User(
      id: data['id'],
      username: data['username'],
      token: data['token'],
      isEmployee: data['isEmployee'],
      userId: data['userId'],
      name: data['name'],
      phone: data['phone'],
      businessName: data['businessName'],
      businessCategory: data['businessCategory'],
      creditCardToken: data['creditCardToken'],
      isApproved: data['isApproved'],
      numDailyOrders: data['numDailyOrders'],
      numOrdersInProgress: data['numOrdersInProgress'],
      dailyCost: data['dailyCost'],
      vehicle: data['vehicle'],
      idDoc: data['idDoc'],
      profilePending: data['profilePending'],
      rating: data['rating'],
      dailyProfit: data['dailyProfit'],
      balance: data['balance'],
      usdIls: data['usdIls'],
      usdEur: data['usdEur'],
      activeOrders: data['activeOrders']);

  Map<String, dynamic> toDatabaseJson() => {
        "id": this.id,
        "username": this.username,
        "token": this.token,
        "isEmployee": this.isEmployee,
        "userId": this.userId,
        "name": this.name,
        "phone": this.phone,
        "businessName": this.businessName,
        "businessCategory": this.businessCategory,
        "creditCardToken": this.creditCardToken,
        "isApproved": this.isApproved,
        "numDailyOrders": this.numDailyOrders,
        "numOrdersInProgress": this.numOrdersInProgress,
        "dailyCost": this.dailyCost,
        "vehicle": this.vehicle,
        "idDoc": this.idDoc,
        "profilePending": this.profilePending,
        "rating": this.rating,
        "dailyProfit": this.dailyProfit,
        "balance": this.balance,
        "usdIls": this.usdIls,
        "usdEur": this.usdEur,
        "activeOrders": this.activeOrders
      };
}
