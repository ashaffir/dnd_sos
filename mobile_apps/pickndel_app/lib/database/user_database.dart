import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

final userTable = 'userTable';

class DatabaseProvider {
  static final DatabaseProvider dbProvider = DatabaseProvider();

  Database _database;

  Future<Database> get database async {
    print('Acecessing User DB >> $_database ...');
    if (_database != null) {
      return _database;
    }
    _database = await createDatabase();
    print('Creating a new DB...');
    return _database;
  }

  createDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "User.db");
    print('Creating New DB at PATH: $path');

    var database = await openDatabase(
      path,
      version: 24,
      onCreate: initDB,
      onUpgrade: onUpgrade,
    );
    return database;
  }

  void onUpgrade(
    Database database,
    int oldVersion,
    int newVersion,
  ) {
    if (newVersion > oldVersion) {}
  }

  void initDB(Database database, int version) async {
    await database.execute("CREATE TABLE $userTable ("
        "id INTEGER PRIMARY KEY, "
        "userId INTEGER, "
        "isEmployee INTEGER, "
        "username TEXT, "
        "name TEXT, "
        "phone TEXT, "
        "businessName TEXT, "
        "businessCategory TEXT, "
        "creditCardToken TEXT, "
        "vehicle TEXT, "
        "profilePending INTEGER, "
        "idDoc TEXT, "
        "isApproved INTEGER, "
        "numDailyOrders INTEGER, "
        "numOrdersInProgress INTEGER, "
        "activeOrders INTEGER, "
        "dailyCost REAL, "
        "rating REAL, "
        "dailyProfit REAL, "
        "balance REAL, "
        "usdIls REAL, "
        "usdEur REAL, "
        "token TEXT "
        ")");
  }
}
