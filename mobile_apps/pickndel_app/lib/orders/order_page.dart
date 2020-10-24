import 'package:flutter/cupertino.dart';
import 'package:pickndell/common/helper.dart';
import 'package:pickndell/common/map_utils.dart';
import 'package:pickndell/lang/lang_helper.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/model/order.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/orders/order_accepted.dart';
import 'package:pickndell/orders/order_delivery.dart';
import 'package:pickndell/orders/order_list.dart';
import 'package:pickndell/orders/order_picked_up.dart';
import 'package:pickndell/orders/order_rated.dart';
import 'package:pickndell/ui/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import '../common/global.dart';
import 'package:url_launcher/url_launcher.dart';

class OrderPage extends StatefulWidget {
  final Order order;
  final String orderId;
  final User user;
  final String country;

  OrderPage({this.order, this.orderId, this.user, this.country});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  var updatedOrderId;
  @override
  int _rookieLevelLimit;
  int _advancedLevelLimit;
  int _expertLevelLimit;

  Future _checAccountLevels() async {
    try {
      SharedPreferences localStorage = await SharedPreferences.getInstance();
      _rookieLevelLimit = localStorage.getInt('rookieLevel');
      _advancedLevelLimit = localStorage.getInt('advancedLevel');
      _expertLevelLimit = localStorage.getInt('expertLevel');
    } catch (e) {
      print(
          'Failed getting the account level limits from SharedPreferences. ERROR: $e');
      _rookieLevelLimit = 1;
      _advancedLevelLimit = 11;
      _expertLevelLimit = 25;
    }
  }

  void initState() {
    _checAccountLevels();
    super.initState();
    try {
      updatedOrderId = widget.order.order_id;
    } catch (e) {
      updatedOrderId = widget.orderId;
    }
  }

  String orderUpdated;
  double userRating;

