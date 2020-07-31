import 'package:bloc_login/home/bottom_nav_bar.dart';
import 'package:flutter/material.dart';
import '../common/global.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderAccepted extends StatelessWidget {
  final String order_id;
  final String pick_up_address;
  final String drop_off_address;

  const OrderAccepted(
      {this.order_id, this.pick_up_address, this.drop_off_address});

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text('Order Accepted'),
      ),
      body: Container(
        padding: EdgeInsets.only(left: 50),
        height: 160,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Spacer(
              flex: 4,
            ),
            Text(
              "Go to pick up!",
              style: bigLightBlueTitle,
            ),
            Spacer(
              flex: 2,
            ),
            Text(
              'From: $pick_up_address',
              style: whiteTitle,
            ),
            Spacer(
              flex: 2,
            ),
            Text(
              "To: $drop_off_address",
              style: whiteTitle,
            )
          ],
        ),
        // child: Row(
        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //   children: <Widget>[
        //     Text(
        //       "Go to pick up!",
        //       style: bigLightBlueTitle,
        //     ),
        //     Container(
        //       child: Column(
        //         children: [
        //           Text(
        //             'From $pick_up_address',
        //             style: whiteTitle,
        //           ),
        //           Spacer(),
        //           Text(
        //             "To: $drop_off_address",
        //             style: whiteTitle,
        //           )
        //         ],
        //       ),
        //     )
        //   ],
        // ),
      ),

      //   child: Column(
      //     children: <Widget>[
      //       Text('Go To pick up!'),
      //       Text('Pick Up Address: $pick_up_address'),
      //       Text('Drop Off Address: $drop_off_address')
      //     ],
      //   ),
      // ),
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
