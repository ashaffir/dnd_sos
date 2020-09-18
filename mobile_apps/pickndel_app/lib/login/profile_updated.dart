import 'package:async/async.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:pickndell/api_connection/api_connection.dart';
import 'package:pickndell/dao/user_dao.dart';
import 'package:pickndell/database/user_database.dart';
import 'package:pickndell/home/home_page_isolate.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/location/geo_helpers.dart';
import 'package:pickndell/model/credit_card.dart';
import 'package:pickndell/model/order.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/repository/order_repository.dart';
import 'package:pickndell/repository/user_repository.dart';
import 'package:pickndell/ui/bottom_nav_bar.dart';
import 'package:pickndell/ui/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/global.dart';
import 'dart:io';

class ProfileUpdated extends StatefulWidget {
  final String updateField;
  final String value;
  final User user;
  final String operation;
  final CreditCard creditCardInfo;
  final File image;

  ProfileUpdated(
      {this.user,
      this.updateField,
      this.value,
      this.operation,
      this.creditCardInfo,
      this.image});

  @override
  _ProfileUpdatedState createState() => _ProfileUpdatedState();
}

class _ProfileUpdatedState extends State<ProfileUpdated> {
  @override
  void initState() {
    super.initState();
    _getTempEmail();
  }

  String orderUpdated;
  final dbProvider = DatabaseProvider.dbProvider;
  final userTable = 'userTable';

