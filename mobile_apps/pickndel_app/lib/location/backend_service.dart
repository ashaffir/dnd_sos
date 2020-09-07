import 'dart:convert';
import 'dart:math';
import 'package:google_maps_webservice/places.dart';
import 'package:http/http.dart' as http;
import 'package:pickndell/location/credencials.dart';
import 'package:pickndell/location/place.dart';
import "package:google_maps_webservice/geocoding.dart";

// REFERENCE: https://www.youtube.com/watch?v=uJliM9Mh1nE&ab_channel=IzwebTechnologies

const googlePlaceApiKey = PLACES_API_KEY;

class BackendService {
  static Future<List> getSuggestions(
      {String input, String sessionToken}) async {
    await Future.delayed(Duration(seconds: 1));

    return List.generate(3, (index) {
      return {'name': input + index.toString(), 'price': Random().nextInt(100)};
    });
  }

  static Future<List> getAddresses({String input, String sessionToken}) async {
    String _baseGooglePlacesUrl =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json";
    List<Place> _places = List<Place>();

    var predictions;
    // final geocoding = new GoogleMapsPlaces(apiKey: PLACES_API_KEY);

    String type = 'address';
    String requestGoogle =
        "$_baseGooglePlacesUrl?input=$input&key=$PLACES_API_KEY&type=$type&sessiontoken=$sessionToken";

    if (input.isNotEmpty) {
      http.Response response = await http.get(requestGoogle);
      if (response.statusCode == 200) {
        var responseJson = jsonDecode(utf8.decode(response.bodyBytes));
        predictions = responseJson['predictions'];
        List<String> _displayResults = [];
        for (var i = 0; i < predictions.length; i++) {
          Place _place = Place();
          String _name = predictions[i]['description'];
          String _placeId = predictions[i]['place_id'];
          _place.name = _name;
          _place.placeId = _placeId;
          print('>>>>>>> $_name. ID: $_placeId');
          // _displayResults.add(Place(name: name));
          _displayResults.add(_name);
          _places.add(_place);
          print('PREDICTION: $predictions');
          print('RESULT: $_displayResults');
        }
        print('API URL: $requestGoogle');
        print('PLACES: $_places');
        // PlacesDetailsResponse _coordsResponse =
        //     await geocoding.getDetailsByPlaceId("${_places[0].placeId}");
        // double latitude = _coordsResponse.result.geometry.location.lat;
        // double longitude = _coordsResponse.result.geometry.location.lng;
        // print('Location COORDS: $latitude $longitude');
        return _places;
      }
    }
  }
}
