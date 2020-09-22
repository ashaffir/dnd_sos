// REFERENCE: Login/Registration. No Bloc
// REFERENCE: Form fields and validatios: https://www.youtube.com/watch?v=nFSL-CqwRDo
// REFERENCE: Snackbar/Flushbar: https://www.youtube.com/watch?v=KNpxyyA8MDA
// REFERENCE: Dropdown text: https://www.youtube.com/watch?v=L3E4LNSrSWM
import 'dart:convert';
import 'dart:ui' as ui;

import 'package:iban/iban.dart';
import 'package:pickndell/api_connection/api_connection.dart';
import 'package:pickndell/common/global.dart';
import 'package:pickndell/common/helper.dart';
import 'package:pickndell/localizations.dart';
import 'package:pickndell/login/login_page.dart';
import 'package:pickndell/login/message_page.dart';
import 'package:pickndell/model/user_model.dart';
import 'package:pickndell/networking/messaging_widget.dart';
import 'package:pickndell/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flushbar/flushbar_helper.dart';
import 'package:url_launcher/url_launcher.dart';

class BankDetailsForm extends StatefulWidget {
  final User user;
  BankDetailsForm({this.user});
  @override
  _BankDetailsFormState createState() => _BankDetailsFormState();
}

class _BankDetailsFormState extends State<BankDetailsForm> {
  // TextEditingController _userNameController = TextEditingController();
  TextEditingController _iban = TextEditingController();
  TextEditingController _bankName = TextEditingController();
  TextEditingController _bankBranch = new TextEditingController();
  TextEditingController _bankAccount = new TextEditingController();
  TextEditingController _nameAccount = new TextEditingController();
  TextEditingController _idNumber = new TextEditingController();
  TextEditingController _swiftCode = new TextEditingController();

  String bankName;
  String bankBranch;
  String bankAccount;
  String nameAccount;
  String idNumber;
  String swiftCode;

  UserRepository userRepository = UserRepository();
  bool _isLoading = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _userType;
  var _registrationTypes = List<DropdownMenuItem>();
  // List<String> _registrationTypeList = ['Sender', 'Courier'];
  List<String> _registrationTypeList;

