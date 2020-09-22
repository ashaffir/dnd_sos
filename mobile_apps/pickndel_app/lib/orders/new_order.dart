import 'package:background_locator/generated/i18n.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:pickndell/common/helper.dart';
import 'package:pickndell/home/home_page_isolate.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/location/backend_service.dart';
import 'package:pickndell/location/credencials.dart';
import 'package:pickndell/location/place.dart';
import 'package:pickndell/location/search_bloc.dart';
import 'package:pickndell/model/order.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/orders/order_created.dart';
import 'package:pickndell/orders/order_summary.dart';
import 'package:pickndell/repository/order_repository.dart';
import 'package:pickndell/repository/user_repository.dart';
import 'package:pickndell/ui/bottom_nav_bar.dart';
import 'package:pickndell/ui/bottom_navigation_bar.dart';
import 'package:pickndell/ui/progress_indicator.dart';
import 'package:uuid/uuid.dart';

class NewOrder extends StatefulWidget {
  final UserRepository userRepository;
  final User user;

  NewOrder({this.userRepository, this.user});

  @override
  _NewOrderState createState() => _NewOrderState();
}

class _NewOrderState extends State<NewOrder> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _typeAheadController = TextEditingController();

  final TextEditingController _pickupAddressInput = TextEditingController();
  final TextEditingController _dropoffAddressInput = TextEditingController();
  String _dropoffAddressId;
  String _pickupAddressId;

  bool _creatingOrder;

  // var searchBloc = SearchBloc();

  var uuid = new Uuid();
  String _sessionToken;

  @override
  void initState() {
    _loadCategoriesTypes();
    _loadUrgency();
    _creatingOrder = false;
    super.initState();
  }

  @override
  void dispose() {
    // _pickupAddressInput.dispose();
    // _dropoffAddressInput.dispose();
    super.dispose();
  }

  // String _pickupAddress;
  // List<String> _addressSearchResults;

  var _businessCategories = List<DropdownMenuItem>();
  String _businessCategory;
  List<String> _businessCategoryList;

  var _urgencyOptions = List<DropdownMenuItem>();
  String _urgencyOption;
  List<String> _urgencyOptionsList;

  _loadCategoriesTypes() {
    _businessCategoryList = ['Food', 'Clothes', 'Tools', 'Documents', 'Other'];

    _businessCategoryList.forEach((element) {
      setState(() {
        _businessCategories.add(DropdownMenuItem(
          child: Text(element),
          value: element,
        ));
      });
    });
  }

  _loadUrgency() {
    _urgencyOptionsList = ['No Rush', 'Urgent'];

    _urgencyOptionsList.forEach((element) {
      setState(() {
        _urgencyOptions.add(DropdownMenuItem(
          child: Text(element),
          value: element,
        ));
      });
    });
  }

  final _controller = TextEditingController();
  String _address = '';
  String _placeId = '';

  @override
  Widget build(BuildContext context) {
    final trans = ExampleLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Create New Order'),
      ),
      body: Container(
        child: Form(
            key: _formKey,
            child: Padding(
                padding: EdgeInsets.only(left: 40.0, right: 40.0, bottom: 40.0),
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/images/pickndell-logo-white.png',
                          width: MediaQuery.of(context).size.width * 0.40,
                        ),
                        Padding(
                          padding: EdgeInsets.only(top: 20.0),
                        ),

                        //////// FROM //////
                        ///
                        Row(
                          children: [
                            Expanded(
                              child: TypeAheadFormField(
                                  textFieldConfiguration:
                                      TextFieldConfiguration(
                                          // autofocus: true,
                                          controller: _pickupAddressInput,
                                          decoration: InputDecoration(
                                              // border: OutlineInputBorder(),
                                              prefixIcon: Icon(
                                                  Icons.store_mall_directory),
                                              hintText: 'Pickup address?'),
                                          onTap: () {
                                            setState(() {
                                              _sessionToken = Uuid().v4();
                                            });
                                          }),
                                  suggestionsCallback: (pattern) async {
                                    return await BackendService.getAddresses(
                                        input: pattern,
                                        sessionToken: _sessionToken);
                                  },
                                  itemBuilder: (context, suggestion) {
                                    return ListTile(
                                      leading: Icon(Icons.location_on),
                                      // title: Text(suggestion),
                                      // subtitle: Text('\$${suggestion['price']}'),
                                      title: Text(suggestion.name),
                                    );
                                  },
                                  onSuggestionSelected: (suggestion) {
                                    // This when someone click the items
                                    _pickupAddressInput.text = suggestion.name;
                                    setState(() {
                                      _pickupAddressId = suggestion.placeId;
                                    });
                                    print('SUGGESTION IS: $suggestion');
                                  },
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please select a pickup address';
                                    }
                                    return null;
                                  }),
                            ),
                            IconButton(
                                icon: Icon(Icons.delete_outline),
                                onPressed: () {
                                  _pickupAddressInput.clear();
                                }),
                          ],
                        ),

                        Padding(padding: EdgeInsets.only(top: 20.0)),

                        Row(
                          children: [
                            Expanded(
                              child: TypeAheadFormField(
                                  textFieldConfiguration:
                                      TextFieldConfiguration(
                                          // autofocus: true,
                                          controller: _dropoffAddressInput,
                                          decoration: InputDecoration(
                                              // border: OutlineInputBorder(),
                                              prefixIcon:
                                                  Icon(Icons.arrow_forward),
                                              hintText: 'Dropoff address?'),
                                          onTap: () {
                                            setState(() {
                                              _sessionToken = Uuid().v4();
                                            });
                                          }),
                                  suggestionsCallback: (pattern) async {
                                    return await BackendService.getAddresses(
                                        input: pattern,
                                        sessionToken: _sessionToken);
                                  },
                                  itemBuilder: (context, suggestion) {
                                    return ListTile(
                                      leading: Icon(Icons.location_on),
                                      // title: Text(suggestion),
                                      // subtitle: Text('\$${suggestion['price']}'),
                                      title: Text(suggestion.name),
                                    );
                                  },
                                  onSuggestionSelected: (suggestion) {
                                    // This when someone click the items
                                    _dropoffAddressInput.text = suggestion.name;
                                    setState(() {
                                      _dropoffAddressId = suggestion.placeId;
                                    });
                                    print('DROPOFF SUGGESTION IS: $suggestion');
                                  },
                                  validator: (value) {
                                    if (value.isEmpty) {
                                      return 'Please select a dropoff adderss';
                                    }
                                    return null;
                                  }),
                            ),
                            IconButton(
                                icon: Icon(Icons.delete_outline),
                                onPressed: () {
                                  _dropoffAddressInput.clear();
                                  print('Clear Text');
                                }),
                          ],
                        ),

                        Padding(padding: EdgeInsets.only(top: 20.0)),

                        //////////// Package Type //////////////
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                              labelText: 'Package Type' + ":",
                              prefixIcon: Icon(Icons.business_center)),

                          // Need to change below for relevant drop downs
                          value: _businessCategory,
                          items: _businessCategories,
                          validator: (value) {
                            if (value != null) {
                              return null;
                            } else {
                              return 'Please choose the package type';
                            }
                          },
                          onChanged: (value) {
                            setState(() {
                              print('dropdown: $value');
                              _businessCategory = value;
                            });
                          },
                        ),
                        Padding(padding: EdgeInsets.only(top: 20)),

                        //////////// Urgency //////////////
                        DropdownButtonFormField(
                          decoration: InputDecoration(
                              labelText: 'Urgency' + ":",
                              prefixIcon: Icon(Icons.access_alarms)),

                          // Need to change below for relevant drop downs
                          value: _urgencyOption,
                          items: _urgencyOptions,
                          // validator: (value) {
                          //   if (dropdownMenue(value) == null) {
                          //     return null;
                          //   } else {
                          //     return 'Please select the business category';
                          //   }
                          // },
                          onChanged: (value) {
                            setState(() {
                              print('dropdown: $value');
                              _urgencyOption = value;
                            });
                          },
                        ),
                        Padding(padding: EdgeInsets.only(top: 20)),

                        RaisedButton(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Order Delivery',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          color: Colors.green,
                          onPressed: () {
                            if (!_formKey.currentState.validate()) {
                              return;
                            } else {
                              print('Ordered a new Delivery....');
                              // priceConfirmation(
                              //     context: context,
                              //     user: widget.user,
                              //     pickupAddressId: _pickupAddressId,
                              //     dropoffAddressId: _dropoffAddressId,
                              //     packageType: _businessCategory,
                              //     isUrgent: _urgencyOption);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderSummary(
                                      pickupAddressName:
                                          _pickupAddressInput.text,
                                      dropoffAddressName:
                                          _dropoffAddressInput.text,
                                      pickupAddressId: _pickupAddressId,
                                      dropoffAddressId: _dropoffAddressId,
                                      user: widget.user,
                                      packageType: _businessCategory,
                                      isUrgent: _urgencyOption),
                                ),
                                // No Back option for this page
                              );
                            }
                          },
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: Colors.white,
                              width: 2,
                            ),
                          ),
                        ),
                      ]),
                ))),
      ),
      bottomNavigationBar: BottomNavigation(
        user: widget.user,
      ),
    );
  }

  Future priceConfirmation(
      {context,
      User user,
      String pickupAddressId,
      String dropoffAddressId,
      String isUrgent,
      String packageType}) async {
    final geocoding = new GoogleMapsPlaces(apiKey: PLACES_API_KEY);
    // final places = new GoogleMapsPlaces(apiKey: PLACES_API_KEY);

    PlacesDetailsResponse _pickupCoodrs =
        await geocoding.getDetailsByPlaceId("$pickupAddressId");
    double puLatitude = _pickupCoodrs.result.geometry.location.lat;
    double puLongitude = _pickupCoodrs.result.geometry.location.lng;
    print('Pickup COORDS: $puLatitude $puLongitude');

    OrderAddress pickupAddress = OrderAddress();
    pickupAddress.placeId = pickupAddressId;
    pickupAddress.lat = puLatitude;
    pickupAddress.lng = puLongitude;

    PlacesDetailsResponse _dropoffCoodrs =
        await geocoding.getDetailsByPlaceId("$dropoffAddressId");
    double doLatitude = _dropoffCoodrs.result.geometry.location.lat;
    double doLongitude = _dropoffCoodrs.result.geometry.location.lng;
    print('Dropoff COORDS: $doLatitude $doLongitude');

    OrderAddress dropoffAddress = OrderAddress();
    dropoffAddress.placeId = dropoffAddressId;
    dropoffAddress.lat = doLatitude;
    dropoffAddress.lng = doLongitude;

    PriceParams priceParams =
        await OrderRepository().getPriceParamsRepo(user: user);
  }

  Future processNewOrder(
      {String pickupAddressName,
      String dropoffAddressName,
      String pickupAddressId,
      String dropoffAddressId,
      String isUrgent,
      String packageType,
      User user}) async {
    setState(() {
      _creatingOrder = true;
    });
    print(
        'NEW ORDER: pua: $pickupAddressId, doa: $dropoffAddressId, urgent: $isUrgent, package: $packageType, user: ${user.username}');
    final geocoding = new GoogleMapsPlaces(apiKey: PLACES_API_KEY);
    // final places = new GoogleMapsPlaces(apiKey: PLACES_API_KEY);

    PlacesDetailsResponse _pickupCoodrs =
        await geocoding.getDetailsByPlaceId("$pickupAddressId");
    double puLatitude = _pickupCoodrs.result.geometry.location.lat;
    double puLongitude = _pickupCoodrs.result.geometry.location.lng;
    print('Pickup COORDS: $puLatitude $puLongitude');

    OrderAddress pickupAddress = OrderAddress();
    pickupAddress.name = pickupAddressName;
    pickupAddress.placeId = pickupAddressId;
    pickupAddress.lat = puLatitude;
    pickupAddress.lng = puLongitude;

    PlacesDetailsResponse _dropoffCoodrs =
        await geocoding.getDetailsByPlaceId("$dropoffAddressId");
    double doLatitude = _dropoffCoodrs.result.geometry.location.lat;
    double doLongitude = _dropoffCoodrs.result.geometry.location.lng;
    print('Dropoff COORDS: $doLatitude $doLongitude');

    OrderAddress dropoffAddress = OrderAddress();
    dropoffAddress.name = dropoffAddressName;
    dropoffAddress.placeId = dropoffAddressId;
    dropoffAddress.lat = doLatitude;
    dropoffAddress.lng = doLongitude;

    // NEW ORDER API

    await OrderRepository().newOrderRepo(
        user: user,
        pickupAddress: pickupAddress,
        dropoffAddress: dropoffAddress,
        urgency: _urgencyOption,
        packageType: _businessCategory);

    setState(() {
      _creatingOrder = false;
    });
  }
}
