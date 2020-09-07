import 'package:google_maps_webservice/places.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/location/credencials.dart';
import 'package:pickndell/location/place.dart';
import 'package:pickndell/model/order.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/repository/order_repository.dart';
import 'package:pickndell/ui/bottom_nav_bar.dart';
import 'package:pickndell/ui/progress_indicator.dart';
import 'package:flutter/material.dart';
import '../common/global.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderCreated extends StatefulWidget {
  final String pickupAddressName;
  final String dropoffAddressName;
  final String pickupAddressId;
  final String dropoffAddressId;
  final String isUrgent;
  final String packageType;
  final User user;

  OrderCreated(
      {this.pickupAddressName,
      this.pickupAddressId,
      this.dropoffAddressId,
      this.dropoffAddressName,
      this.user,
      this.isUrgent,
      this.packageType});

  @override
  _OrderCreatedState createState() => _OrderCreatedState();
}

class _OrderCreatedState extends State<OrderCreated> {
  var updatedOrderId;
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
          print('ORDER CREATED: ${snapshot.data}');

          if (snapshot.data == "Order Created") {
            return getOrderCreatedPage(snapshot.data);
          } else if (snapshot.data["response"] == "Update failed") {
            return orderAcceptErrorPage();
          } else {
            return orderAcceptErrorPage();
          }
        } else {
          print("No data:");
        }
        print('CONFIRMING ORDER');
        String loaderText = 'Confirming order. Stand by' + "...";
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

    final orderCreatedResponse = await OrderRepository().newOrderRepo(
        user: user,
        priceOrder: false,
        pickupAddress: pickupAddress,
        dropoffAddress: dropoffAddress,
        urgency: widget.isUrgent,
        packageType: widget.packageType);

    return orderCreatedResponse;
  }

  Widget getOrderCreatedPage(dynamic order) {
    final translations = ExampleLocalizations.of(context);

    return new Scaffold(
      backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text('Order Confirmed.'),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 50),
        // height: 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Spacer(
              flex: 2,
            ),
            Text(
              // translations.order_a_go_to + "!",
              'ORDER CREATED!',
              style: bigLightBlueTitle,
            ),
            Spacer(
              flex: 2,
            ),
            // Text(
            //   translations.orders_from + ': ${order["pick_up_address"]}',
            //   style: whiteTitle,
            // ),
            // Spacer(
            //   flex: 2,
            // ),
            // Text(
            //   translations.orders_to + ": ${order["drop_off_address"]}",
            //   style: whiteTitle,
            // )
            Spacer(
              flex: 2,
            )
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

// TODO: Add the pick and drop addresses coordinates

class MapUtils {
  MapUtils._();

  static Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(googleUrl)) {
      await launch(googleUrl);
    } else {
      throw 'Could not open the map.';
    }
  }
}
