import 'package:flutter/material.dart';
import 'package:pickndell/model/order.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

Widget ratingWidget({User user, Order order, double rating}) {
  return MaterialApp(
      title: 'Rating bar demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
          body: Center(
              child: SmoothStarRating(
        rating: rating,
        isReadOnly: false,
        size: 80,
        filledIconData: Icons.star,
        halfFilledIconData: Icons.star_half,
        defaultIconData: Icons.star_border,
        starCount: 5,
        allowHalfRating: true,
        spacing: 2.0,
        onRated: (value) {
          print("rating value -> $value");
          // print("rating value dd -> ${value.truncate()}");
        },
      ))));
}
