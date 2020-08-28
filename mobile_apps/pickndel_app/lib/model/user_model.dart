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

  // Courier
  String name;
  String phone;
  String vehicle;
  double rating;
  double dailyProfit;
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
      this.isApproved,
      this.numDailyOrders,
      this.numOrdersInProgress,
      this.dailyCost,
      this.vehicle,
      this.rating,
      this.dailyProfit,
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
      isApproved: data['isApproved'],
      numDailyOrders: data['numDailyOrders'],
      numOrdersInProgress: data['numOrdersInProgress'],
      dailyCost: data['dailyCost'],
      vehicle: data['vehicle'],
      rating: data['rating'],
      dailyProfit: data['dailyProfit'],
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
        "isApproved": this.isApproved,
        "numDailyOrders": this.numDailyOrders,
        "numOrdersInProgress": this.numOrdersInProgress,
        "dailyCost": this.dailyCost,
        "vehicle": this.vehicle,
        "rating": this.rating,
        "dailyProfit": this.dailyProfit,
        "activeOrders": this.activeOrders
      };
}