  _loadRegistrationTypes() {
    // if (ui.window.locale.languageCode == 'he') {
    //   _registrationTypeList = ['שולח', 'שליח'];
    // } else {
    _registrationTypeList = ['Sender', 'Courier'];
    // }

    _registrationTypeList.forEach((element) {
      setState(() {
        _registrationTypes.add(DropdownMenuItem(
          child: Text(element),
          value: element,
        ));
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _loadRegistrationTypes();
  }

  @override
  Widget build(BuildContext context) {
    final trans = ExampleLocalizations.of(context);

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(trans.register_join),
      // ),
      body: SafeArea(
        child: Scaffold(
          body: Container(
            child: SingleChildScrollView(
                child: Form(
                    key: _formKey,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: LEFT_MARGINE,
                          right: RIGHT_MARGINE,
                          top: TOP_MARGINE),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          MessagingWidget(),

                          // Image.asset(
                          //   'assets/images/pickndell-logo-white.png',
                          //   width: MediaQuery.of(context).size.width * 0.70,
                          //   // height: MediaQuery.of(context).size.height * 0.50,
                          //   // width: 300,
                          // ),
                          // Padding(
                          //   padding: EdgeInsets.all(10.0),
                          // ),
                          Text(
                            "Bank Details",
                            style: whiteTitle,
                          ),
                          Padding(
                            padding: EdgeInsets.all(10.0),
                          ),
                          // DropdownButtonFormField(
                          //   decoration: InputDecoration(
                          //       labelText: "Bank Name" + ":",
                          //       prefixIcon: Icon(Icons.business)),
                          //   value: _userType,
                          //   items: _registrationTypes,
                          //   validator: (value) {
                          //     if (dropdownMenue(value) == null) {
                          //       return null;
                          //     } else {
                          //       return trans.register_alert_as;
                          //     }
                          //   },
                          //   onChanged: (value) {
                          //     setState(() {
                          //       print('dropdown: $value');
                          //       _userType = value;
                          //     });
                          //   },
                          //   // hint: Text("Registration as:"),
                          // ),
                          // Padding(
                          //   padding: EdgeInsets.all(10.0),
                          // ),

                          /////////////// Bank Name ////////////
                          ///

                          TextFormField(
                            decoration: InputDecoration(
                                labelText: "IBAN", icon: Icon(Icons.language)),
                            controller: _iban,
                            validator: (iban) {
                              if (isValid(iban)) {
                                return null;
                              } else {
                                return "Please enter a valid IBAN";
                              }
                            },
                            // validator: (String value) {
                            //   if (value.isEmpty) {
                            //     return "Valid email required.";
                            //   }
                          ),

                          /////////////// Name of the account ////////////
                          ///

                          TextFormField(
                            decoration: InputDecoration(
                                labelText: "Account name",
                                icon: Icon(Icons.person_pin)),
                            controller: _nameAccount,
                            // obscureText: true,
                            validator: validateName,
                          ),

                          /////////////// SWIFT code  ////////////

                          TextFormField(
                            decoration: InputDecoration(
                                labelText: "SWIFT",
                                icon: Icon(Icons.confirmation_number)),
                            controller: _swiftCode,
                            // obscureText: true,
                            validator: (value) {
                              if (value != null) {
                                return null;
                              } else {
                                return "Please Enter a valid Swift Code";
                              }
                            },
                            // validator: (val) => validateConfirmPassword(
                            //     _password1Controller.text, val),
                            // onSaved: (String val) {
                            //   confirmPassword = val;
                            // },
                          ),

                          /////////////// Name on the bank account  ////////////

                          /////////////// Registration Button ////////////

                          Padding(
                            padding: const EdgeInsets.only(top: 30.0),
                            child: FlatButton(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      top: 8, bottom: 8, left: 10, right: 10),
                                  child: Text(
                                    _isLoading
                                        ? "Updating bank details" + '...'
                                        : "Update",
                                    textDirection: TextDirection.ltr,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15.0,
                                      decoration: TextDecoration.none,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ),
                                color: pickndellGreen,
                                disabledColor: Colors.grey,
                                shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(20.0)),
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        if (!_formKey.currentState.validate()) {
                                          return;
                                        } else {
                                          if (_isLoading) {
                                            return null;
                                          } else {
                                            return _sendBankDetails(
                                                widget.user);
                                          }
                                        }
                                      }),
                          ),
                          Padding(padding: EdgeInsets.only(top: 30.0)),
                          Divider(color: Colors.white),
                          Padding(padding: EdgeInsets.only(top: 30.0)),
                          InkWell(
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.arrow_back),
                                Padding(padding: EdgeInsets.only(right: 10.0)),
                                Text('Back'),
                              ],
                            ),
                            onTap: () {
                              print('BACK');
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ))),
          ),
        ),
      ),
    );
  }

  void errorBankDetailsForm(BuildContext context, res) {
    final trans = ExampleLocalizations.of(context);
    // String msg = res["is_employee"] == "This field may not be null."
    //     ? "Please select Sender or Courier registration."
    //     : res;
    Flushbar(
      // mainButton: FlatButton(
      //   child: Text('Retry'),
      //   onPressed: () {},
      // ),
      // backgroundGradient: LinearGradient(
      //     colors: [Colors.red[300], Colors.redAccent[700]], stops: [0.6, 1]),
      backgroundColor: Colors.red[600],
      margin: EdgeInsets.all(10),
      borderRadius: 8,
      // boxShadows: [
      //   BoxShadow(color: Colors.white, offset: Offset(3, 3), blurRadius: 3),
      // ],
      title: trans.register_err,
      message: trans.register_alert_fields + '. $res',
      icon: Icon(
        Icons.info_outline,
        size: 28,
        color: Colors.white,
      ),
      duration: Duration(seconds: 5),
    )..show(context);
  }

  void _sendBankDetails(User user) async {
    setState(() {
      _isLoading = true;
    });

    try {
      var res = await bankDetails(
          user: user,
          iban: _iban.text,
          swiftCode: _swiftCode.text,
          bankName: _bankName.text,
          bankAccount: _bankAccount.text,
          bankBranch: _bankBranch.text,
          nameAccount: _nameAccount.text,
          idNumber: _idNumber.text);
      if (res['response'] == "OK") {
        print('Sucess updating bank details: $res');

        Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => MessagePage(
                      user: widget.user,
                      messageType: "statusOK",
                      content: "Bank details updated",
                    )));
      } else {
        print("Failed registration process. Error: $res");
        errorBankDetailsForm(context, res);
      }
    } catch (e) {
      print('BANK DETAILS: Failed updating bank details. ERROR: $e');
      Navigator.push(
          context,
          new MaterialPageRoute(
              builder: (context) => MessagePage(
                    user: widget.user,
                    messageType: "Error",
                    content:
                        "We apologize for the inconvenience, but your information was not updated. Please contact PickNdell support or/and try again later.",
                  )));
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _bankAccount.dispose();
    _bankBranch.dispose();
    _bankName.dispose();
    _idNumber.dispose();
    _nameAccount.dispose();
    _swiftCode.dispose();
    super.dispose();
  }
}
