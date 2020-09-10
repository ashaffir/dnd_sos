import 'package:google_maps_webservice/places.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/location/credencials.dart';
import 'package:pickndell/location/place.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/orders/order_created.dart';
import 'package:pickndell/repository/order_repository.dart';
import 'package:pickndell/ui/bottom_nav_bar.dart';
import 'package:pickndell/ui/progress_indicator.dart';
import 'package:flutter/material.dart';
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
  double _orderPrice;
  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    final translations = ExampleLocalizations.of(context);
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
        String loaderText = 'Creating a new order' + "...";
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
    _orderPrice = await OrderRepository().newOrderRepo(
        user: user,
        priceOrder: true,
        pickupAddress: pickupAddress,
        dropoffAddress: dropoffAddress,
        urgency: widget.isUrgent,
        packageType: widget.packageType);

    return _orderPrice;
  }

  Future updateOrderCreated(dynamic updateOrderId) async {
    print('UPDATINNG ORDER...');
    final orderUpdated =
        await OrderRepository().updateOrder(updateOrderId, 'STARTED');
    print('orderUpdated: $orderUpdated');
    return orderUpdated;
  }

  Widget getOrderSummaryPage(dynamic order) {
    final translations = ExampleLocalizations.of(context);

    return new Scaffold(
      backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text(translations.order_a_accepted),
      ),
      body: Container(
        padding: EdgeInsets.all(30),
        // height: 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Spacer(
              flex: 4,
            ),
            Text(
              translations.orders_from + ': ${widget.pickupAddressName}',
              style: whiteTitle,
            ),
            Spacer(
              flex: 5,
            ),
            Text(
              translations.orders_to + ": ${widget.dropoffAddressName}",
              style: whiteTitle,
            ),
            Spacer(
              flex: 5,
            ),
            Text(
              // translations.order_a_go_to + "!",
              'ORDER PRICE: $_orderPrice',
              style: bigLightBlueTitle,
            ),
            Spacer(
              flex: 5,
            ),
            RaisedButton(
              padding: EdgeInsets.all(20),
              child: Text(
                'Confirm Order',
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
              color: Colors.green,
              onPressed: () {
                print('Confirmed...');
                // priceConfirmation(
                //     context: context,
                //     user: widget.user,
                //     pickupAddressId: _pickupAddressId,
                //     dropoffAddressId: _dropoffAddressId,
                //     packageType: _businessCategory,
                //     isUrgent: _urgencyOption);
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => OrderCreated(
                        pickupAddressName: widget.pickupAddressName,
                        dropoffAddressName: widget.dropoffAddressName,
                        pickupAddressId: widget.pickupAddressId,
                        dropoffAddressId: widget.dropoffAddressId,
                        user: widget.user,
                        packageType: widget.packageType,
                        isUrgent: widget.isUrgent),
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
      bottomNavigationBar: BottomNavBar(),
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
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
