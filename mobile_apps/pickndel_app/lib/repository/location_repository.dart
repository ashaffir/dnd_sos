import 'package:bloc_login/dao/user_dao.dart';
import 'package:bloc_login/model/user_location.dart';
import 'package:bloc_login/model/user_model.dart';
import 'package:bloc_login/networking/ApiProvider.dart';
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
}
