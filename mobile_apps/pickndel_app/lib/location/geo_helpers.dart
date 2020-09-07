import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String> getCountryName() async {
  Position position = await Geolocator()
      .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  final coordinates = new Coordinates(position.latitude, position.longitude);
  var addresses =
      await Geocoder.local.findAddressesFromCoordinates(coordinates);
  var first = addresses.first;
  SharedPreferences localStorage = await SharedPreferences.getInstance();
  try {
    await localStorage.setString('userCountry', first.countryCode);
  } catch (e) {
    print('ERROR: Country check page');
  }
  print('COUNTRY: ${first.countryCode}');
  return first.countryName; // this will return country name
}
