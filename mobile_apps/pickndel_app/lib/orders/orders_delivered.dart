import 'package:flutter/material.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/common/helper.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/model/order.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/orders/order_page.dart';
import 'package:pickndell/orders/order_rated.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

double _userRating;

Widget deliveredOrders({Order order, User user, BuildContext context}) {
  final trans = ExampleLocalizations.of(context);
  return Center(
    child: InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderPage(
                user: user,
                order: order,
                orderId: order.order_id,
              ),
            ));
      },
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    trans.orders_status_delivered,
                    style: TextStyle(
                      backgroundColor: pickndellGreen,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            ListTile(
              // leading: Icon(Icons.album),
              leading: CircleAvatar(
                radius: 25,
                foregroundColor: Colors.white,
                backgroundColor: Colors.blueGrey,
                child: order.order_type.toString() == 'Documents'
                    ? Icon(Icons.collections_bookmark)
                    : order.order_type.toString() == 'Food'
                        ? Icon(Icons.restaurant)
                        : order.order_type.toString() == 'Tools'
                            ? Icon(Icons.fitness_center)
                            : order.order_type.toString() == 'Furniture'
                                ? Icon(Icons.weekend)
                                : order.order_type.toString() == 'Clothes'
                                    ? Icon(Icons.wc)
                                    : Icon(Icons.whatshot),
              ),
              title: Text(trans.orders_from + ': ${order.pick_up_address}'),
              subtitle: Text(trans.orders_to + ': ${order.drop_off_address}'),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(trans.orders_created + ': ${order.created}'),
                  Text(trans.orders_update + ': ${order.updated}'),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Text('Fee: ${order.price}'),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    if (order.freelancerRating != 0.0)
                      Text(trans.orders_you_rated_courier + ":"),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: SmoothStarRating(
                          rating: order.freelancerRating,
                          onRated: (value) {
                            _userRating = value;
                          },
                          isReadOnly:
                              order.freelancerRating == 0.0 ? false : true,
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
                    if (order.freelancerRating == 0.0)
                      RaisedButton.icon(
                        icon: Icon(
                          Icons.star,
                          color: Colors.white,
                        ),
                        color: rateButtonColor,
                        shape: StadiumBorder(
                            side: BorderSide(color: Colors.black)),
                        onPressed: () {
                          if (_userRating == null)
                            showAlertDialog(
                                context: context,
                                title: trans.please_choose_rating,
                                content: trans.click_or_drag_stars);
                          if (_userRating != null)
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OrderRated(
                                  order: order,
                                  user: user,
                                  rating: _userRating,
                                ),
                              ),
                              (Route<dynamic> route) =>
                                  false, // No Back option for this page
                            );
                        },
                        label: Text(
                          trans.orders_rate_courier,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}
