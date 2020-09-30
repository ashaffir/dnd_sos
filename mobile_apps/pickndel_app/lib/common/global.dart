import 'package:flutter/material.dart';

// Time limits
const MAX_WAIT_TIME = 10;
// NGROK or other as such
String serverDomain = 'https://3dbc8c54441a.ngrok.io';
String defaultCountry = "Israel";
// Sizes
////////////////////

// Bottom Nav Bar
const NAVBAR_ICON_SIZE = 35.0;
const RIGHT_MARGINE = 30.0;
const LEFT_MARGINE = 30.0;
const TOP_MARGINE = 40.0;
const BUTTON_BORDER_RADIUS = 15.0;

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

TextStyle redText =
    new TextStyle(fontFamily: 'Avenir', color: redColor, fontSize: 20);