  Widget build(BuildContext context) {
    final trans = ExampleLocalizations.of(context);
    if (widget.operation == 'check_code') {
      print(
          '> STAGE 6) Sending the code entered by the user. Code: ${widget.value} Email: $tmail');
      return FutureBuilder(
        future: widget.updateField == 'email'
            ? _checkEmailVerificationCode(
                user: widget.user,
                code: widget.value,
                operation: widget.operation)
            : _checkPhoneVerificationCode(
                user: widget.user,
                code: widget.value,
                operation: widget.operation),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            print(
                '> STAGE 7) Cheking the response from the server: ${snapshot.data}');

            if (snapshot.data["response"] == "Update successful") {
              print(
                  '> STAGE 8) Code verified successfully. Getting the temporary ${widget.updateField}...');

              var data = widget.updateField == 'email'
                  ? {"email": tmail}
                  : {'phone': tphone};

              print('> STAGE 9) Updating DB with data: $data');
              rowUpdate(data);

              print('> STAGE 10) FINISHED PROFILE UPDATED!!!!');
              return getProfileUpdatedPage(snapshot.data);
            } else if (snapshot.data["response"] == "Update failed") {
              print('> STAGE 8.a) Falied with server response. ');
              return profileUpdatedErrorPage();
            } else {
              print(
                  'Falied WITHOUT server response. RESPONSE: ${snapshot.data}');
              return profileUpdatedErrorPage();
            }
          } else {
            print("No data:");
          }
          print('Waiting for code verification...');
          String loaderText = "Verifying code...";
          return ColoredProgressDemo(loaderText);
        },
      );
    } else {
      return FutureBuilder(
        future: widget.updateField == 'photo_id'
            ? _updatePhotoId(user: widget.user, image: widget.image)
            // ? _uploadImage(widget.image)
            : widget.updateField == 'credit_card'
                ? _updateCreditCard(
                    user: widget.user, creditCard: widget.creditCardInfo)
                : updateRemoteProfile(widget.updateField, widget.value),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            print('PROFILE UPDATED: ${snapshot.data}');

            if (snapshot.data["response"] == "Update successful") {
              var data = widget.updateField == 'credit_card'
                  ? {'credit_card_token': snapshot.data['credit_card_token']}
                  : snapshot.data;

              rowUpdate(data);

              print('FINISHED PROFILE UPDATED!!!!');
              if (widget.updateField == 'name') {
                return HomePageIsolate();
              } else {
                return getProfileUpdatedPage(snapshot.data);
              }
            } else if (snapshot.data['response'] == 'ID updated') {
              return getProfileUpdatedPage(snapshot.data['response']);
            } else if (snapshot.data["response"] == "Update failed") {
              print('Falied with server response. ');
              return profileUpdatedErrorPage();
            } else {
              print(
                  'Falied WITHOUT server response. RESPONSE: ${snapshot.data}');
              return profileUpdatedErrorPage();
            }
          } else {
            print("No data:");
          }
          print('WAITING FOR PROFILE UPDATE');
          String loaderText = "Updating Profile...";
          return ColoredProgressDemo(loaderText);
        },
      );
    }
  }

  // REFERENCE: Updating row in the DB
  //https://stackoverflow.com/questions/54102043/how-to-do-a-database-update-with-sqflite-in-flutter
  Future<int> rowUpdate(dynamic data) async {
    final db = await dbProvider.database;
    // final currentUser = await UserDao().getUser(0);
    final currentUser = widget.user;
    int updateCount;
    if (currentUser.isEmployee == 1) {
      updateCount = await db.rawUpdate('''
    UPDATE $userTable 
    SET name = ?, username = ?, phone = ? , vehicle = ?
    WHERE id = ?
    ''', [data['name'], data['email'], data['phone'], data['vehicle'], 0]);
    } else {
      updateCount = await db.rawUpdate('''
    UPDATE $userTable 
    SET businessName = ?, phone = ?, username = ?, businessCategory = ?, creditCardToken = ?
    WHERE id = ?
    ''', [
        data['business_name'],
        data['phone'],
        data['email'],
        data['business_category'],
        data['credit_card_token'],
        0
      ]);
    }
    print('ROWS UPDATED: $updateCount ');

    return updateCount;
  }

  Future _updateCreditCard({User user, CreditCard creditCard}) async {
    var _cardUpdate;
    _cardUpdate = await updateCreditCard(user: user, creditCard: creditCard);
    return _cardUpdate;
  }

  Future _updatePhotoId({User user, File image}) async {
    var _photoIdUpdate;
    // _photoIdUpdate = await updatePhotoId(user: user, image: image);
    _photoIdUpdate = await _uploadImage(image);
    print('6: UPDATE: $_photoIdUpdate');
    return _photoIdUpdate;
  }

  String tphone;
  Future _checkPhoneVerificationCode(
      {String code, User user, String operation}) async {
    tphone = await _getTempPhone();
    print('In function PHONE: $tphone, CODE: $code');
    var _codeVerified;
    _codeVerified = await phoneVerificationAPI(
        phone: tphone,
        verificationCode: code,
        user: user,
        action: 'verify_code');
    return _codeVerified;
  }

  Future<String> _getTempPhone() async {
    final localStorage = await SharedPreferences.getInstance();
    final _tempPhone = localStorage.getString('tmpPhone');
    if (_tempPhone == null) {
      return "";
    } else {
      return _tempPhone;
    }
  }

  String tmail;
  Future _checkEmailVerificationCode(
      {String code, User user, String operation}) async {
    tmail = await _getTempEmail();
    print('In function EMAIL: $tmail, CODE: $code');
    var _codeVerified;
    _codeVerified = await emailVerificationAPI(
        email: tmail, code: code, user: user, codeDirection: 'test_result');
    return _codeVerified;
  }

  Future<String> _getTempEmail() async {
    final localStorage = await SharedPreferences.getInstance();
    final _tempEmail = localStorage.getString('tmpEmail');
    if (_tempEmail == null) {
      return "";
    } else {
      return _tempEmail;
    }
  }

  _uploadImage(File imageFile) async {
    // open a bytestream
    print('1');
    var stream = new http.ByteStream(DelegatingStream(imageFile.openRead()));
    // get file length
    var length = await imageFile.length();
    print('2: length: $length');

    // string to uri
    var uri = Uri.parse("https://94b6703642d5.ngrok.io/api/user-photo-id/");

    // create multipart request
    var request = new http.MultipartRequest("POST", uri);
    print('3: request: $request');

    // multipart that takes file
    var multipartFile = new http.MultipartFile('image', stream, length,
        filename: imageFile.path.split("/").last);

    // add file to multipart
    request.files.add(multipartFile);

    // send
    var response = await request.send();
    print('4: request: ${response.statusCode}');

    // listen for response
    response.stream.transform(utf8.decoder).listen((value) {
      print('5: value: $value');
      return value;
    });
  }

  Future updateRemoteProfile(String updateField, String value) async {
    print('UPDATINNG REMOTE PROFILE. CHANGING $updateField');
    var updateResponse;
    updateResponse = await updateUser(
        user: widget.user, value: value, updateField: updateField);
    print('Field updated: $updateResponse');
    return updateResponse;
  }

  Widget getProfileUpdatedPage(dynamic order) {
    final trans = ExampleLocalizations.of(context);

    return Scaffold(
      // backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text('Profile Update'),
      ),
      body: Container(
        height: 300,
        padding: EdgeInsets.all(30),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: 30),
              ),
              Text(
                'Your profile was successfully updated',
                style: bigLightBlueTitle,
              ),
              Padding(
                padding: EdgeInsets.only(top: 100),
              ),
              FlatButton(
                child: Text('Back To Main Page'),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return HomePageIsolate(
                          userRepository: UserRepository(),
                        );
                      },
                    ),
                    (Route<dynamic> route) =>
                        false, // No Back option for this page
                  );
                },
                color: pickndellGreen,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }

  Widget profileUpdatedErrorPage() {
    final trans = ExampleLocalizations.of(context);

    return new Scaffold(
      backgroundColor: mainBackground,
      appBar: AppBar(
        title: Text('Error updating profile'),
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
              'Please try again later',
              style: bigLightBlueTitle,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
