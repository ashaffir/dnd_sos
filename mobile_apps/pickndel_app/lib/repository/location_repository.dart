import 'package:pickndell/dao/user_dao.dart';
import 'package:pickndell/model/user_location.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/networking/ApiProvider.dart';
// import 'package:geolocator/geolocator.dart';

class LocationRepository {
  ApiProvider _apiProvider = ApiProvider();

  Future updateUserLocation(UserLocation position) async {
    User user;
    try {
      user = await UserDao().getUser(0);
      String _url = "user-location/?user=${user.userId}";
      var response = await _apiProvider.putLocation(_url, user, position);
      print('>>> Location update response: $response');
      return response;
    } catch (e) {
      print('REPO ERROR updating location: $e');
      return e;
    }
  }

  Future updateAvailability(bool available) async {
    User user;
    try {
      user = await UserDao().getUser(0);
      String _url = "user-availability/?user=${user.userId}";
      var response = await _apiProvider.putAvailability(_url, user, available);
      print('>>> Availability update response: $response');
      return response;
    } catch (e) {
      print('REPO ERROR updating availability: $e');
      return e;
    }
  }
}
