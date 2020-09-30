import 'package:google_maps_webservice/places.dart';
import 'package:pickndell/common/error_page.dart';
import 'package:pickndell/common/helper.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/location/credencials.dart';
import 'package:pickndell/location/geo_helpers.dart';
import 'package:pickndell/location/place.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/orders/order_created.dart';
import 'package:pickndell/repository/order_repository.dart';
import 'package:pickndell/ui/bottom_nav_bar.dart';
import 'package:pickndell/ui/bottom_navigation_bar.dart';
import 'package:pickndell/ui/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/global.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderSummary extends StatefulWidget {
  final String pickupAddressName;
  final String dropoffAddressName;
  final String pickupAddressId;
  final String dropoffAddressId;
  final String isUrgent;
  final String packageType;
  final User user;

  OrderSummary(
      {this.pickupAddressName,
      this.pickupAddressId,
      this.dropoffAddressId,
      this.dropoffAddressName,
      this.user,
      this.isUrgent,
      this.packageType});

  @override
  _OrderSummaryState createState() => _OrderSummaryState();
}

class _OrderSummaryState extends State<OrderSummary> {
  var updatedOrderId;
  String _country;
  String countryCode;

  void _getCountry() async {
    try {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      _country = localStorage.getString('country');
      print('COUNTRY: $_country');
    } catch (e) {
      print('*** Error *** Fail getting country code. E: $e');
      _country = 'Israel';
    }
    setState(() {
      countryCode = _country;
    });
  }

  double _orderPrice;
  @override
  void initState() {
    _getCountry();
    super.initState();
  }

  Widget build(BuildContext context) {
    final trans = ExampleLocalizations.of(context);
    return FutureBuilder(
      future: processNewOrder(
          user: widget.user,
          pickupAddressName: widget.pickupAddressName,
          pickupAddressId: widget.pickupAddressId,
          dropoffAddressName: widget.dropoffAddressName,
          dropoffAddressId: widget.dropoffAddressId,
          packageType: widget.packageType,
          isUrgent: widget.isUrgent),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          print('ORDER PRICE: ${snapshot.data}');

          if (snapshot.data != null) {
            return getOrderSummaryPage(snapshot.data);
          } else if (snapshot.data["response"] == "Update failed") {
            return orderAcceptErrorPage();
          } else {
            return orderAcceptErrorPage();
          }
        } else {
          print("No data:");
        }
        print('CREATING NEW ORDER');
        String loaderText = trans.orders_creating_new_order + "...";
        return ColoredProgressDemo(loaderText);
      },
    );
  }

  Future processNewOrder(
      {String pickupAddressName,
      String dropoffAddressName,
      String pickupAddressId,
      String dropoffAddressId,
      String isUrgent,
      String packageType,
      User user}) async {
    print(
        'NEW ORDER: pua: $pickupAddressId, doa: $dropoffAddressId, urgent: $isUrgent, package: $packageType, user: ${user.username}');
    final trans = ExampleLocalizations.of(context);

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

    // Send information to server to check the price for the order
    try {
      _orderPrice = await OrderRepository(user: user, context: context)
          .newOrderRepo(
              user: user,
              priceOrder: true,
              pickupAddress: pickupAddress,
              dropoffAddress: dropoffAddress,
              urgency: widget.isUrgent,
              packageType: widget.packageType);

      return _orderPrice;
    } catch (e) {
      print('Failed creating new order. ERROR: $e');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ErrorPage(
              user: user,
              errorMessage: trans.messages_communication_error,
            );
          },
        ),
        (Route<dynamic> route) => false, // No Back option for this page
      );
    }
  }

  Future updateOrderCreated(dynamic updateOrderId) async {
    final trans = ExampleLocalizations.of(context);

    print('UPDATINNG ORDER...');
    try {
      final orderUpdated =
          await OrderRepository().updateOrder(updateOrderId, 'STARTED');
      print('orderUpdated: $orderUpdated');
      return orderUpdated;
    } catch (e) {
      print('Failed updating order started/accepted. ERROR: $e');
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) {
            return ErrorPage(
              user: widget.user,
              errorMessage: trans.messages_communication_error,
            );
          },
        ),
        (Route<dynamic> route) => false, // No Back option for this page
      );
    }
  }

  Widget getOrderSummaryPage(dynamic order) {
    final translations = ExampleLocalizations.of(context);

    return new Scaffold(
      // backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text(translations.order_new_order_confirmation),
      ),
      body: Container(
        padding: EdgeInsets.only(
            top: TOP_MARGINE, left: LEFT_MARGINE, right: RIGHT_MARGINE),
        // height: 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Spacer(
              flex: 4,
            ),
            Text(
              translations.orders_from + ': ${widget.pickupAddressName}',
              style: whiteTitleH3,
            ),
            Spacer(
              flex: 5,
            ),
            Text(
              translations.orders_to + ": ${widget.dropoffAddressName}",
              style: whiteTitleH3,
            ),
            Spacer(
              flex: 5,
            ),
            Text(
              countryCode == 'Israel' || countryCode == 'ישראל'
                  ? '${translations.orders_order_cost}: ${roundDouble(_orderPrice * widget.user.usdIls, 2)}  ₪'
                  : '${translations.orders_order_cost}: \$ $_orderPrice',
              style: whiteTitle,
            ),
            Spacer(
              flex: 5,
            ),
            RaisedButton(
              padding: EdgeInsets.all(20),
              child: Text(
                translations.orders_confirm_order,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              color: Colors.green,
              onPressed: () {
                print('Confirmed...');
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) {
                      return OrderCreated(
                          pickupAddressName: widget.pickupAddressName,
                          dropoffAddressName: widget.dropoffAddressName,
                          pickupAddressId: widget.pickupAddressId,
                          dropoffAddressId: widget.dropoffAddressId,
                          user: widget.user,
                          packageType: widget.packageType,
                          isUrgent: widget.isUrgent);
                    },
                  ),
                  (Route<dynamic> route) =>
                      false, // No Back option for this page
                );
              },
              shape: StadiumBorder(
                side: BorderSide(
                  color: Colors.white,
                  width: 2,
                ),
              ),
            ),
            Spacer(
              flex: 5,
            ),
            RaisedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                translations.orders_cancel,
                style: TextStyle(color: Colors.white),
              ),
              shape:
                  StadiumBorder(side: BorderSide(color: Colors.red, width: 2)),
            ),
            Spacer(
              flex: 5,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        user: widget.user,
      ),
    );
  }

  Widget orderAcceptErrorPage() {
    final translations = ExampleLocalizations.of(context);

    return new Scaffold(
      backgroundColor: mainBackground,
      appBar: AppBar(
        // title: Text(translations.order_a_accepted),
        title: Text('ERROR CREATING NEW ORDER'),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 20),
        height: 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Spacer(
              flex: 4,
            ),
            Text(
              translations.order_a_not_available + "!",
              style: bigLightBlueTitle,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        user: widget.user,
      ),
    );
  }
}
