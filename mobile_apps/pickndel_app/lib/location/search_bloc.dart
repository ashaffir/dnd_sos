import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:pickndell/location/place.dart';

// import './place_plugin.dart';
import './credencials.dart';
import 'package:http/http.dart' as http;

const googlePlaceApiKey = PLACES_API_KEY;

class SearchBloc {
  var _searchController = StreamController();
  List<Place> _places = List<Place>();

  Stream get searchStream => _searchController.stream;

  void getLocationResults({String input, String sessionToken}) async {
    String _baseGooglePlacesUrl =
        "https://maps.googleapis.com/maps/api/place/autocomplete/json";

    String type = 'address';
    String requestGoogle =
        "$_baseGooglePlacesUrl?input=$input&key=$PLACES_API_KEY&type=$type&sessiontoken=$sessionToken";

    if (input.isNotEmpty) {
      print('>>>> GOOGLE API: $requestGoogle');
      _searchController.sink.add("searching_");

      http.Response response = await http.get(requestGoogle);
      if (response.statusCode == 200) {
        var responseJson = jsonDecode(utf8.decode(response.bodyBytes));
        final predictions = responseJson['predictions'];
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
        }
        _searchController.sink.add(_displayResults);
        // print(predictions);
      } else {
        print('Failed getting the locations!');
      }
      print('PLACES: ${_places[0].name}');
      // print(_displayResults[0].name);

    }
  }

  void dispose() {
    _searchController.close();
  }
}

/////////////////////////////////////////////////////
// For storing our result
//// https://medium.com/comerge/location-search-autocomplete-in-flutter-84f155d44721
class Suggestion {
  final String placeId;
  final String description;

  Suggestion(this.placeId, this.description);

  @override
  String toString() {
    return 'Suggestion(description: $description, placeId: $placeId)';
  }
}

class PlaceApiProvider {
  final client = Client();

  PlaceApiProvider(this.sessionToken);

  final sessionToken;

  static final String androidKey = PLACES_API_KEY;
  static final String iosKey = PLACES_API_KEY;
  final apiKey = Platform.isAndroid ? androidKey : iosKey;

  Future<List<Suggestion>> fetchSuggestions(String input, String lang) async {
    final request =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$input&types=address&language=$lang&components=country:ch&key=$apiKey&sessiontoken=$sessionToken';
    final response = await client.get(request);

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      if (result['status'] == 'OK') {
        // compose suggestions in a list
        return result['predictions']
            .map<Suggestion>((p) => Suggestion(p['place_id'], p['description']))
            .toList();
      }
      if (result['status'] == 'ZERO_RESULTS') {
        return [];
      }
      throw Exception(result['error_message']);
    } else {
      throw Exception('Failed to fetch suggestion');
    }
  }

  Future<Place> getPlaceDetailFromId(String placeId) async {
    // if you want to get the details of the selected place by place_id
  }
}

class AddressSearch extends SearchDelegate<Suggestion> {
  final sessionToken;
  AddressSearch(this.sessionToken);
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        tooltip: 'Clear',
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Back',
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder(
      // We will put the api call here
      future: null,
      builder: (context, snapshot) => query == ''
          ? Container(
              padding: EdgeInsets.all(16.0),
              child: Text('Enter your address'),
            )
          : snapshot.hasData
              ? ListView.builder(
                  itemBuilder: (context, index) => ListTile(
                    // we will display the data returned from our future here
                    title: Text(snapshot.data[index]),
                    onTap: () {
                      close(context, snapshot.data[index]);
                    },
                  ),
                  itemCount: snapshot.data.length,
                )
              : Container(child: Text('Loading...')),
    );
  }
}
