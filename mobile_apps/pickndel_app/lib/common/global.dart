import 'package:flutter/material.dart';

// Time limits
const MAX_WAIT_TIME = 10;
// NGROK or other as such
String serverDomain = 'https://pickndell.com';
// String serverDomain = 'https://1c7bc171824b.ngrok.io';
String defaultCountry = "Israel";
// Sizes
////////////////////

// Bottom Nav Bar
const NAVBAR_ICON_SIZE = 35.0;
const RIGHT_MARGINE = 30.0;
const LEFT_MARGINE = 30.0;
const TOP_MARGINE = 40.0;
const BUTTON_BORDER_RADIUS = 15.0;
const ORDER_STATUS_FONT_SIZE = 20.0;
// Colors
////////////////////

const FLOATING_RELOAD_BUTTON_COLOR = Colors.white;
const DEFAUT_TEXT_COLOR = Colors.white;

Color darkGreyColor = new Color(0xFF212128);
Color lightBlueColor = new Color(0xFF8787A0);
Color redColor = new Color(0xFFDC4F64);
Color greenColor = new Color(0xFFDC4F64);
Color pickndellGreen = new Color(0xFF8BC34A);
Color buttonBorderColor = new Color(0xFF8BC34A);
Color buttonTextColor = Colors.white;
Color rateButtonColor = Colors.orange;

Color mainBackground = new Color(0xFF202020);
Color ordersBackground = new Color(0xFF333333);

Color bottomNavigationBarColor = pickndellGreen;

// Fonts
////////////////////

TextStyle intrayTitleStyle = new TextStyle(
    fontFamily: 'Avenir',
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 15);

TextStyle intrayTitleStyleBlack = new TextStyle(
    fontFamily: 'Avenir',
    fontWeight: FontWeight.bold,
    color: Colors.black,
    fontSize: 15);

TextStyle userContentStyle =
    new TextStyle(fontFamily: 'Avenir', color: Colors.white, fontSize: 15);

TextStyle bigLightBlueTitle = new TextStyle(
    fontFamily: 'Avenir',
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 30);

TextStyle darkTodoTitle = new TextStyle(
    fontFamily: 'Avenir',
    fontWeight: FontWeight.bold,
    color: darkGreyColor,
    fontSize: 30);

TextStyle greenApproved = new TextStyle(
    fontFamily: 'Avenir',
    fontWeight: FontWeight.bold,
    color: pickndellGreen,
    fontSize: 15);

TextStyle whiteTitle = new TextStyle(
    fontFamily: 'Avenir',
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 25);

TextStyle whiteTitleH4 = new TextStyle(
    fontFamily: 'Avenir',
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 17);

TextStyle whiteTitleH3 = new TextStyle(
    fontFamily: 'Avenir',
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 20);

TextStyle whiteTitleH2 = new TextStyle(
    fontFamily: 'Avenir',
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 25);

TextStyle whiteButtonTitle = new TextStyle(
    fontFamily: 'Avenir',
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: 15);
TextStyle redTodoTitle = new TextStyle(
    fontFamily: 'Avenir',
    fontWeight: FontWeight.bold,
    color: redColor,
    fontSize: 30);

TextStyle redBoldText = new TextStyle(
    fontFamily: 'Avenir',
    fontWeight: FontWeight.bold,
    color: redColor,
    fontSize: 20);

TextStyle statusRequested = new TextStyle(
    fontFamily: 'Avenir',
    fontWeight: FontWeight.bold,
    color: Colors.white,
    fontSize: ORDER_STATUS_FONT_SIZE);

TextStyle statusStarted = new TextStyle(
    fontFamily: 'Avenir',
    fontWeight: FontWeight.bold,
    color: Colors.blue,
    fontSize: ORDER_STATUS_FONT_SIZE);

TextStyle statusInProgress = new TextStyle(
    fontFamily: 'Avenir',
    fontWeight: FontWeight.bold,
    color: Colors.yellow,
    fontSize: ORDER_STATUS_FONT_SIZE);

TextStyle statusRejected = new TextStyle(
    fontFamily: 'Avenir',
    fontWeight: FontWeight.bold,
    color: Colors.red,
    fontSize: ORDER_STATUS_FONT_SIZE);

TextStyle statusDelivered = new TextStyle(
    fontFamily: 'Avenir',
    fontWeight: FontWeight.bold,
    color: Color(0xFF8BC34A),
    fontSize: ORDER_STATUS_FONT_SIZE);

TextStyle redText =
    new TextStyle(fontFamily: 'Avenir', color: redColor, fontSize: 20);
