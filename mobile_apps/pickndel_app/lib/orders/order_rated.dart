import 'package:pickndell/common/error_page.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/model/order.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/networking/ApiProvider.dart';
import 'package:pickndell/ui/bottom_navigation_bar.dart';
import 'package:pickndell/ui/progress_indicator.dart';
import 'package:flutter/material.dart';
import '../common/global.dart';

class OrderRated extends StatefulWidget {
  final Order order;
  final User user;
  final double rating;
  OrderRated({this.order, this.user, this.rating});

  @override
  _OrderRatedState createState() => _OrderRatedState();
}

class _OrderRatedState extends State<OrderRated> {
  @override
  void initState() {
    super.initState();
  }

  String orderUpdated;

  Widget build(BuildContext context) {
    final translations = ExampleLocalizations.of(context);

    return FutureBuilder(
      future: updateOrderRating(widget.order, widget.rating),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          print('ORDER RATED: ${snapshot.data["response"]}');

          if (snapshot.data["response"] == "Update successful") {
            return getOrderRatedPage(widget.order);
          } else if (snapshot.data["response"] == "Update failed") {
            return orderRatedErrorPage();
          } else {
            return orderRatedErrorPage();
          }
        } else {
          print("No data:");
        }
        print('WAITING FOR ORDER RATING UPDATE');
        String loaderText = "Updating Order...";

        return ColoredProgressDemo(loaderText);
      },
    );
  }

  Future updateOrderRating(Order order, double rating) async {
    ApiProvider _provider = ApiProvider();

    final trans = ExampleLocalizations.of(context);
    var _url = "order-ratings/";
    try {
      // var user = await UserDao().getUser(0);
      var response =
          await _provider.rating(_url, order.order_id, widget.user, rating);

      return response;
    } catch (e) {
      print('UPDATE ORDER ERROR: $e');
      return Navigator.pushAndRemoveUntil(
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

  Widget getOrderRatedPage(Order order) {
    final translations = ExampleLocalizations.of(context);

    return new Scaffold(
      // backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text(translations.orders_update),
      ),
      body: Container(
        padding: EdgeInsets.only(left: LEFT_MARGINE, right: RIGHT_MARGINE),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(
              flex: 2,
            ),
            Center(
              child: Text(
                translations.courier_rating_updated,
                style: bigLightBlueTitle,
              ),
            ),
            Text(
              translations.thank_you,
              style: bigLightBlueTitle,
            ),
            Spacer(
              flex: 2,
            ),
            Image.asset(
              'assets/images/check-icon.png',
              width: MediaQuery.of(context).size.width * 0.50,
            ),
            Spacer(
              flex: 4,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        user: widget.user,
      ),
    );
  }

  Widget orderRatedErrorPage() {
    final translations = ExampleLocalizations.of(context);

    return new Scaffold(
      // backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text(translations.orders_error),
      ),
      body: Container(
        // padding: EdgeInsets.only(left: 50),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Spacer(
              flex: 2,
            ),
            Text(
              translations.order_p_problem,
              style: bigLightBlueTitle,
            ),
            Image.asset(
              'assets/images/fail-icon.png',
              width: MediaQuery.of(context).size.width * 0.50,
            ),
            Spacer(
              flex: 4,
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