  Widget build(BuildContext context) {
    final translations = ExampleLocalizations.of(context);
    return new Scaffold(
      // backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text(translations.order_page),
      ),
      body: Container(
        padding: EdgeInsets.only(left: LEFT_MARGINE, right: RIGHT_MARGINE),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Spacer(
              flex: 2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  translations.order_details,
                  style: bigLightBlueTitle,
                ),
                Padding(padding: EdgeInsets.only(right: 10)),
                Text(
                    widget.order.isUrgent == 1
                        ? translations.orders_urgent
                        : "",
                    style: widget.order.isUrgent == 1
                        ? TextStyle(
                            color: Colors.orange, fontWeight: FontWeight.bold)
                        : whiteTitleH4),
              ],
            ),
            Spacer(
              flex: 1,
            ),
            ///////////////// Order Status ///////////////////
            ///
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  translations.orders_status + ":",
                  style: whiteTitleH3,
                ),
                Padding(padding: EdgeInsets.only(right: 10)),
                Text(
                  _translateOrderStatus(widget.order.status),
                  style: _getStatusColor(widget.order.status),
                ),
              ],
            ),
            Spacer(
              flex: 1,
            ),
            ///////////////// Package Type ///////////////////
            Row(
              children: [
                Text(translations.package_type + ":"),
                Padding(padding: EdgeInsets.only(right: 10)),
                Text(
                  translateCategory(widget.order.order_type),
                  style: whiteTitleH4,
                ),
              ],
            ),
            Divider(
              color: Colors.white,
            ),
            Spacer(
              flex: 1,
            ),

            ///////////////// Locations ///////////////////

            Text(
              translations.orders_from + ': ${widget.order.pick_up_address}',
              style: whiteTitleH3,
            ),
            Spacer(
              flex: 1,
            ),
            Text(
              translations.orders_to + ": ${widget.order.drop_off_address}",
              style: whiteTitleH3,
            ),
            Spacer(
              flex: 6,
            ),
            Divider(color: Colors.white),
            Spacer(
              flex: 2,
            ),

            // Delivery Fare -  for couriers
            if ((widget.country == 'Israel' || widget.country == 'ישראל') &&
                widget.user.isEmployee == 1)
              Text(
                translations.orders_fare +
                    ": " +
                    "${roundDouble(widget.order.fare * widget.user.usdIls, 2)} ₪",
                style: whiteTitleH3,
              ),
            if ((widget.country != 'Israel' && widget.country != 'ישראל') &&
                widget.user.isEmployee == 1)
              Text(
                translations.orders_fare + ": " + "${widget.order.fare} \$",
                style: whiteTitleH3,
              ),

            // Cost for Businesses/Sender
            if ((widget.country == 'Israel' || widget.country == 'ישראל') &&
                widget.user.isEmployee == 0)
              Text(
                translations.orders_order_cost +
                    ": " +
                    "${roundDouble(widget.order.price * widget.user.usdIls, 2)} ₪",
                style: whiteTitleH3,
              ),
            if ((widget.country != 'Israel' && widget.country != 'ישראל') &&
                widget.user.isEmployee == 0)
              Text(
                translations.orders_fare + ": " + "${widget.order.price} \$",
                style: whiteTitleH3,
              ),

            Spacer(
              flex: 6,
            ),

            ///////////////// Business Buttons ///////////////////
            ///

            if (widget.user.isEmployee == 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  if (widget.order.status == 'STARTED' ||
                      widget.order.status == 'IN_PROGRESS')

                    // Call the courier//
                    RaisedButton.icon(
                      label: Text(translations.orders_call_courier),
                      icon: Icon(Icons.phone),
                      color: Colors.blue,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(BUTTON_BORDER_RADIUS),
                          side: BorderSide(color: buttonBorderColor)),
                      onPressed: () {
                        launch(('tel://${widget.order.courier_phone}'));
                      },
                    ),
                  Padding(padding: EdgeInsets.all(5.0)),

                  // Cancel order - only in "Reqeusted/Re-requested//
                  if (widget.order.status == 'REQUESTED' ||
                      widget.order.status == 'RE_REQUESTED')
                    RaisedButton(
                      child: Text(
                        translations.orders_cancel_delivery,
                        style: whiteButtonTitle,
                      ),
                      color: Colors.red,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(BUTTON_BORDER_RADIUS),
                          side: BorderSide(color: buttonBorderColor)),
                      onPressed: () {
                        print('Cancel Order!!');
                        String newStatus = 'ARCHIVED';
                        OrdersList(
                          user: widget.user,
                        ).orderAlert(context, widget.order, newStatus);
                      },
                    ),

                  // Report pick up//
                  if (widget.order.status == 'STARTED')
                    RaisedButton(
                      child: Text(
                        translations.order_p_picked,
                        style: whiteButtonTitle,
                      ),
                      color: pickndellGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(BUTTON_BORDER_RADIUS),
                          side: BorderSide(color: buttonBorderColor)),
                      onPressed: () {
                        print('Delivered!!');
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OrderPickedup(
                              order: widget.order,
                              user: widget.user,
                            ),
                          ),
                          (Route<dynamic> route) =>
                              false, // No Back option for this page
                        );
                      },
                    ),

                  // Give feedback//
                  if (widget.order.status == 'COMPLETED')
                    Column(
                      children: <Widget>[
                        if (widget.order.freelancerRating != 0.0)
                          Text(translations.orders_you_rated_courier + ":"),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: SmoothStarRating(
                              rating: widget.order.freelancerRating,
                              onRated: (value) {
                                setState(() {
                                  userRating = value;
                                });
                              },
                              isReadOnly: widget.order.freelancerRating == 0.0
                                  ? false
                                  : true,
                              size: 30,
                              filledIconData: Icons.star,
                              halfFilledIconData: Icons.star_half,
                              defaultIconData: Icons.star_border,
                              borderColor: Colors.white30,
                              starCount: 5,
                              allowHalfRating: true,
                              color: Colors.yellow,
                              spacing: 0.0),
                        ),
                        Padding(padding: EdgeInsets.only(bottom: 20)),
                        if (widget.order.freelancerRating == 0.0)
                          RaisedButton.icon(
                            icon: Icon(Icons.star, color: Colors.white),
                            label: Text(
                              translations.orders_rate_courier,
                              style: whiteButtonTitle,
                            ),
                            color: Colors.orange,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(BUTTON_BORDER_RADIUS),
                                side: BorderSide(color: buttonBorderColor)),
                            onPressed: () {
                              print('Rate courier: $userRating');
                              if (userRating == null)
                                showAlertDialog(
                                    context: context,
                                    title: translations.please_choose_rating,
                                    content: translations.click_or_drag_stars);
                              if (userRating != null)
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderRated(
                                      order: widget.order,
                                      user: widget.user,
                                      rating: userRating,
                                    ),
                                  ),
                                  (Route<dynamic> route) =>
                                      false, // No Back option for this page
                                );
                            },
                          ),
                      ],
                    ),
                ],
              ),

            ////////////////////// Freelancer Buttons /////////////////
            ///
            if (widget.user.isEmployee == 1)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ButtonBar(
                    children: <Widget>[
                      if (widget.order.status == 'STARTED' ||
                          widget.order.status == 'IN_PROGRESS')
                        RaisedButton.icon(
                          label: Text(translations.orders_call_sender),
                          icon: Icon(Icons.phone),
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(BUTTON_BORDER_RADIUS),
                              side: BorderSide(color: buttonBorderColor)),
                          onPressed: () {
                            launch(('tel://${widget.order.business_phone}'));
                          },
                        ),
                      Padding(padding: EdgeInsets.all(5.0)),
                      if (widget.order.status == 'STARTED' ||
                          widget.order.status == 'IN_PROGRESS')
                        RaisedButton.icon(
                          padding: EdgeInsets.only(left: 20, right: 20),
                          icon: Icon(
                            Icons.navigation,
                            color: pickndellGreen,
                          ),
                          color: Colors.transparent,
                          shape: StadiumBorder(
                              side: BorderSide(color: pickndellGreen)),
                          label: Text(
                            translations.navigate,
                            style: whiteButtonTitle,
                          ),
                          onPressed: () {
                            if (widget.order.status == 'IN_PROGRESS') {
                              print(
                                  'IN PROGRESS STATUS: ${widget.order.status}');
                              print(
                                  '>>>>> NAVIGATE TO DROP OFF: LAT: ${widget.order.dropoffAddressLat} LON: ${widget.order.dropoffAddressLng}');

                              MapUtils.openMap(widget.order.dropoffAddressLat,
                                  widget.order.dropoffAddressLng);
                            } else {
                              print('STARTED STATUS: ${widget.order.status}');
                              print(
                                  '>>>>> NAVIGATE TO PICKUP: LAT: ${widget.order.pickUpAddressLat} LON: ${widget.order.pickUpAddressLng}');

                              MapUtils.openMap(widget.order.pickUpAddressLat,
                                  widget.order.pickUpAddressLng);
                            }
                          },
                        ),
                      if (widget.user.isEmployee == 1 &&
                          widget.order.status == 'REQUESTED')
                        RaisedButton(
                          padding: EdgeInsets.all(30),
                          child: Text(
                            translations.orders_accept,
                            style: whiteTitleH2,
                          ),
                          color: pickndellGreen,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(BUTTON_BORDER_RADIUS),
                              side: BorderSide(color: buttonBorderColor)),
                          onPressed: () {
                            print('Accepted!!');
                            String newStatus = "STARTED";
                            if ((widget.user.accountLevel == 'Rookie' &&
                                    widget.user.activeOrders <=
                                        _rookieLevelLimit) ||
                                (widget.user.accountLevel == 'Advanced' &&
                                    widget.user.activeOrders <=
                                        _advancedLevelLimit) ||
                                (widget.user.accountLevel == 'Expert' &&
                                    widget.user.activeOrders <=
                                        _expertLevelLimit)) {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OrderAccepted(
                                    order: widget.order,
                                    user: widget.user,
                                  ),
                                ),
                                (Route<dynamic> route) =>
                                    false, // No Back option for this page
                              );
                            } else {
                              showAlertDialog(
                                  context: context,
                                  title: translations.account_level_limit,
                                  content: translations.orders_account_limit +
                                      "${widget.user.accountLevel}",
                                  okButtontext: translations.close);
                            }
                          },
                        ),
                    ],
                  ),
                ],
              ),
            Spacer(
              flex: 10,
            ),

            if (widget.user.isEmployee == 1 &&
                (widget.order.status == 'IN_PROGRESS'))
              RaisedButton(
                padding: EdgeInsets.all(20),
                child: Text(
                  translations.orders_report_delivered,
                  style: whiteTitleH4,
                ),
                color: pickndellGreen,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(BUTTON_BORDER_RADIUS),
                    side: BorderSide(color: buttonBorderColor)),
                onPressed: () {
                  print('Delivered!!');
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OrderDelivery(
                              user: widget.user,
                              updateField: 'delivery_photo',
                              order: widget.order,
                            )),
                  );
                },
              ),
            Spacer(
              flex: 10,
            ),
            CupertinoActionSheetAction(
              child: Text(translations.back,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Spacer(
              flex: 10,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        user: widget.user,
      ),
    );
  }

  TextStyle _getStatusColor(orderStatus) {
    TextStyle statusColor;
    switch (orderStatus) {
      case 'REQUESTED':
        statusColor = statusRequested;
        break;
      case 'STARTED':
        statusColor = statusStarted;
        break;
      case 'IN_PROGRESS':
        statusColor = statusInProgress;
        break;
      case 'REJECTED':
        statusColor = statusRejected;
        break;
      case 'COMPLETED':
        statusColor = statusDelivered;
        break;

      default:
    }
    return statusColor;
  }

  String _translateOrderStatus(orderStatus) {
    String translated;
    switch (orderStatus) {
      case 'REQUESTED':
        translated = 'פתוחה';
        break;
      case 'REJECTED':
        translated = 'נדחה';
        break;
      case 'IN_PROGRESS':
        translated = 'בתהליך מסירה';
        break;
      case 'STARTED':
        translated = 'התחילה מחכה לשליח';
        break;
      case 'COMPLETED':
        translated = 'נמסר';
        break;
      case 'RE_REQUESTED':
        translated = 'נפתח מחדש';
        break;
      default:
    }
    return translated;
  }
}
