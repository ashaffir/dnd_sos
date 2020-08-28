import 'package:pickndell/database/user_database.dart';
import 'package:pickndell/model/user_model.dart';

import '../model/user_model.dart';

class UserDao {
  final dbProvider = DatabaseProvider.dbProvider;

  Future<int> createUser(User user) async {
    final db = await dbProvider.database;

    print('>>>>>>> Writing user to DB.');

    var result = db.insert(userTable, user.toDatabaseJson());
    print('RESULT: ${user.username}');
    print('RESULT ID: ${user.userId}');
    print('RESULT isEmployee: ${user.isEmployee}');
    print('RESULT businessName: ${user.businessName}');
    print('RESULT vehicle: ${user.vehicle}');
    print('RESULT phone: ${user.phone}');
    return result;
  }

  Future<int> deleteUser(int id) async {
    final db = await dbProvider.database;
    var result = await db.delete(userTable, where: "id = ?", whereArgs: [id]);
    return result;
  }

  Future<User> getUser(int id) async {
    final db = await dbProvider.database;
    try {
      final data = await db.query(userTable, where: 'id = ?', whereArgs: [id]);
      User user = User.fromDatabaseJson(data[id]);
      // print('User FROM DB: ${user.isEmployee}');
      // String username = user.username;
      return user;
    } catch (error) {
      print('ERROR Getting User (user_dao.dart): $error');
      return null;
    }
  }

  Future<bool> checkUser(int id) async {
    final db = await dbProvider.database;
    try {
      List<Map> users =
          await db.query(userTable, where: 'id = ?', whereArgs: [id]);
      if (users.length > 0) {
        return true;
      } else {
        return false;
      }
    } catch (error) {
      return false;
    }
  }
}
